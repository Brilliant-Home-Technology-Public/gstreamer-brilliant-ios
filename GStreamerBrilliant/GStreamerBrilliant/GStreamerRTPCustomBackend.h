#ifndef GStreamerRTPCustomBackend_h
#define GStreamerRTPCustomBackend_h
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

#import <Foundation/Foundation.h>
#import "GStreamerRTPCustomBackendDelegate.h"
#import <UIKit/UIKit.h>

@interface GStreamerRTPCustomBackend : NSObject

/* Initialization method.
 * uiDelegate must implement the GStreamerRTPCustomBackendDelegate protocol.
 * video_view will hold the video window.
 */
-(id)                init:(id)uiDelegate
                videoView:(UIView*)video_view
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

/* Quit the main loop and free all resources, including the pipeline and
 * the references to the ui delegate and the UIView used for rendering, so
 * these objects can be deallocated. */
-(void) deinit;

/* Set the pipeline to PLAYING */
-(void) play;

/* Set the pipeline to PAUSED */
-(void) pause;

/* Set the position to seek to, in milliseconds */
-(void) setPosition:(NSInteger)milliseconds;

-(void) setMute:(BOOL)muted;

-(void) setMicMute:(BOOL)muted;

@end


#endif /* GStreamerRTPCustomBackend_h */
