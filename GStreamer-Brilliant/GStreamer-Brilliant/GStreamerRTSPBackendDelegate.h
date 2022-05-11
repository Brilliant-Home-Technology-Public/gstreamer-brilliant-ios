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

#import <Foundation/Foundation.h>

@protocol GStreamerRTSPBackendDelegate <NSObject>

@optional
/* Called when the GStreamer RTSP backend has finished initializing
 * and is ready to accept orders. */
-(void) gstreamerRTSPInitialized;

/* Called when the GStreamer backend wants to output some message
 * to the screen. */
-(void) gstreamerRTSPSetUIMessage:(NSString *)message;

/* Called when the media size is first discovered or it changes */
-(void) gstreamerRTSPMediaSizeChanged:(NSInteger)width height:(NSInteger)height;

/* Called when the media position changes. Times in milliseconds */
-(void) gstreamerRTSPSetCurrentPosition:(NSInteger)position duration:(NSInteger)duration;

@end
