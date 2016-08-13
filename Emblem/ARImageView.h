//
//  ARView.h
//  Emblem
//
//  Created by Humanity on 8/12/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

#ifndef ARView_h
#define ARView_h

#import <UIKit/UIKit.h>
#import <Vuforia/UIGLViewProtocol.h>
#import "Renderer.h"

// #define kNumAugmentationTextures 4

@interface ARImageView : UIView {
    EAGLContext* context;
    Renderer* renderer;
    
    GLuint defaultFrameBuffer;
    GLuint colorRenderBuffer;
    GLuint depthRenderBuffer;
    
    GLuint shaderProgramID;
    GLint vertexHandle;
    GLint normalHandle;
    GLint textureCoordHandle;
    GLint mvpMatrixHandle;
    GLint texSampler2DHandle;
    
    // Texture* augmentationTexture[kNumAugmentationTextures;]
    
    BOOL offTargetTrackingEnabled;
    // SampleApplication3DModel* buildingModel;
    // SampleAppRenderer* sampleAppRenderer;
    
}

// @property (nonatomic, weak) SampleApplicationSession* vapp;
// - (id)initWithFrame:(CGRect)frame appSession:

- (void) finishOpenGLESCommands;
- (void) freeOpenGLESResources;

- (void) setOffTargetTrackingMode:(BOOL) enabled;
@end

#endif /* ARView_h */
