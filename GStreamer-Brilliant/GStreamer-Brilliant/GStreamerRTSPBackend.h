#import <Foundation/Foundation.h>
#import "GStreamerRTSPBackendDelegate.h"
#import <UIKit/UIKit.h>

@interface GStreamerRTSPBackend : NSObject

+(void) gst_ios_init;

/* Initialization method. Pass the delegate that will take care of the UI.
 * This delegate must implement the GStreamerRTSPBackendDelegate protocol.
 * Pass also the UIView object that will hold the video window. */
-(id) init:(id)uiDelegate
 videoView:(UIView*)video_view;

/* Quit the main loop and free all resources, including the pipeline and
 * the references to the ui delegate and the UIView used for rendering, so
 * these objects can be deallocated. */
-(void) deinit;

/* Set the pipeline to PLAYING */
-(void) play;

/* Set the pipeline to PAUSED */
-(void) pause;

/* Set the URI to be played */
-(void) setUri:(NSString*)uri;

/* Set the position to seek to, in milliseconds */
-(void) setPosition:(NSInteger)milliseconds;

@end