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

#include "gst_ios_init.h"
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

GST_DEBUG_CATEGORY_STATIC (debug_category);
#define GST_CAT_DEFAULT debug_category

/* Do not allow seeks to be performed closer than this distance. It is visually useless, and will probably
 * confuse some demuxers. */
#define SEEK_MIN_DELAY (500 * GST_MSECOND)

@interface GStreamerRTSPBackend()
-(void)setUIMessage:(gchar*) message;
-(void)app_function;
-(void)check_initialization_complete;
@end

@implementation GStreamerRTSPBackend {
  id ui_delegate;              /* Class that we use to interact with the user interface */
  GstElement *pipeline;        /* The running pipeline */
  GstElement *video_sink;      /* The video sink element which receives XOverlay commands */
  GstElement *rtsp_src;        /* The rtspSrc element which handles rtsp */
  GMainContext *context;       /* GLib context used to run the main loop */
  GMainLoop *main_loop;        /* GLib main loop */
  gboolean initialized;        /* To avoid informing the UI multiple times about the initialization */
  UIView *ui_video_view;       /* UIView that holds the video */
  GstState state;              /* Current pipeline state */
  GstState target_state;       /* Desired pipeline state, to be set once buffering is complete */
  gint64 duration;             /* Cached clip duration */
  gint64 desired_position;     /* Position to seek to, once the pipeline is running */
  GstClockTime last_seek_time; /* For seeking overflow prevention (throttling) p*/
  gboolean is_live;            /* Live streams do not use buffering */
  GstElement *volume;          /* Volume element for muting and adjusting stream volume */
  NSMutableArray<NSNumber *> *rtsp_signal_ids;
  NSMutableArray<NSNumber *> *bus_signal_ids;
}

+(void)gst_ios_init {
  gst_ios_init();
}

/*
 * Interface methods
 */

-(id) init:(id) uiDelegate videoView:(UIView *)video_view
{
  if (self = [super init])
  {
    self->ui_delegate = uiDelegate;
    self->ui_video_view = video_view;
    self->duration = GST_CLOCK_TIME_NONE;
    
    self->rtsp_signal_ids = [NSMutableArray array];
    self->bus_signal_ids = [NSMutableArray array];
    GST_DEBUG_CATEGORY_INIT (debug_category, "brilliant", 0, "Brilliant-Mobile");
    gst_debug_set_threshold_for_name("brilliant", GST_LEVEL_TRACE);
    /* Start the bus monitoring task */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self app_function];
    });
  }
  
  return self;
}

-(void) deinit
{
  dispatch_async(dispatch_get_main_queue(), ^{
    GST_DEBUG("Quit main loop");
    if (self->main_loop) {
      g_main_loop_quit(self->main_loop);
    }
    GstBus *bus = gst_pipeline_get_bus(GST_PIPELINE (self->pipeline));
    for (NSNumber *bus_signal_id in self->bus_signal_ids) {
      g_signal_handler_disconnect(G_OBJECT(bus), [bus_signal_id unsignedLongValue]);
    }
    [self->bus_signal_ids removeAllObjects];
    for (NSNumber *rtsp_signal_id in self->rtsp_signal_ids) {
      g_signal_handler_disconnect(G_OBJECT(self->rtsp_src), [rtsp_signal_id unsignedLongValue]);
    }
    [self->rtsp_signal_ids removeAllObjects];
  });
}

-(void) play
{
  target_state = GST_STATE_PLAYING;
  is_live = (gst_element_set_state (pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_NO_PREROLL);
}

-(void) pause
{
  target_state = GST_STATE_PAUSED;
  is_live = (gst_element_set_state (pipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_NO_PREROLL);
}

-(void) setUri:(NSString*)uri
{
  GST_DEBUG ("Setting RTSP URL to %s", [uri UTF8String]);
  g_object_set(rtsp_src, "location", [uri UTF8String], NULL);
}

-(void) setPosition:(NSInteger)milliseconds
{
  gint64 position = (gint64)(milliseconds * GST_MSECOND);
  if (state >= GST_STATE_PAUSED) {
    execute_seek(position, self);
  } else {
    GST_DEBUG ("Scheduling seek to %" GST_TIME_FORMAT " for later", GST_TIME_ARGS (position));
    self->desired_position = position;
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
  if(ui_delegate && [ui_delegate respondsToSelector:@selector(gstreamerRTSPSetUIMessage:)])
  {
    [ui_delegate gstreamerRTSPSetUIMessage:string];
  }
}

/* Tell the application what is the current position and clip duration */
-(void) setCurrentUIPosition:(gint)pos duration:(gint)dur
{
  if(ui_delegate && [ui_delegate respondsToSelector:@selector(gstreamerRTSPSetCurrentPosition:duration:)])
  {
    [ui_delegate gstreamerRTSPSetCurrentPosition:pos duration:dur];
  }
}

/* If we have pipeline and it is running, query the current position and clip duration and inform
 * the application */
static gboolean refresh_ui (GStreamerRTSPBackend *self) {
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
static gboolean delayed_seek_cb (GStreamerRTSPBackend *self);

/* Perform seek, if we are not too close to the previous seek. Otherwise, schedule the seek for
 * some time in the future. */
static void execute_seek (gint64 position, GStreamerRTSPBackend *self) {
  gint64 diff;
  
  if (position == GST_CLOCK_TIME_NONE)
    return;
  
  diff = gst_util_get_timestamp () - self->last_seek_time;
  
  if (GST_CLOCK_TIME_IS_VALID (self->last_seek_time) && diff < SEEK_MIN_DELAY) {
    /* The previous seek was too close, delay this one */
    GSource *timeout_source;
    
    if (self->desired_position == GST_CLOCK_TIME_NONE) {
      /* There was no previous seek scheduled. Setup a timer for some time in the future */
      timeout_source = g_timeout_source_new ((SEEK_MIN_DELAY - diff) / GST_MSECOND);
      g_source_set_callback (timeout_source, (GSourceFunc)delayed_seek_cb, (__bridge void *)self, NULL);
      g_source_attach (timeout_source, self->context);
      g_source_unref (timeout_source);
    }
    /* Update the desired seek position. If multiple petitions are received before it is time
     * to perform a seek, only the last one is remembered. */
    self->desired_position = position;
    GST_DEBUG ("Throttling seek to %" GST_TIME_FORMAT ", will be in %" GST_TIME_FORMAT,
               GST_TIME_ARGS (position), GST_TIME_ARGS (SEEK_MIN_DELAY - diff));
  } else {
    /* Perform the seek now */
    GST_DEBUG ("Seeking to %" GST_TIME_FORMAT, GST_TIME_ARGS (position));
    self->last_seek_time = gst_util_get_timestamp ();
    gst_element_seek_simple (self->pipeline, GST_FORMAT_TIME, GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_KEY_UNIT, position);
    self->desired_position = GST_CLOCK_TIME_NONE;
  }
}

/* Delayed seek callback. This gets called by the timer setup in the above function. */
static gboolean delayed_seek_cb (GStreamerRTSPBackend *self) {
  GST_DEBUG ("Doing delayed seek to %" GST_TIME_FORMAT, GST_TIME_ARGS (self->desired_position));
  execute_seek (self->desired_position, self);
  return FALSE;
}

/* Retrieve errors from the bus and show them on the UI */
static void error_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self)
{
  GError *err;
  gchar *debug_info;
  gchar *message_string;
  
  gst_message_parse_error (msg, &err, &debug_info);
  message_string = g_strdup_printf ("Error received from element %s: %s", GST_OBJECT_NAME (msg->src), err->message);
  g_clear_error (&err);
  g_free (debug_info);
  [self setUIMessage:message_string];
  g_free (message_string);
  gst_element_set_state (self->pipeline, GST_STATE_NULL);
}

/* Called when the End Of the Stream is reached. Just move to the beginning of the media and pause. */
static void eos_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self) {
  self->target_state = GST_STATE_PAUSED;
  self->is_live = (gst_element_set_state (self->pipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_NO_PREROLL);
  execute_seek (0, self);
}

/* Called when the duration of the media changes. Just mark it as unknown, so we re-query it in the next UI refresh. */
static void duration_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self) {
  self->duration = GST_CLOCK_TIME_NONE;
}

/* Called when buffering messages are received. We inform the UI about the current buffering level and
 * keep the pipeline paused until 100% buffering is reached. At that point, set the desired state. */
static void buffering_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self) {
  gint percent;
  
  if (self->is_live)
    return;
  
  gst_message_parse_buffering (msg, &percent);
  if (percent < 100 && self->target_state >= GST_STATE_PAUSED) {
    gchar * message_string = g_strdup_printf ("Buffering %d%%", percent);
    gst_element_set_state (self->pipeline, GST_STATE_PAUSED);
    [self setUIMessage:message_string];
    g_free (message_string);
  } else if (self->target_state >= GST_STATE_PLAYING) {
    gst_element_set_state (self->pipeline, GST_STATE_PLAYING);
  } else if (self->target_state >= GST_STATE_PAUSED) {
    [self setUIMessage:"Buffering complete"];
  }
}

/* Called when the clock is lost */
static void clock_lost_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self) {
  if (self->target_state >= GST_STATE_PLAYING) {
    gst_element_set_state (self->pipeline, GST_STATE_PAUSED);
    gst_element_set_state (self->pipeline, GST_STATE_PLAYING);
  }
}

static void on_bus_message (GstBus *bus, GstMessage *message, GStreamerRTSPBackend *self) {
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
static void check_media_size (GStreamerRTSPBackend *self, GstElement * video_sink) {
  GstPad *video_sink_pad;
  GstCaps *caps;
  GstVideoInfo info;
  
  
  /* Do nothing if there is no video sink (this might be an audio-only clip */
  if (!video_sink) return;
  
  video_sink_pad = gst_element_get_static_pad (video_sink, "sink");
  caps = gst_pad_get_current_caps (video_sink_pad);
  
  if (gst_video_info_from_caps (&info, caps)) {
    info.width = info.width * info.par_n / info.par_d;
    GST_DEBUG ("Media size is %dx%d, notifying application", info.width, info.height);
    
    if (self->ui_delegate && [self->ui_delegate respondsToSelector:@selector(gstreamerRTSPMediaSizeChanged:height:)])
    {
      [self->ui_delegate gstreamerRTSPMediaSizeChanged:info.width height:info.height];
    }
  }
  
  gst_caps_unref(caps);
  gst_object_unref (video_sink_pad);
  gst_object_unref(video_sink);
}

/* Notify UI about pipeline state changes */
static void state_changed_cb (GstBus *bus, GstMessage *msg, GStreamerRTSPBackend *self)
{
  GstState old_state, new_state, pending_state;
  gst_message_parse_state_changed (msg, &old_state, &new_state, &pending_state);
  /* Only pay attention to messages coming from the pipeline, not its children */
  if (GST_MESSAGE_SRC (msg) == GST_OBJECT (self->pipeline)) {
    self->state = new_state;
    gchar *message = g_strdup_printf("State changed to %s", gst_element_state_get_name(new_state));
    [self setUIMessage:message];
    g_free (message);
    
    if (old_state == GST_STATE_READY && new_state == GST_STATE_PAUSED)
    {
      check_media_size(self, self->video_sink);
      
      /* If there was a scheduled seek, perform it now that we have moved to the Paused state */
      if (GST_CLOCK_TIME_IS_VALID (self->desired_position))
        execute_seek (self->desired_position, self);
    }
  }
}

/* Check if all conditions are met to report GStreamer as initialized.
 * These conditions will change depending on the application */
-(void) check_initialization_complete
{
  if (!initialized && main_loop) {
    GST_DEBUG ("Initialization complete, notifying application.");
    if (ui_delegate && [ui_delegate respondsToSelector:@selector(gstreamerRTSPInitialized)])
    {
      [ui_delegate gstreamerRTSPInitialized];
    }
    initialized = TRUE;
  }
}

/* Main method for the bus monitoring code */
-(void) app_function
{
  GstBus *bus;
  GSource *timeout_source;
  GSource *bus_source;
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
  rtsp_src = gst_bin_get_by_name(GST_BIN (pipeline), "rtspsrc");
  volume = gst_bin_get_by_name(GST_BIN (pipeline), "vol");
  g_object_set(volume, "mute", FALSE, NULL);

  // Rtsp factory
  g_object_set(rtsp_src, "protocols", 0x4, NULL);
  g_object_set(rtsp_src, "tcp-timeout", (guint64)1000000*15, NULL); // In microseconds
  
  // Set Up Receive Video Pipeline
  
  // Register for messages coming from the pipeline so we can timeout if the pipeline never starts
  bus = gst_pipeline_get_bus(GST_PIPELINE (pipeline));
  gst_bus_enable_sync_message_emission(bus);
  gulong signalId = g_signal_connect(G_OBJECT (bus), "sync-message", (GCallback)on_bus_message, (__bridge void *)self);
  [bus_signal_ids addObject:[NSNumber numberWithUnsignedLong:signalId]];
  gst_object_unref(G_OBJECT (bus));
  
  /* Set the pipeline to READY, so it can already accept a window handle */
  gst_element_set_state(pipeline, GST_STATE_READY);
  
  video_sink = gst_bin_get_by_interface(GST_BIN(pipeline), GST_TYPE_VIDEO_OVERLAY);
  if (!video_sink) {
    GST_ERROR ("Could not retrieve video sink");
    return;
  }
  gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(video_sink), (guintptr) (id) ui_video_view);
  
  /* Instruct the bus to emit signals for each received message, and connect to the interesting signals */
  bus_source = gst_bus_create_watch (bus);
  g_source_set_callback (bus_source, (GSourceFunc) gst_bus_async_signal_func, NULL, NULL);
  g_source_attach (bus_source, context);
  g_source_unref (bus_source);
  gulong errorSignalId = g_signal_connect (G_OBJECT (bus), "message::error", (GCallback)error_cb, (__bridge void *)self);
  [bus_signal_ids addObject:[NSNumber numberWithUnsignedLong:errorSignalId]];
  gulong eosSignalId = g_signal_connect (G_OBJECT (bus), "message::eos", (GCallback)eos_cb, (__bridge void *)self);
  [bus_signal_ids addObject:[NSNumber numberWithUnsignedLong:eosSignalId]];
  gulong stateChangedSignalId = g_signal_connect (G_OBJECT (bus), "message::state-changed", (GCallback)state_changed_cb, (__bridge void *)self);
  [bus_signal_ids addObject:[NSNumber numberWithUnsignedLong:stateChangedSignalId]];
  gulong durationSignalId = g_signal_connect (G_OBJECT (bus), "message::duration", (GCallback)duration_cb, (__bridge void *)self);
  [bus_signal_ids addObject:[NSNumber numberWithUnsignedLong:durationSignalId]];
  gulong bufferingSignalId = g_signal_connect (G_OBJECT (bus), "message::buffering", (GCallback)buffering_cb, (__bridge void *)self);
  [bus_signal_ids addObject:[NSNumber numberWithUnsignedLong:bufferingSignalId]];
  gulong clockLostSignalId = g_signal_connect (G_OBJECT (bus), "message::clock-lost", (GCallback)clock_lost_cb, (__bridge void *)self);
  [bus_signal_ids addObject:[NSNumber numberWithUnsignedLong:clockLostSignalId]];
  gst_object_unref (bus);
  
  /* Register a function that GLib will call 4 times per second */
  timeout_source = g_timeout_source_new (250);
  g_source_set_callback (timeout_source, (GSourceFunc)refresh_ui, (__bridge void *)self, NULL);
  g_source_attach (timeout_source, context);
  g_source_unref (timeout_source);
  
  /* Create a GLib Main Loop and set it to run */
  GST_DEBUG ("Entering main loop...");
  main_loop = g_main_loop_new (context, FALSE);
  [self check_initialization_complete];
  g_main_loop_run (main_loop);
  GST_DEBUG ("Exited main loop");
  ui_delegate = NULL;
  ui_video_view = NULL;
  g_main_loop_unref (main_loop);
  main_loop = NULL;
  
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
