/*****************************************************************************
 * GStreamerBrilliant: Dynamic XCFramework built with system's GStreamer Implementation. Intended for use in Brilliant Mobile App.
 *****************************************************************************
 * Copyright (C) 2022 Brilliant Home Technologies
 *
 * Authors: Brilliant iOS Team <apple_developer # brilliant.tech>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wsign-compare"
#pragma clang diagnostic ignored "-Wunused-function"

#import "GStreamerRTPCustomBackend.h"

#include <gst/gst.h>
#include <gst/video/video.h>
#include <gst/audio/audio.h>
#include <gst/sdp/gstsdpmessage.h>
#include <gio/gio.h>
#include <openssl/evp.h>

#define GST_TYPE_VIDEO_OVERLAY \
(gst_video_overlay_get_type ())

G_BEGIN_DECLS

/* Do not allow seeks to be performed closer than this distance. It is visually useless, and will probably
 * confuse some demuxers. */
#define SEEK_MIN_DELAY (500 * GST_MSECOND)
#define ONE_64 G_GUINT64_CONSTANT (1)
#define CHANNEL_MASK_STEREO ((ONE_64<<GST_AUDIO_CHANNEL_POSITION_FRONT_LEFT) | (ONE_64<<GST_AUDIO_CHANNEL_POSITION_FRONT_RIGHT))

G_END_DECLS

#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <netinet/in.h>

@interface GStreamerRTPCustomBackend()
-(void)setUIMessage:(gchar*) message;
-(void)appFunction;
-(void)checkInitializationComplete;
@end

@implementation GStreamerRTPCustomBackend {
  id uiDelegate;                  /* Class that we use to interact with the user interface */
  GstElement *receivePipeline;    /* The running incoming pipeline */
  GstElement *outAudioDataPipe;   /* The running outgoing pipeline */
  GstElement *audioDepay;         /* The video sink element which receives XOverlay commands */
  GstElement *videoDepay;         /* The video sink element which receives XOverlay commands */
  GstElement *videoSink;          /* The video sink element which receives XOverlay commands */
  GMainContext *context;          /* GLib context used to run the main loop */
  GMainLoop *mainLoop;            /* GLib main loop */
  gboolean initialized;           /* To avoid informing the UI multiple times about the initialization */
  UIView *uiVideoView;            /* UIView that holds the video */
  GstState state;                 /* Current pipeline state */
  GstState targetState;           /* Desired pipeline state, to be set once buffering is complete */
  gint64 duration;                /* Cached clip duration */
  gint64 desiredPosition;         /* Position to seek to, once the pipeline is running */
  GstClockTime lastSeekTime;      /* For seeking overflow prevention (throttling) p*/
  gboolean isLive;                /* Live streams do not use buffering */
  GstElement *volume;             /* Volume element for muting and adjusting stream volume */

  // Incoming Video Config
  NSString *incomingVideoServer;
  int incomingVideoPort;
  NSData *incomingVideoKey;
  unsigned int incomingVideoSsrc;
  int incomingVideoSampleRate;
  int incomingVideoPayloadType;

  // Incoming Audio Config
  NSString *incomingAudioServer;
  int incomingAudioPort;
  NSData *incomingAudioKey;
  unsigned int incomingAudioSsrc;
  int incomingAudioChannels;
  int incomingAudioSampleRate;
  int incomingAudioPayloadType;

  // Outgoing Audio Config
  NSString *outgoingAudioServer;
  int outgoingAudioPort;
  NSData *outgoingAudioKey;
  unsigned int outgoingAudioSsrc;
  int outgoingAudioChannels;
  int outgoingAudioSampleRate;
  int outgoingAudioPayloadType;
  
  // Local port config
  int localRtpVideoUdpPort;
  int localRtcpVideoUdpPort;
  int localRtpAudioUdpPort;
  int localRtcpAudioUdpPort;

  NSMutableArray<NSNumber *> *busSignalIds;

  GstElement *micVolume;          /* Volume element for muting and adjusting stream volume */
  GstElement *rtpBin;             /* RTP Bin element */
  GstElement *videoDataPipe;      /* Incoming video data pipe */
  NSMutableArray<NSValue *> *sharedSocketPointers;
}

/*
 * Interface methods
 */

-(id)                init:(id)uiDelegate
                videoView:(UIView*)videoView
     localRTPVideoUDPPort:(int)localRtpVideoUdpPort
    localRTCPVideoUDPPort:(int)localRtcpVideoUdpPort
     localRTPAudioUDPPort:(int)localRtpAudioUdpPort
    localRTCPAudioUDPPort:(int)localRtcpAudioUdpPort
      incomingVideoServer:(NSString*)incomingVideoServer
      incomingAudioServer:(NSString*)incomingAudioServer
              audioServer:(NSString*)audioServer
  incomingVideoSampleRate:(int)incomingVideoSampleRate
  incomingAudioSampleRate:(int)incomingAudioSampleRate
          audioSampleRate:(int)audioSampleRate
 incomingVideoPayloadType:(int)incomingVideoPayloadType
 incomingAudioPayloadType:(int)incomingAudioPayloadType
         audioPayloadType:(int)audioPayloadType
         incomingVideoKey:(NSData*)incomingVideoKey
         incomingAudioKey:(NSData*)incomingAudioKey
                 audioKey:(NSData*)audioKey
        incomingVideoSsrc:(unsigned int)incomingVideoSsrc
        incomingAudioSsrc:(unsigned int)incomingAudioSsrc
                audioSsrc:(unsigned int)audioSsrc
        incomingVideoPort:(int)incomingVideoPort
        incomingAudioPort:(int)incomingAudioPort
                audioPort:(int)audioPort
    incomingAudioChannels:(int)incomingAudioChannels
            audioChannels:(int)audioChannels;
{
  if (self = [super init])
  {
    self->uiDelegate = uiDelegate;
    self->uiVideoView = videoView;
    self->duration = GST_CLOCK_TIME_NONE;
    
    self->localRtpVideoUdpPort = localRtpVideoUdpPort;
    self->localRtcpVideoUdpPort = localRtcpVideoUdpPort;
    self->localRtpAudioUdpPort = localRtpAudioUdpPort;
    self->localRtcpAudioUdpPort = localRtcpAudioUdpPort;
    
    self->incomingVideoServer = incomingVideoServer;
    self->incomingVideoPort = incomingVideoPort;
    self->incomingVideoKey = incomingVideoKey;
    self->incomingVideoSsrc = incomingVideoSsrc;
    self->incomingVideoPayloadType = incomingVideoPayloadType;
    self->incomingVideoSampleRate = incomingVideoSampleRate;

    self->incomingAudioServer = incomingAudioServer;
    self->incomingAudioPort = incomingAudioPort;
    self->incomingAudioKey = incomingAudioKey;
    self->incomingAudioSsrc = incomingAudioSsrc;
    self->incomingAudioPayloadType = incomingAudioPayloadType;
    self->incomingAudioChannels = incomingAudioChannels;
    self->incomingAudioSampleRate = incomingAudioSampleRate;

    self->outgoingAudioServer = audioServer;
    self->outgoingAudioPort = audioPort;
    self->outgoingAudioKey = audioKey;
    self->outgoingAudioSsrc = audioSsrc;
    self->outgoingAudioPayloadType = audioPayloadType;
    self->outgoingAudioChannels = audioChannels;
    self->outgoingAudioSampleRate = audioSampleRate;
    
    self->busSignalIds = [NSMutableArray array];
    self->sharedSocketPointers = [NSMutableArray array];
    /* Start the bus monitoring task */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self appFunction];
    });
  }
  
  return self;
}

-(void) deinit
{
  dispatch_async(dispatch_get_main_queue(), ^{
    GST_DEBUG("Quit main loop");
    if (self->mainLoop) {
      g_main_loop_quit(self->mainLoop);
    }
    GstBus *bus = gst_pipeline_get_bus(GST_PIPELINE (self->receivePipeline));
    for (NSNumber *busSignalId in self->busSignalIds) {
      g_signal_handler_disconnect(G_OBJECT(bus), [busSignalId unsignedLongValue]);
    }
    [self->busSignalIds removeAllObjects];
  });
}

-(void) play
{
  targetState = GST_STATE_PLAYING;
  isLive = (gst_element_set_state (receivePipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_NO_PREROLL);
}

-(void) pause
{
  targetState = GST_STATE_PAUSED;
  isLive = (gst_element_set_state (receivePipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_NO_PREROLL);
}

-(void) setPosition:(NSInteger)milliseconds
{
  gint64 position = (gint64)(milliseconds * GST_MSECOND);
  if (state >= GST_STATE_PAUSED) {
    executeSeek(position, self);
  } else {
    GST_DEBUG ("Scheduling seek to %" GST_TIME_FORMAT " for later", GST_TIME_ARGS (position));
    self->desiredPosition = position;
  }
}

-(void) setMute:(BOOL)muted
{
  g_object_set(volume, "mute", muted ? TRUE : FALSE, NULL);
}

-(void) setMicMute:(BOOL)muted
{
  g_object_set(micVolume, "mute", muted ? TRUE : FALSE, NULL);
}

/*
 * Private methods
 */

/* Change the message on the UI through the UI delegate */
-(void)setUIMessage:(gchar*) message
{
  NSString *string = [NSString stringWithUTF8String:message];
  if(uiDelegate && [uiDelegate respondsToSelector:@selector(gstreamerRTPCustomSetUIMessage:)])
  {
    [uiDelegate gstreamerRTPCustomSetUIMessage:string];
  }
}

/* Tell the application what is the current position and clip duration */
-(void) setCurrentUIPosition:(gint)pos duration:(gint)dur
{
  if(uiDelegate && [uiDelegate respondsToSelector:@selector(gstreamerRTPCustomSetCurrentPosition:duration:)])
  {
    [uiDelegate gstreamerRTPCustomSetCurrentPosition:pos duration:dur];
  }
}

/* If we have in_pipeline and it is running, query the current position and clip duration and inform
 * the application */
static gboolean rtp_custom_refresh_ui (GStreamerRTPCustomBackend *self) {
  gint64 position;
  /* We do not want to update anything unless we have a working in_pipeline in the PAUSED or PLAYING state */
  if (!self || !self->receivePipeline || self->state < GST_STATE_PAUSED)
    return TRUE;
  
  /* If we didn't know it yet, query the stream duration */
  if (!GST_CLOCK_TIME_IS_VALID (self->duration)) {
    gst_element_query_duration (self->receivePipeline, GST_FORMAT_TIME,&self->duration);
  }
  
  if (gst_element_query_position (self->receivePipeline, GST_FORMAT_TIME, &position)) {
    /* The UI expects these values in milliseconds, and GStreamer provides nanoseconds */
    [self setCurrentUIPosition:position / GST_MSECOND duration:self->duration / GST_MSECOND];
  }
  return TRUE;
}

/* Forward declaration for the delayed seek callback */
static gboolean rtp_custom_delayed_seek_cb (GStreamerRTPCustomBackend *self);

/* Perform seek, if we are not too close to the previous seek. Otherwise, schedule the seek for
 * some time in the future. */
static void executeSeek (gint64 position, GStreamerRTPCustomBackend *self) {
  gint64 diff;
  
  if (position == GST_CLOCK_TIME_NONE)
    return;
  
  diff = gst_util_get_timestamp () - self->lastSeekTime;
  
  if (GST_CLOCK_TIME_IS_VALID (self->lastSeekTime) && diff < SEEK_MIN_DELAY) {
    /* The previous seek was too close, delay this one */
    GSource *timeout_source;
    
    if (self->desiredPosition == GST_CLOCK_TIME_NONE) {
      /* There was no previous seek scheduled. Setup a timer for some time in the future */
      timeout_source = g_timeout_source_new ((SEEK_MIN_DELAY - diff) / GST_MSECOND);
      g_source_set_callback (timeout_source, (GSourceFunc)rtp_custom_delayed_seek_cb, (__bridge void *)self, NULL);
      g_source_attach (timeout_source, self->context);
      g_source_unref (timeout_source);
    }
    /* Update the desired seek position. If multiple petitions are received before it is time
     * to perform a seek, only the last one is remembered. */
    self->desiredPosition = position;
    GST_DEBUG ("Throttling seek to %" GST_TIME_FORMAT ", will be in %" GST_TIME_FORMAT,
               GST_TIME_ARGS (position), GST_TIME_ARGS (SEEK_MIN_DELAY - diff));
  } else {
    /* Perform the seek now */
    GST_DEBUG ("Seeking to %" GST_TIME_FORMAT, GST_TIME_ARGS (position));
    self->lastSeekTime = gst_util_get_timestamp ();
    gst_element_seek_simple (self->receivePipeline, GST_FORMAT_TIME, GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_KEY_UNIT, position);
    self->desiredPosition = GST_CLOCK_TIME_NONE;
  }
}

/* Delayed seek callback. This gets called by the timer setup in the above function. */
static gboolean rtp_custom_delayed_seek_cb (GStreamerRTPCustomBackend *self) {
  GST_DEBUG ("Doing delayed seek to %" GST_TIME_FORMAT, GST_TIME_ARGS (self->desiredPosition));
  executeSeek (self->desiredPosition, self);
  return FALSE;
}

/* Retrieve errors from the bus and show them on the UI */
static void error_cb (GstBus *bus, GstMessage *msg, GStreamerRTPCustomBackend *self)
{
  GError *err;
  gchar *debugInfo;
  gchar *messageString;
  
  gst_message_parse_error (msg, &err, &debugInfo);
  messageString = g_strdup_printf ("Error received from element %s: %s", GST_OBJECT_NAME (msg->src), err->message);
  g_clear_error (&err);
  g_free (debugInfo);
  [self setUIMessage:messageString];
  g_free (messageString);
  gst_element_set_state (self->receivePipeline, GST_STATE_NULL);
}

/* Called when the End Of the Stream is reached. Just move to the beginning of the media and pause. */
static void rtp_custom_eos_cb (GstBus *bus, GstMessage *msg, GStreamerRTPCustomBackend *self) {
  self->targetState = GST_STATE_PAUSED;
  self->isLive = (gst_element_set_state (self->receivePipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_NO_PREROLL);
  executeSeek (0, self);
}

/* Called when the duration of the media changes. Just mark it as unknown, so we re-query it in the next UI refresh. */
static void rtp_custom_duration_cb (GstBus *bus, GstMessage *msg, GStreamerRTPCustomBackend *self) {
  self->duration = GST_CLOCK_TIME_NONE;
}

/* Called when buffering messages are received. We inform the UI about the current buffering level and
 * keep the in_pipeline paused until 100% buffering is reached. At that point, set the desired state. */
static void rtp_custom_buffering_cb (GstBus *bus, GstMessage *msg, GStreamerRTPCustomBackend *self) {
  gint percent;
  
  if (self->isLive)
    return;
  
  gst_message_parse_buffering (msg, &percent);
  if (percent < 100 && self->targetState >= GST_STATE_PAUSED) {
    gchar * messageString = g_strdup_printf ("Buffering %d%%", percent);
    gst_element_set_state (self->receivePipeline, GST_STATE_PAUSED);
    [self setUIMessage:messageString];
    g_free (messageString);
  } else if (self->targetState >= GST_STATE_PLAYING) {
    gst_element_set_state (self->receivePipeline, GST_STATE_PLAYING);
  } else if (self->targetState >= GST_STATE_PAUSED) {
    [self setUIMessage:"Buffering complete"];
  }
}

/* Called when the clock is lost */
static void rtp_custom_clock_lost_cb (GstBus *bus, GstMessage *msg, GStreamerRTPCustomBackend *self) {
  if (self->targetState >= GST_STATE_PLAYING) {
    gst_element_set_state (self->receivePipeline, GST_STATE_PAUSED);
    gst_element_set_state (self->receivePipeline, GST_STATE_PLAYING);
  }
}

static void rtp_custom_on_bus_message (GstBus *bus, GstMessage *message, GStreamerRTPCustomBackend *self) {
  GstState oldState;
  GstState newState;
  GError *err = NULL;
  gchar *name, *debug = NULL;
  switch (GST_MESSAGE_TYPE (message)) {
    case GST_MESSAGE_STATE_CHANGED:
      gst_message_parse_state_changed(message, &oldState, &newState, NULL);
      // If the object does not have a parent then it's the in_pipeline!
      GstObject *parent = gst_object_get_parent(message->src);
      if (!parent && newState == GST_STATE_PLAYING) {
        GST_DEBUG("Video has started, stopping timer");
        // Stop a timer...
      }
      if (parent) {
        gst_object_unref(parent);
      }
      break;
    case GST_MESSAGE_ERROR:
      // Start a timer...
      name = gst_object_get_path_string(message->src);
      gst_message_parse_error(message, &err, &debug);
      GST_ERROR ("ERROR: from element: %s err %s", name, err->message);
      if (debug != NULL) {
        GST_ERROR ("Additional debug info: %s", debug);
      }
      g_error_free(err);
      g_free(debug);
      g_free(name);
      break;
    default:
      break;
  }
}

/* Retrieve the video sink's Caps and tell the application about the media size */
static void rtp_custom_check_media_size (GStreamerRTPCustomBackend *self, GstElement * videoSink) {
  GstPad *videoSinkPad;
  GstCaps *caps;
  GstVideoInfo info;
  
  
  /* Do nothing if there is no video sink (this might be an audio-only clip */
  if (!videoSink) return;
  
  videoSinkPad = gst_element_get_static_pad (videoSink, "sink");
  caps = gst_pad_get_current_caps (videoSinkPad);
  
  if (gst_video_info_from_caps (&info, caps)) {
    info.width = info.width * info.par_n / info.par_d;
    GST_DEBUG ("Media size is %dx%d, notifying application", info.width, info.height);
    
    if (self->uiDelegate && [self->uiDelegate respondsToSelector:@selector(gstreamerRTPCustomMediaSizeChanged:height:)])
    {
      [self->uiDelegate gstreamerRTPCustomMediaSizeChanged:info.width height:info.height];
    }
  }
}

/* Notify UI about in_pipeline state changes */
static void rtp_custom_state_changed_cb (GstBus *bus, GstMessage *msg, GStreamerRTPCustomBackend *self)
{
  GstState oldState, newState, pendingState;
  gst_message_parse_state_changed (msg, &oldState, &newState, &pendingState);
  /* Only pay attention to messages coming from the in_pipeline, not its children */
  if (GST_MESSAGE_SRC (msg) == GST_OBJECT (self->receivePipeline)) {
    self->state = newState;
    gchar *message = g_strdup_printf("State changed to %s", gst_element_state_get_name(newState));
    [self setUIMessage:message];
    g_free (message);
    
    if (oldState == GST_STATE_READY && newState == GST_STATE_PAUSED)
    {
      rtp_custom_check_media_size(self, self->videoSink);
      
      /* If there was a scheduled seek, perform it now that we have moved to the Paused state */
      if (GST_CLOCK_TIME_IS_VALID (self->desiredPosition))
        executeSeek (self->desiredPosition, self);
    }
  }
}

static void rtp_custom_on_decode_bin_pad_added (GstElement *decodeBin, GstPad *pad, GStreamerRTPCustomBackend *self)
{
  gboolean success = gst_element_link(decodeBin, self->videoDataPipe);
  if (!success) {
    gchar *padName = gst_pad_get_name(pad);
    gchar *message = g_strdup_printf("GStreamerRTPCustomBackend is unable to link pad %s from decodeBin to video sink.", padName);
    [self setUIMessage:message];
    g_free(padName);
    g_free(message);
  }
}

static void rtp_custom_on_rtp_bin_pad_added (GstElement *rtpBin, GstPad* pad, GStreamerRTPCustomBackend *self) {
  gchar *padName = gst_pad_get_name(pad);
  GST_DEBUG("onRtpBinPadAdded, pad name: %s", padName);
  if (strstr(padName, "send_rtp_src") != NULL) {
    GstPad *sinkPad = gst_element_get_static_pad(self->outAudioDataPipe, "sink");
    gst_pad_link(pad, sinkPad);
  } else if (strstr(padName, "recv_rtp_src") != NULL) {
    GstCaps *caps = gst_pad_get_current_caps(pad);
    GstStructure *structure = gst_caps_get_structure(caps, 0);
    bool isAudioPad =
        (gst_structure_has_field_typed(structure, "media", G_TYPE_STRING) &&
         g_strcmp0(g_value_get_string(gst_structure_get_value(structure, "media")), "audio") == 0);
    GstPad *sinkPad = gst_element_get_static_pad(isAudioPad ? self->audioDepay : self->videoDepay, "sink");
    gst_pad_link(pad, sinkPad);
  }
  g_free(padName);
}

static void rtp_custom_data_available_callback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    CFDataRef dataRef = (CFDataRef)data;
    NSLog(@"RTP Custom Backend Data recieved (%s) ", CFDataGetBytePtr(dataRef));
}

static GstBuffer *string_to_buffer(NSData *data) {
  size_t data_length = [data length];
  // No need for a null terminator
  gpointer buffer_data = g_memdup([data bytes], data_length);
  // Takes ownership of allocated memory
  GstBuffer *buffer = gst_buffer_new_wrapped(buffer_data, data_length);
  return buffer;
}

static GstCaps *request_srtp_key(GstElement *element, guint ssrc, GstBuffer *keyBuffer) {
  GstCaps *caps = gst_caps_new_simple(
                                      "application/x-srtp",
                                      "ssrc", G_TYPE_UINT, ssrc,
                                      "srtp-key", GST_TYPE_BUFFER, keyBuffer,
                                      "mki", GST_TYPE_BUFFER, NULL,
                                      "srtp-cipher", G_TYPE_STRING, "aes-128-icm",
                                      "srtp-auth", G_TYPE_STRING, "hmac-sha1-80",
                                      "srtcp-cipher", G_TYPE_STRING, "aes-128-icm",
                                      "srtcp-auth", G_TYPE_STRING, "hmac-sha1-80",
                                      NULL);
  return caps;
}

-(Boolean) setUpPipelines
{
  receivePipeline = gst_pipeline_new("incoming_video_pipeline");
  rtpBin = gst_element_factory_make("rtpbin", "incoming_video_manager");
  g_object_set(rtpBin,
               "latency", 500,
               "autoremove", true,
               "buffer-mode", 1, // RTP_JITTER_BUFFER_MODE_SLAVE
               "rtcp-sync", 2, // GST_RTP_BIN_RTCP_SYNC_RTP,
               NULL);
  g_signal_connect (G_OBJECT (rtpBin), "pad-added", (GCallback)rtp_custom_on_rtp_bin_pad_added, (__bridge void *)self);
  gst_bin_add(GST_BIN(receivePipeline), rtpBin);
  Boolean notifyStartVideoSuccessful =
      [self notifyCustomRTPToStartSendingDataAtHost:incomingVideoServer
                                             atPort:incomingVideoPort
                                             toPort:localRtpVideoUdpPort];
  if (!notifyStartVideoSuccessful) {
    GST_WARNING("Failed to notify Target to start video.");
    return false;
  }
  Boolean videoPipelineSetupSuccessful = [self setUpReceiveVideoPipeline];
  if (!videoPipelineSetupSuccessful) {
    GST_WARNING("Failed to setup video pipeline");
    return false;
  }
  Boolean notifyStartAudioSuccessful =
  [self notifyCustomRTPToStartSendingDataAtHost:incomingAudioServer
                                         atPort:incomingAudioPort
                                         toPort:localRtpAudioUdpPort];
  if (!notifyStartAudioSuccessful) {
    GST_WARNING("Failed to notify Target to start audio.");
    return false;
  }
  // The socket is shared for sending/receiving audio RTP packets because the server will
  // deliver audio to the port it sees packets coming from
  GSocket *audioRTPSocket = [self createSocketOnPort:localRtpAudioUdpPort];
  if (!audioRTPSocket) {
    GST_WARNING("Failed to create audio RTP socket.");
    return false;
  }
  [sharedSocketPointers addObject:[NSValue valueWithPointer:audioRTPSocket]];
  Boolean incomingAudioPipelineSetupSuccessful = [self setUpReceiveAudioPipelineWithSocket: audioRTPSocket];
  if (!incomingAudioPipelineSetupSuccessful) {
    GST_WARNING("Failed to setup incoming audio pipeline.");
    return false;
  }
  Boolean outgoingAudioPipelineSetupSuccessful = [self setUpSendAudioPipelineWithSocket:audioRTPSocket];
  if (!outgoingAudioPipelineSetupSuccessful) {
    GST_WARNING("Failed to setup outgoing audio pipeline.");
    return false;
  }
  
  return true;
}

/*
 *  Video Pipeline Diagram:
 *
 *   [rtp udpsrc]  [rtcp udpsrc]
 *        V             V
 *        |          #2 |   -------  #3
 *        |             +->|      |----->[rtcp udpsink]
 *        +-->[srtpdec]--->|rtpbin|
 *                     #1  |      |
 *                         -------
 *                          |
 *                          V                              **
 *                   [rtph264depay]-->[queue]-->[decodebin]-->[identity]-->[autovideoconvert]-->[autovideosink]
 *
 *  (**) denotes a link added in response to the pad-added signal being emitted.
 *  (#*) denotes a manual pad link
 */
-(Boolean) setUpReceiveVideoPipeline
{
  GST_DEBUG("Starting to set up receive video pipeline");
  GstElement *rtpVideoUdpSrc = gst_element_factory_make("udpsrc", "rtp_video_udp_src");
  g_object_set(rtpVideoUdpSrc, "port", localRtpVideoUdpPort, NULL);
  GstElement *rtcpVideoUdpSrc = gst_element_factory_make("udpsrc", "rtcp_video_udp_src");
  g_object_set(rtcpVideoUdpSrc, "port", localRtcpVideoUdpPort, NULL);
  GstElement *rtcpVideoUdpSink = gst_element_factory_make("udpsink", "rtcp_video_udp_sink");
  g_object_set(rtcpVideoUdpSink,
               "host", incomingVideoServer,
               "port", incomingVideoPort + 1,
               "bind-port", localRtcpVideoUdpPort,
               "sync", false,
               "async", false,
               NULL);
  videoDepay = gst_element_factory_make("rtph264depay", "video_depay");
  GstElement *queue = gst_element_factory_make("queue", "video_queue");
  g_object_set(queue,
               "max-size-buffers", 0,
               "max-size-bytes", 0,
               "max-size-time", 0,
               NULL);
  GstElement *decodeBin = gst_element_factory_make("decodebin", NULL);
  g_signal_connect(G_OBJECT(decodeBin),
                   "pad-added",
                   G_CALLBACK(rtp_custom_on_decode_bin_pad_added),
                   (__bridge void *)self);
  videoDataPipe = gst_element_factory_make("identity", NULL);
  GstElement *autoVideoConvert = gst_element_factory_make("autovideoconvert", NULL);
  GstElement *autoVideoSink = gst_element_factory_make("autovideosink", NULL);
  gst_bin_add_many(GST_BIN(receivePipeline),
                   rtpVideoUdpSrc,
                   rtcpVideoUdpSrc,
                   rtcpVideoUdpSink,
                   videoDepay,
                   queue,
                   decodeBin,
                   videoDataPipe,
                   autoVideoConvert,
                   autoVideoSink,
                   NULL);
  // Use autovideoconvert ! autovideosink
  gst_element_link_many(videoDepay, queue, decodeBin, NULL);
  gst_element_link_many(videoDataPipe, autoVideoConvert, autoVideoSink, NULL);
  GstCaps *videoCaps = gst_caps_new_simple("application/x-srtp",
                                           "clock-rate", G_TYPE_INT, 90000,
                                           "encoding-name", G_TYPE_STRING, "H264",
                                           "payload", G_TYPE_INT, 96,
                                           "media", G_TYPE_STRING, "video",
                                           NULL);
  // incomingVideoSsrc expected to be in [0, 4,294,967,295] as values can be up to 2^31
  GstElement *srtpDec = [self getSRTPDecoderWithKey:incomingVideoKey
                                           streamId:incomingVideoSsrc
                                      sourceElement:rtpVideoUdpSrc
                                        sinkElement:nil
                                           pipeline:GST_BIN(receivePipeline)
                                           linkCaps:videoCaps];
  gst_object_unref(videoCaps);

  if (srtpDec == NULL) {
    GST_WARNING("Failed to set up srtpdec element in RTP Custom video pipeline.");
    return false;
  }
  // #1 Manually link srtpdec:rtp_src to rtpbin:recv_rtp_sink_0
  GstPad *srtpDecRtpSrc = gst_element_get_static_pad(srtpDec, "rtp_src");
  GstPad *rtpBinRecvRtpSink = gst_element_request_pad_simple(rtpBin, "recv_rtp_sink_%u");
  gst_pad_link(srtpDecRtpSrc, rtpBinRecvRtpSink);
  
  // #2 Manually link rtcp udpsrc:src to rtpbin:recv_rtcp_sink_0
  GstPad *rtcpUdpSrc = gst_element_get_static_pad(rtcpVideoUdpSrc, "src");
  GstPad *rtpBinRecvRtcpSink = gst_element_request_pad_simple(rtpBin, "recv_rtcp_sink_%u");
  gst_pad_link(rtcpUdpSrc, rtpBinRecvRtcpSink);
  
  // #3 Manually link rtpbin:send_rtcp_src_0 to rtcp udpsink:sink
  GstPad *rtpBinSendRtcpSrc = gst_element_request_pad_simple(rtpBin, "send_rtcp_src_%u");
  GstPad *rtcpUdpSink = gst_element_get_static_pad(rtcpVideoUdpSink, "sink");
  gst_pad_link(rtpBinSendRtcpSrc, rtcpUdpSink);
  
  return true;
}

/*
 *  Audio Pipeline Diagram:
 *
 *  Shares the same rtpbin with the video elements in the receive pipeline.
 *
 *   [rtp udpsrc]  [rtcp udpsrc]
 *        V             V
 *        |          #2 |   -------  #3
 *        |             +->|      |----->[rtcp udpsink]
 *        +-->[srtpdec]--->|rtpbin|
 *                     #1  |      |
 *                         -------
 *                            |
 *                    +-------+
 *                    V
 *             [rtpL16depay]-->[queue]-->[audioconvert]-->[volume]-->[autoaudiosink]
 *
 *  (*) denotes an optional element in the pipeline
 *  (#*) denotes a manual pad link
 */
-(Boolean) setUpReceiveAudioPipelineWithSocket: (GSocket *)audioRTPSocket
{
  GST_DEBUG("Starting to set up receive audio pipeline");
  GstElement *rtpAudioUdpSrc = gst_element_factory_make("udpsrc", "rtp_audio_udp_src");
  g_object_set(rtpAudioUdpSrc,
               "timeout", (guint64) 1000000000,
               "socket", audioRTPSocket,
               "close-socket", false,
               NULL);
  GstElement *rtcpAudioUdpSrc = gst_element_factory_make("udpsrc", "rtcp_audio_udp_src");
  g_object_set(rtcpAudioUdpSrc, "port", localRtcpAudioUdpPort, NULL);
  GstElement *rtcpAudioUdpSink = gst_element_factory_make("udpsink", "rtcp_audio_udp_sink");
  g_object_set(rtcpAudioUdpSink,
               "host", [incomingAudioServer cStringUsingEncoding: NSUTF8StringEncoding],
               "port", incomingAudioPort + 1,
               "sync", false,
               "async", false,
               NULL);
  audioDepay = gst_element_factory_make("rtpL16depay", "audio_depay");
  GstElement *queue = gst_element_factory_make("queue", "audio_queue");
  g_object_set(queue,
               "max-size-buffers", 0,
               "max-size-bytes", 0,
               "max-size-time", 0,
               NULL);
  
  GstElement *audioConvert = gst_element_factory_make("audioconvert", NULL);
  volume = gst_element_factory_make("volume", NULL);
  g_object_set(volume, "mute", true, NULL);
  GstElement *autoAudioSink = gst_element_factory_make("autoaudiosink", NULL);
  
  gst_bin_add_many(GST_BIN(receivePipeline),
                   rtpAudioUdpSrc,
                   rtcpAudioUdpSrc,
                   rtcpAudioUdpSink,
                   audioDepay,
                   queue,
                   audioConvert,
                   volume,
                   autoAudioSink,
                   NULL);
  if (!gst_element_link(audioDepay, queue)) {
    GST_WARNING("Failed to link audio_depay to audio_queue");
    return false;
  }
  if (!gst_element_link_many(queue, audioConvert, volume, autoAudioSink, NULL)) {
    GST_WARNING("Failed to link audio_queue to rest of audio pipeline");
    return false;
  }
  GstCaps *audioCaps = gst_caps_new_simple("application/x-srtp",
                                           "clock-rate", G_TYPE_INT, incomingAudioSampleRate,
                                           "encoding-name", G_TYPE_STRING, "L16",
                                           "payload", G_TYPE_INT, 97,
                                           "media", G_TYPE_STRING, "audio",
                                           "channels", G_TYPE_INT, incomingAudioChannels,
                                           "channel-mask", GST_TYPE_BITMASK, CHANNEL_MASK_STEREO,
                                           "format", G_TYPE_STRING, "S16LE",
                                           NULL);
  GstElement *srtpDec = [self getSRTPDecoderWithKey:incomingAudioKey
                                           streamId:incomingAudioSsrc
                                      sourceElement:rtpAudioUdpSrc
                                        sinkElement:nil
                                           pipeline:GST_BIN(receivePipeline)
                                           linkCaps:audioCaps];
  gst_object_unref(audioCaps);
  if (srtpDec == NULL) {
    GST_WARNING("Failed to set up srtpdec element in CustomRTP audio pipeline");
    return false;
  }
  
  // #1 Manually link srtpdec:rtp_src to rtpbin:recv_rtp_sink_1
  GstPad *srtpDecRtpSrc = gst_element_get_static_pad(srtpDec, "rtp_src");
  GstPad *rtpBinRecvRtpSink = gst_element_request_pad_simple(rtpBin, "recv_rtp_sink_%u");
  gst_pad_link(srtpDecRtpSrc, rtpBinRecvRtpSink);
  
  // #2 Manually link rtcp udpsrc:src to rtpbin:recv_rtcp_sink_1
  GstPad *rtcpUdpSrc = gst_element_get_static_pad(rtcpAudioUdpSrc, "src");
  GstPad *rtpBinRecvRtcpSink = gst_element_request_pad_simple(rtpBin, "recv_rtcp_sink_%u");
  gst_pad_link(rtcpUdpSrc, rtpBinRecvRtcpSink);
  
  // #3 Manually link rtpbin:send_rtcp_src_1 to rtcp udpsink:sink
  GstPad *rtpBinSendRtcpSrc = gst_element_request_pad_simple(rtpBin, "send_rtcp_src_%u");
  GstPad *rtcpUdpSink = gst_element_get_static_pad(rtcpAudioUdpSink, "sink");
  gst_pad_link(rtpBinSendRtcpSrc, rtcpUdpSink);
  
  return true;
}

/*
 *  Outgoing Audio Pipeline Diagram:
 *
 *  Shares the same rtpbin with the elements in the receive pipeline.
 *
 *  [autioaudiosrc]
 *      V
 *  [audioconvert]       [rtcp udpsrc]
 *      V                      V
 *  [capsfilter]               |      (#1)     -------
 *      V                      +------------->|      | (#3)
 *  [volume]-->[rtpL16pay]------------------->|rtpbin|-->[rtcp udpsink]
 *                                        (#2)|      |
 *                                             -------
 *                                               V
 *                                           [identity]
 *                                               V
 *                                           [srtpenc]
 *                                               V
 *                                         [rtp udpsink]
 *
 *  (*) denotes an optional element in the pipeline
 *  (#*) denotes a manual pad link
 */
-(Boolean) setUpSendAudioPipelineWithSocket: (GSocket *)audioRTPSocket
{
  GstElement *autoAudioSrc = gst_element_factory_make("autoaudiosrc", NULL);
  GstElement *audioConvert = gst_element_factory_make("audioconvert", NULL);
  GstCaps *srcCaps = gst_caps_new_simple("audio/x-raw",
                                         "rate", G_TYPE_INT, outgoingAudioSampleRate,
                                         "channels", G_TYPE_INT, 1,
                                         "format", G_TYPE_STRING, "S16LE",
                                         "channel-mask", GST_TYPE_BITMASK, CHANNEL_MASK_STEREO,
                                         nil);
  GstElement *outgoingAudioCaps = gst_element_factory_make("capsfilter", "outgoing_audio_rtp_caps");
  g_object_set(outgoingAudioCaps, "caps", srcCaps, NULL);
  gst_object_unref(srcCaps);

  micVolume = gst_element_factory_make("volume", "mic_volume");
  g_object_set(micVolume, "mute", true, NULL);
  GstElement *rtpL16Pay = gst_element_factory_make("rtpL16pay", NULL);
  g_object_set(rtpL16Pay, "mtu", 332, "min_ptime", 20000000, NULL);
  gst_bin_add_many(GST_BIN(receivePipeline),
                   autoAudioSrc,
                   audioConvert,
                   outgoingAudioCaps,
                   micVolume,
                   rtpL16Pay,
                   NULL);
  if (!gst_element_sync_state_with_parent(autoAudioSrc) ||
      !gst_element_sync_state_with_parent(micVolume)) {
    GST_WARNING("Failed to sync state while setting up audio source");
  }
  if (!gst_element_link_many(autoAudioSrc, audioConvert, outgoingAudioCaps, micVolume, rtpL16Pay, NULL)) {
    GST_ERROR("Failed to link audio source to micVolume and rtpL16pay");
    return false;
  }
  
  GstElement *rtpAudioUdpSink = gst_element_factory_make("udpsink", "rtp_outgoing_audio_udp_sink");
  g_object_set(rtpAudioUdpSink,
               "host", [outgoingAudioServer cStringUsingEncoding:NSUTF8StringEncoding],
               "port", outgoingAudioPort,
               "socket", audioRTPSocket,
               "close-socket", false,
               "sync", false,
               "async", false,
               NULL);
  
  GstElement *rtcpAudioUdpSink = gst_element_factory_make("udpsink", "rtcp_outgoing_audio_udp_sink");
  g_object_set(rtcpAudioUdpSink,
               "host", [outgoingAudioServer cStringUsingEncoding:NSUTF8StringEncoding],
               "port", outgoingAudioPort + 1,
               "bind-port", localRtcpAudioUdpPort,
               "sync", false,
               "async", false,
               NULL);
  GstElement *rtcpAudioUdpSrc = gst_element_factory_make("udpsrc", "rtcp_outgoing_audio_udp_src");
  g_object_set(rtcpAudioUdpSrc, "port", localRtcpAudioUdpPort, NULL);
  outAudioDataPipe = gst_element_factory_make("identity", NULL);
  GstCaps *audioCaps = gst_caps_new_simple("application/x-rtp",
                                           "clock-rate", G_TYPE_INT, outgoingAudioSampleRate,
                                           "encoding-name", G_TYPE_STRING, "L16",
                                           "payload", G_TYPE_INT, 97,
                                           "media", G_TYPE_STRING, "audio",
                                           "channels", G_TYPE_INT, outgoingAudioChannels,
                                           "channel-mask", GST_TYPE_BITMASK, CHANNEL_MASK_STEREO,
                                           "format", G_TYPE_STRING, "S16LE",
                                           "ssrc", G_TYPE_UINT, outgoingAudioSsrc,
                                           "srtp-cipher", G_TYPE_STRING, "aes-128-icm",
                                           "srtp-auth", G_TYPE_STRING, "hmac-sha1-80",
                                           NULL);
  GstElement *rtpCapsFilter = gst_element_factory_make("capsfilter", "audio_rtp_caps");
  g_object_set(rtpCapsFilter, "caps", audioCaps, NULL);
  gst_object_unref(audioCaps);
  
  gst_bin_add_many(GST_BIN(receivePipeline),
                   rtpCapsFilter,
                   rtpAudioUdpSink,
                   rtcpAudioUdpSink,
                   rtcpAudioUdpSrc,
                   outAudioDataPipe,
                   NULL);
  [self addSrtpEncoderWithKey:outgoingAudioKey
                     streamId:outgoingAudioSsrc
                   srcElement:outAudioDataPipe
                  sinkElement:rtpAudioUdpSink
                     pipeline:GST_BIN(receivePipeline)
                     linkCaps:audioCaps];
  // (#1) Manually link rtcp udpsrc:src to rtpbin:recv_rtcp_sink_2
  GstPad *rtcpUdpSrc = gst_element_get_static_pad(rtcpAudioUdpSrc, "src");
  GstPad *rtpBinRecvRtcpSink = gst_element_request_pad_simple(rtpBin, "recv_rtcp_sink_%u");
  gst_pad_link(rtcpUdpSrc, rtpBinRecvRtcpSink);
  
  // (#2) Manually link rtpL16pay[capsfilter]:src to rtpbin:send_rtp_sink_0, automatically creates
  // send_rtp_src_0 pad on rtpbin
  gst_element_link(rtpL16Pay, rtpCapsFilter);
  GstPad *rtpPaySrc = gst_element_get_static_pad(rtpCapsFilter, "src");
  GstPad *rtpBinSendRtpSink = gst_element_request_pad_simple(rtpBin, "send_rtp_sink_%u");
  gst_pad_link(rtpPaySrc, rtpBinSendRtpSink);
  
  // (#3) Manually link rtpbin:send_rtcp_src_2 to rtcp udpsink:sink
  GstPad *rtpBinSendRtcpSrc = gst_element_request_pad_simple(rtpBin, "send_rtcp_src_%u");
  GstPad *rtcpUdpSink = gst_element_get_static_pad(rtcpAudioUdpSink, "sink");
  gst_pad_link(rtpBinSendRtcpSrc, rtcpUdpSink);
  
  return true;
}

-(GSocket *) createSocketOnPort: (uint16_t) bindPort {
  GError *error;
  GSocket *socket = g_socket_new(G_SOCKET_FAMILY_IPV4,
                                 G_SOCKET_TYPE_DATAGRAM,
                                 G_SOCKET_PROTOCOL_UDP,
                                 &error);
  if (!socket) {
    GST_ERROR("Failed to create GSocket! Error: %s", error->message);
    return nil;
  }
  GInetAddress * hostAddress = g_inet_address_new_from_string("0.0.0.0");
  GSocketAddress * bindAddress = g_inet_socket_address_new(hostAddress, bindPort);
  if (!g_socket_bind(socket, bindAddress, true, &error)) {
    GST_ERROR("Failed to bind port %d. Error: %s", bindPort, error ? error->message : "<unknown error");
    g_socket_close(socket, NULL);
    g_object_unref(socket);
    g_object_unref(hostAddress);
    g_object_unref(bindAddress);
    return nil;
  }
  return socket;
}



/* Check if all conditions are met to report GStreamer as initialized.
 * These conditions will change depending on the application */
-(void) checkInitializationComplete
{
  if (!initialized && mainLoop) {
    GST_DEBUG ("Initialization complete, notifying application.");
    if (uiDelegate && [uiDelegate respondsToSelector:@selector(gstreamerRTPCustomInitialized)])
    {
      [uiDelegate gstreamerRTPCustomInitialized];
    }
    initialized = TRUE;
  }
}

/* Main method for the bus monitoring code */
-(void) appFunction
{
  GSource *timeoutSource;
  GSource *busSource;
  GError *error = NULL;
  
  GST_DEBUG ("Creating in_pipeline");
  
  /* Create our own GLib Main Context and make it the default one */
  context = g_main_context_new ();
  g_main_context_push_thread_default(context);
  
  /* Build in_pipeline */
  
  [self setUpPipelines];
  
  GstBus *bus = gst_pipeline_get_bus(GST_PIPELINE (self->receivePipeline));
  gst_bus_enable_sync_message_emission(bus);
  gulong signalId = g_signal_connect(G_OBJECT (bus), "sync-message", (GCallback)rtp_custom_on_bus_message, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:signalId]];

  
  /* Set the in_pipeline to READY, so it can already accept a window handle */
  gst_element_set_state(receivePipeline, GST_STATE_READY);
  
  videoSink = gst_bin_get_by_interface(GST_BIN(receivePipeline), GST_TYPE_VIDEO_OVERLAY);
  if (!videoSink) {
    GST_ERROR ("Could not retrieve video sink");
    gst_object_unref (bus);
    return;
  }
  gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(videoSink), (guintptr) (id) uiVideoView);
  
  /* Instruct the bus to emit signals for each received message, and connect to the interesting signals */
  busSource = gst_bus_create_watch (bus);
  g_source_set_callback (busSource, (GSourceFunc) gst_bus_async_signal_func, NULL, NULL);
  g_source_attach (busSource, context);
  g_source_unref (busSource);
  gulong errorSignalId = g_signal_connect (G_OBJECT (bus), "message::error", (GCallback)error_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:errorSignalId]];
  gulong eosSignalId = g_signal_connect (G_OBJECT (bus), "message::eos", (GCallback)rtp_custom_eos_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:eosSignalId]];
  gulong stateChangedSignalId = g_signal_connect (G_OBJECT (bus), "message::state-changed", (GCallback)rtp_custom_state_changed_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:stateChangedSignalId]];
  gulong durationSignalId = g_signal_connect (G_OBJECT (bus), "message::duration", (GCallback)rtp_custom_duration_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:durationSignalId]];
  gulong bufferingSignalId = g_signal_connect (G_OBJECT (bus), "message::buffering", (GCallback)rtp_custom_buffering_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:bufferingSignalId]];
  gulong clockLostSignalId = g_signal_connect (G_OBJECT (bus), "message::clock-lost", (GCallback)rtp_custom_clock_lost_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:clockLostSignalId]];
  gst_object_unref (bus);
  
  /* Register a function that GLib will call 4 times per second */
  timeoutSource = g_timeout_source_new (250);
  g_source_set_callback (timeoutSource, (GSourceFunc)rtp_custom_refresh_ui, (__bridge void *)self, NULL);
  g_source_attach (timeoutSource, context);
  g_source_unref (timeoutSource);
  
  /* Create a GLib Main Loop and set it to run */
  GST_DEBUG ("Entering main loop...");
  mainLoop = g_main_loop_new (context, FALSE);
  [self checkInitializationComplete];
  g_main_loop_run (mainLoop);
  GST_DEBUG ("Exited main loop");
  uiDelegate = NULL;
  uiVideoView = NULL;
  g_main_loop_unref (mainLoop);
  mainLoop = NULL;
  
  /* Free resources */
  g_main_context_pop_thread_default(context);
  g_main_context_unref (context);
  gst_element_set_state (receivePipeline, GST_STATE_NULL);
  gst_object_unref (receivePipeline);
  for (NSValue *socketPointer in sharedSocketPointers) {
    GSocket *socket = [socketPointer pointerValue];
    g_socket_close(socket, NULL);
    gst_object_unref(socket);
  }
  [sharedSocketPointers removeAllObjects];
  receivePipeline = NULL;
  outAudioDataPipe = NULL;
  rtpBin = NULL;
  videoDepay = NULL;
  videoDataPipe = NULL;
  audioDepay = NULL;
  micVolume = NULL;
  volume = NULL;

  return;
}

-(Boolean)notifyCustomRTPToStartSendingDataAtHost: (NSString *)host atPort: (int)port toPort: (int)bindPort
{
  GSocket *socket = [self createSocketOnPort: bindPort];
  GError *error = NULL;
  GInetAddress * hostAddress = g_inet_address_new_from_string([host cStringUsingEncoding:NSUTF8StringEncoding]);
  GSocketAddress * destAddress = g_inet_socket_address_new(hostAddress, port);
  g_socket_send_to(socket, destAddress, "Start Data", 10, NULL, &error);
  if (error != NULL) {
    g_error_free(error);
    g_object_unref(socket);
    return false;
  }
  g_object_unref(hostAddress);
  g_object_unref(destAddress);
  g_socket_close(socket, NULL);
  g_object_unref(socket);
  return true;
}

static void closure_cleanup(GstBuffer *buffer, GClosure *closure) {
  gst_buffer_unref(buffer);
}

-(GstElement *)getSRTPDecoderWithKey: (NSData *) key
                            streamId: (unsigned int)streamId
                       sourceElement: (GstElement *)srcElement
                         sinkElement: (GstElement *)sinkElement
                            pipeline: (GstBin *)pipeline
                            linkCaps: (GstCaps *)linkCaps
{
  GstElement *srtpDec = gst_element_factory_make("srtpdec", NULL);
  if (srtpDec){
    gst_bin_add(pipeline, srtpDec);
    GstBuffer *keyBuffer = string_to_buffer(key);
    g_signal_connect_data(srtpDec,
                          "request-key",
                          (GCallback) request_srtp_key,
                          keyBuffer,
                          (GClosureNotify) closure_cleanup,
                          (GConnectFlags) 0
                          );
    GstCaps *srtpCaps = gst_caps_copy(linkCaps);
    gst_structure_set_name(gst_caps_get_structure(srtpCaps, 0), "application/x-srtp");
    gst_caps_set_simple(srtpCaps,
                        "ssrc", G_TYPE_UINT, streamId,
                        NULL);
    g_object_set(srcElement, "caps", srtpCaps, NULL);
    gst_caps_unref(srtpCaps);
    gst_element_link(srcElement, srtpDec);
    if (sinkElement != NULL) {
      gst_element_link(srtpDec, sinkElement);
    }
  } else {
    GST_WARNING("Couldn't construct srtpdec.");
    if (sinkElement != NULL) {
      gst_element_link_filtered(srcElement, sinkElement, linkCaps);
    }
  }
  return srtpDec;
}

-(void)addSrtpEncoderWithKey: (NSData *)key
                    streamId: (unsigned int)streamId
                  srcElement: (GstElement *)srcElement
                 sinkElement: (GstElement *)sinkElement
                    pipeline: (GstBin *)pipeline
                    linkCaps: (GstCaps *)linkCaps {
  GstElement *srtpEnc = gst_element_factory_make("srtpenc", NULL);
  if (srtpEnc) {
    gst_bin_add(pipeline, srtpEnc);
    GstBuffer *keyBuffer = string_to_buffer(key);
    g_object_set(srtpEnc, "key", keyBuffer, NULL);
    gst_buffer_unref(keyBuffer);
    GstCaps *srtpCaps = gst_caps_copy(linkCaps);
    gst_caps_set_simple(srtpCaps, "ssrc", G_TYPE_UINT, streamId, NULL);
    gst_element_link_filtered(srcElement, srtpEnc, srtpCaps);
    gst_caps_unref(srtpCaps);
    gst_element_link(srtpEnc, sinkElement);
  } else {
    GST_WARNING("Couldn't construct srtpEnc: sending audio might not work!");
    gst_element_link_filtered(srcElement, sinkElement, linkCaps);
  }
}

-(void)setVolume: (GstElement *)volume
           level: (double)volumeLevel {
  if (!volume) {
    return;
  }
  g_object_set(volume, "volume", volumeLevel, NULL);
}
@end
#pragma clang diagnostic pop
