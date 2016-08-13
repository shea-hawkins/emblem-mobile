//
//  Renderer.h
//  Emblem
//
//  Created by Humanity on 8/13/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

#ifndef Renderer_h
#define Renderer_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RendererControl
// This method has to be implemented by the Renderer class which handles the content rendering
// of the sample, this one is called from SampleAppRendering class for each view inside a loop
//- (void) renderFrameWithState:(const Vuforia::State&) state projectMatrix:(Vuforia::Matrix44F&) projectionMatrix;
@end

@interface Renderer : NSObject

- (id)initWithRendererControl:(id<RendererControl>) control deviceMode:(Vuforia::Device::MODE) deviceMode stereo:(bool) stereo;
-(void) initRendering;
-(void) renderFrameVuforia;
-(void) renderVideoBackground;


@end
#endif /* Renderer_h */
