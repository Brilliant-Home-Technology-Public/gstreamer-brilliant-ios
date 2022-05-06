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
