/*****************************************************************************
 * GStreamer-Brilliant: Dynamic XCFramework built with system's GStreamer Implementation. Intended for use in Brilliant Mobile App.
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


#ifndef __GST_IOS_INIT_H__
#define __GST_IOS_INIT_H__

#include <gst/gst.h>

G_BEGIN_DECLS

#define GST_G_IO_MODULE_DECLARE(name) \
extern void G_PASTE(g_io_, G_PASTE(name, _load)) (gpointer module)

#define GST_G_IO_MODULE_LOAD(name) \
G_PASTE(g_io_, G_PASTE(name, _load)) (NULL)

/* Uncomment each line to enable the plugin categories that your application needs.
 * You can also enable individual plugins. See gst_ios_init.c to see their names
 */

// Core Plugins:
//#define GST_IOS_PLUGINS_CORE
#define GST_IOS_PLUGIN_COREELEMENTS
#define GST_IOS_PLUGIN_AUDIOCONVERT
#define GST_IOS_PLUGIN_GIO
#define GST_IOS_PLUGIN_OVERLAYCOMPOSITION
#define GST_IOS_PLUGIN_TYPEFINDFUNCTIONS
#define GST_IOS_PLUGIN_VIDEOCONVERT
#define GST_IOS_PLUGIN_AUTODETECT
#define GST_IOS_PLUGIN_AUDIOPARSERS
#define GST_IOS_PLUGIN_VOLUME

// Codecs Plugins:
//#define GST_IOS_PLUGINS_CODECS
//#define GST_IOS_PLUGIN_OPENH264
#define GST_IOS_PLUGIN_VIDEOPARSERSBAD
//#define GST_IOS_PLUGIN_WEBRTCDSP

// Net Plugins:
#define GST_IOS_PLUGINS_NET
#define GST_IOS_PLUGIN_TCP
#define GST_IOS_PLUGIN_RTSP
#define GST_IOS_PLUGIN_RTP
#define GST_IOS_PLUGIN_RTPMANAGER
#define GST_IOS_PLUGIN_SOUP
//#define GST_IOS_PLUGIN_WEBRTC
//#define GST_IOS_PLUGIN_NICE
#define GST_IOS_PLUGIN_RTSPCLIENTSINK

// From PLAYBACK
//#define GST_IOS_PLUGINS_PLAYBACK
#define GST_IOS_PLUGIN_PLAYBACK

// From VIS
//#define GST_IOS_PLUGINS_VIS

// From SYS
//#define GST_IOS_PLUGINS_SYS
#define GST_IOS_PLUGIN_OPENGL
#define GST_IOS_PLUGIN_APPLEMEDIA
#define GST_IOS_PLUGIN_OSXAUDIO
#define GST_IOS_PLUGIN_SHM

// From EFFECTS
//#define GST_IOS_PLUGINS_EFFECTS
#define GST_IOS_PLUGIN_DEBUG
#define GST_IOS_PLUGIN_AUTOCONVERT
//#define GST_IOS_PLUGIN_ALPHACOLOR
//#define GST_IOS_PLUGIN_BAYER


#define GST_IOS_GIO_MODULE_OPENSSL
#define GST_IOS_GIO_MODULE_GNUTLS


void gst_ios_init (void);

G_END_DECLS

#endif
