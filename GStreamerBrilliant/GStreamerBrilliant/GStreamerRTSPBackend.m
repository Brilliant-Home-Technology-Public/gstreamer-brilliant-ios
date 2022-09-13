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

#import "GStreamerRTSPBackend.h"

#include <gst/gst.h>
#include <gst/video/video.h>
#include <gst/rtsp/gstrtspmessage.h>
#include <gst/rtsp/gstrtspurl.h>
#include <gst/sdp/gstsdpmessage.h>
#include <gio/gio.h>
#include <openssl/evp.h>

#define GST_TYPE_VIDEO_OVERLAY \
(gst_video_overlay_get_type ())

G_BEGIN_DECLS

/* Do not allow seeks to be performed closer than this distance. It is visually useless, and will probably
 * confuse some demuxers. */
#define SEEK_MIN_DELAY (500 * GST_MSECOND)

G_END_DECLS

@interface GStreamerRTSPBackend()
-(void)setUIMessage:(gchar*) message;
-(void)appFunction;
-(void)checkInitializationComplete;
@end

@implementation GStreamerRTSPBackend {
  id uiDelegate;              /* Class that we use to interact with the user interface */
  GstElement *pipeline;        /* The running pipeline */
  GstElement *videoSink;      /* The video sink element which receives XOverlay commands */
  GstElement *rtspSrc;        /* The rtspSrc element which handles rtsp */
  GMainContext *context;       /* GLib context used to run the main loop */
  GMainLoop *mainLoop;        /* GLib main loop */
  gboolean initialized;        /* To avoid informing the UI multiple times about the initialization */
  UIView *uiVideoView;       /* UIView that holds the video */
  GstState state;              /* Current pipeline state */
  GstState targetState;       /* Desired pipeline state, to be set once buffering is complete */
  gint64 duration;             /* Cached clip duration */
  gint64 desiredPosition;     /* Position to seek to, once the pipeline is running */
  GstClockTime lastSeekTime; /* For seeking overflow prevention (throttling) p*/
  gboolean isLive;            /* Live streams do not use buffering */
  GstElement *volume;          /* Volume element for muting and adjusting stream volume */
  NSMutableArray<NSNumber *> *busSignalIds;
}

/*
 * Interface methods
 */

-(id) init:(id) uiDelegate videoView:(UIView *)videoView
{
  if (self = [super init])
  {
    self->uiDelegate = uiDelegate;
    self->uiVideoView = videoView;
    self->duration = GST_CLOCK_TIME_NONE;
    
    self->busSignalIds = [NSMutableArray array];
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
    GstBus *bus = gst_pipeline_get_bus(GST_PIPELINE (self->pipeline));
    for (NSNumber *busSignalId in self->busSignalIds) {
      g_signal_handler_disconnect(G_OBJECT(bus), [busSignalId unsignedLongValue]);
    }
    [self->busSignalIds removeAllObjects];
  });
}

-(void) play
{
  targetState = GST_STATE_PLAYING;
  isLive = (gst_element_set_state (pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_NO_PREROLL);
}

-(void) pause
{
  targetState = GST_STATE_PAUSED;
  isLive = (gst_element_set_state (pipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_NO_PREROLL);
}

-(void) setUri:(NSString*)uri
{
  GST_DEBUG ("Setting RTSP URL to %s", [uri UTF8String]);
  g_object_set(rtspSrc, "location", [uri UTF8String], NULL);
}

-(void) setPosition:(NSInteger)milliseconds
{
  gint64 position = (gint64)(milliseconds * GST_MSECOND);
  if (state >= GST_STATE_PAUSED) {
    execute_seek(position, self);
  } else {
    GST_DEBUG ("Scheduling seek to %" GST_TIME_FORMAT " for later", GST_TIME_ARGS (position));
    self->desiredPosition = position;
  }
}

-(void) setMute:(BOOL)muted
{
  g_object_set(volume, "mute", muted ? TRUE : FALSE, NULL);
}

/*
 * Private methods
 */

/* Change the message on the UI through the UI delegate */
-(void)setUIMessage:(gchar*) message
{
  NSString *string = [NSString stringWithUTF8String:message];
  if(uiDelegate && [uiDelegate respondsToSelector:@selector(gstreamerRTSPSetUIMessage:)])
  {
    [uiDelegate gstreamerRTSPSetUIMessage:string];
  }
}

/* Tell the application what is the current position and clip duration */
-(void) setCurrentUIPosition:(gint)pos duration:(gint)dur
{
  if(uiDelegate && [uiDelegate respondsToSelector:@selector(gstreamerRTSPSetCurrentPosition:duration:)])
  {
    [uiDelegate gstreamerRTSPSetCurrentPosition:pos duration:dur];
  }
}

/* If we have pipeline and it is running, query the current position and clip duration and inform
 * the application */
static gboolean rtsp_refresh_ui (GStreamerRTSPBackend *self) {
  gint64 position;
  /* We do not want to update anything unless we have a working pipeline in the PAUSED or PLAYING state */
  if (!self || !self->pipeline || self->state < GST_STATE_PAUSED)
    return TRUE;
  
  /* If we didn't know it yet, query the stream duration */
  if (!GST_CLOCK_TIME_IS_VALID (self->duration)) {
    gst_element_query_duration (self->pipeline, GST_FORMAT_TIME,&self->duration);
  }
  
  if (gst_element_query_position (self->pipeline, GST_FORMAT_TIME, &position)) {
    /* The UI expects these values in milliseconds, and GStreamer provides nanoseconds */
    [self setCurrentUIPosition:position / GST_MSECOND duration:self->duration / GST_MSECOND];
  }
  return TRUE;
}

/* Forward declaration for the delayed seek callback */
static gboolean rtsp_delayed_seek_cb (GStreamerRTSPBackend *self);

/* Perform seek, if we are not too close to the previous seek. Otherwise, schedule the seek for
 * some time in the future. */
static void execute_seek (gint64 position, GStreamerRTSPBackend *self) {
  gint64 diff;
  
  if (position == GST_CLOCK_TIME_NONE)
    return;
  
  diff = gst_util_get_timestamp () - self->lastSeekTime;
  
  if (GST_CLOCK_TIME_IS_VALID (self->lastSeekTime) && diff < SEEK_MIN_DELAY) {
    /* The previous seek was too close, delay this one */
    GSource *timeoutSource;
    
    if (self->desiredPosition == GST_CLOCK_TIME_NONE) {
      /* There was no previous seek scheduled. Setup a timer for some time in the future */
      timeoutSource = g_timeout_source_new ((SEEK_MIN_DELAY - diff) / GST_MSECOND);
      g_source_set_callback (timeoutSource, (GSourceFunc)rtsp_delayed_seek_cb, (__bridge void *)self, NULL);
      g_source_attach (timeoutSource, self->context);
      g_source_unref (timeoutSource);
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
    gst_element_seek_simple (self->pipeline, GST_FORMAT_TIME, GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_KEY_UNIT, position);
    self->desiredPosition = GST_CLOCK_TIME_NONE;
  }
}

/* Delayed seek callback. This gets called by the timer setup in the above function. */
static gboolean rtsp_delayed_seek_cb (GStreamerRTSPBackend *self) {
  GST_DEBUG ("Doing delayed seek to %" GST_TIME_FORMAT, GST_TIME_ARGS (self->desiredPosition));
  execute_seek (self->desiredPosition, self);
  return FALSE;
}

/* Retrieve errors from the bus and show them on the UI */
static void rtsp_error_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self)
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
  gst_element_set_state (self->pipeline, GST_STATE_NULL);
}

/* Called when the End Of the Stream is reached. Just move to the beginning of the media and pause. */
static void rtsp_eos_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self) {
  self->targetState = GST_STATE_PAUSED;
  self->isLive = (gst_element_set_state (self->pipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_NO_PREROLL);
  execute_seek (0, self);
}

/* Called when the duration of the media changes. Just mark it as unknown, so we re-query it in the next UI refresh. */
static void rtsp_duration_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self) {
  self->duration = GST_CLOCK_TIME_NONE;
}

/* Called when buffering messages are received. We inform the UI about the current buffering level and
 * keep the pipeline paused until 100% buffering is reached. At that point, set the desired state. */
static void rtsp_buffering_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self) {
  gint percent;
  
  if (self->isLive)
    return;
  
  gst_message_parse_buffering (msg, &percent);
  if (percent < 100 && self->targetState >= GST_STATE_PAUSED) {
    gchar * message_string = g_strdup_printf ("Buffering %d%%", percent);
    gst_element_set_state (self->pipeline, GST_STATE_PAUSED);
    [self setUIMessage:message_string];
    g_free (message_string);
  } else if (self->targetState >= GST_STATE_PLAYING) {
    gst_element_set_state (self->pipeline, GST_STATE_PLAYING);
  } else if (self->targetState >= GST_STATE_PAUSED) {
    [self setUIMessage:"Buffering complete"];
  }
}

/* Called when the clock is lost */
static void rtsp_clock_lost_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self) {
  if (self->targetState >= GST_STATE_PLAYING) {
    gst_element_set_state (self->pipeline, GST_STATE_PAUSED);
    gst_element_set_state (self->pipeline, GST_STATE_PLAYING);
  }
}

static void rtsp_on_bus_message (GstBus *bus, GstMessage *message, GStreamerRTSPBackend *self) {
  GstState old_state;
  GstState new_state;
  GError *err = NULL;
  gchar *name, *debug = NULL;
  switch (GST_MESSAGE_TYPE (message)) {
    case GST_MESSAGE_STATE_CHANGED:
      gst_message_parse_state_changed(message, &old_state, &new_state, NULL);
      // If the object does not have a parent then it's the pipeline!
      GstObject *parent = gst_object_get_parent(message->src);
      if (!parent && new_state == GST_STATE_PLAYING) {
        GST_DEBUG("RTSP Receiver: Video has started, stopping timer");
        // Stop a timer...
      }
      if (parent) {
        gst_object_unref(parent);
      }
      break;
    case GST_MESSAGE_ERROR:
      // Start a timer
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
static void rtsp_check_media_size (GStreamerRTSPBackend *self, GstElement * videoSink) {
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
    
    if (self->uiDelegate && [self->uiDelegate respondsToSelector:@selector(gstreamerRTSPMediaSizeChanged:height:)])
    {
      [self->uiDelegate gstreamerRTSPMediaSizeChanged:info.width height:info.height];
    }
  }
}

/* Notify UI about pipeline state changes */
static void rtsp_state_changed_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self)
{
  GstState oldState, newState, pendingState;
  gst_message_parse_state_changed (msg, &oldState, &newState, &pendingState);
  /* Only pay attention to messages coming from the pipeline, not its children */
  if (GST_MESSAGE_SRC (msg) == GST_OBJECT (self->pipeline)) {
    self->state = newState;
    gchar *message = g_strdup_printf("State changed to %s", gst_element_state_get_name(newState));
    [self setUIMessage:message];
    g_free (message);
    
    if (oldState == GST_STATE_READY && newState == GST_STATE_PAUSED)
    {
      rtsp_check_media_size(self, self->videoSink);
      
      /* If there was a scheduled seek, perform it now that we have moved to the Paused state */
      if (GST_CLOCK_TIME_IS_VALID (self->desiredPosition))
        execute_seek (self->desiredPosition, self);
    }
  }
}

/* Check if all conditions are met to report GStreamer as initialized.
 * These conditions will change depending on the application */
-(void) checkInitializationComplete
{
  if (!initialized && mainLoop) {
    GST_DEBUG ("Initialization complete, notifying application.");
    if (uiDelegate && [uiDelegate respondsToSelector:@selector(gstreamerRTSPInitialized)])
    {
      [uiDelegate gstreamerRTSPInitialized];
    }
    initialized = TRUE;
  }
}

/* Main method for the bus monitoring code */
-(void) appFunction
{
  GstBus *bus;
  GSource *timeoutSource;
  GSource *busSource;
  GError *error = NULL;
  
  GST_DEBUG ("Creating pipeline");
  
  /* Create our own GLib Main Context and make it the default one */
  context = g_main_context_new ();
  g_main_context_push_thread_default(context);
  
  /* Build pipeline */
  NSString * parseLaunchString = [NSString stringWithFormat:
                                    @"rtspsrc debug=true name=rtspsrc rtspsrc. ! rtph264depay ! h264parse ! decodebin ! autovideoconvert ! autovideosink rtspsrc. ! decodebin ! audioconvert ! volume name=vol ! autoaudiosink"
  ];
  
  pipeline = gst_parse_launch([parseLaunchString UTF8String], &error);
  if (error) {
    gchar *message = g_strdup_printf("Unable to build pipeline: %s", error->message);
    g_clear_error (&error);
    [self setUIMessage:message];
    g_free (message);
    return;
  }
  rtspSrc = gst_bin_get_by_name(GST_BIN (pipeline), "rtspsrc");
  volume = gst_bin_get_by_name(GST_BIN (pipeline), "vol");
  g_object_set(volume, "mute", true, NULL);

  // Rtsp factory
  g_object_set(rtspSrc, "protocols", 0x4, NULL);
  g_object_set(rtspSrc, "tcp-timeout", (guint64)1000000*15, NULL); // In microseconds
  
  // Set Up Receive Video Pipeline
  
  // Register for messages coming from the pipeline so we can timeout if the pipeline never starts
  bus = gst_pipeline_get_bus(GST_PIPELINE (pipeline));
  gst_bus_enable_sync_message_emission(bus);
  gulong signalId = g_signal_connect(G_OBJECT (bus), "sync-message", (GCallback)rtsp_on_bus_message, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:signalId]];
  
  /* Set the pipeline to READY, so it can already accept a window handle */
  gst_element_set_state(pipeline, GST_STATE_READY);
  
  videoSink = gst_bin_get_by_interface(GST_BIN(pipeline), GST_TYPE_VIDEO_OVERLAY);
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
  gulong errorSignalId = g_signal_connect (G_OBJECT (bus), "message::error", (GCallback)rtsp_error_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:errorSignalId]];
  gulong eosSignalId = g_signal_connect (G_OBJECT (bus), "message::eos", (GCallback)rtsp_eos_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:eosSignalId]];
  gulong stateChangedSignalId = g_signal_connect (G_OBJECT (bus), "message::state-changed", (GCallback)rtsp_state_changed_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:stateChangedSignalId]];
  gulong durationSignalId = g_signal_connect (G_OBJECT (bus), "message::duration", (GCallback)rtsp_duration_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:durationSignalId]];
  gulong bufferingSignalId = g_signal_connect (G_OBJECT (bus), "message::buffering", (GCallback)rtsp_buffering_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:bufferingSignalId]];
  gulong clockLostSignalId = g_signal_connect (G_OBJECT (bus), "message::clock-lost", (GCallback)rtsp_clock_lost_cb, (__bridge void *)self);
  [busSignalIds addObject:[NSNumber numberWithUnsignedLong:clockLostSignalId]];
  gst_object_unref (bus);
  
  /* Register a function that GLib will call 4 times per second */
  timeoutSource = g_timeout_source_new (250);
  g_source_set_callback (timeoutSource, (GSourceFunc)rtsp_refresh_ui, (__bridge void *)self, NULL);
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
  gst_element_set_state (pipeline, GST_STATE_NULL);
  gst_object_unref (pipeline);
  pipeline = NULL;
  
  return;
}

@end
#pragma clang diagnostic pop
