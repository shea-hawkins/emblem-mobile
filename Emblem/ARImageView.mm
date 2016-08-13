//
//  ARView.m
//  Emblem
//
//  Created by Humanity on 8/12/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <sys/time.h>

#import <Vuforia/Vuforia.h>
#import <Vuforia/State.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/VideoBackgroundConfig.h>

#import "ARImageView.h"


// Here is where we define the private methods of this class
@interface ARImageView (PrivateMethods)
- (void)initShaders;
- (void)createFrameBuffer;
- (void)deleteFrameBuffer;
- (void)setFrameBuffer;
- (BOOL)presentFrameBuffer;
@end

@implementation ARImageView
// @synthesize vapp = vapp;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
//
//#pragma Lifecycle
//- (id)initWithFrame:(CGRect)frame appSession:

@end





