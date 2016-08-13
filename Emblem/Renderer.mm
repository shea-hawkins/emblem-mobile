//
//  Renderer.m
//  Emblem
//
//  Created by Humanity on 8/13/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <UIKit/UIKit.h>

#import <Vuforia/Device.h>
#import <Vuforia/State.h>
#import <Vuforia/UIGLViewProtocol.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/CameraDevice.h>
#import <Vuforia/Vuforia.h>
#import <Vuforia/TrackerManager.h>
#import <Vuforia/Tool.h>
#import <Vuforia/ObjectTracker.h>
#import <Vuforia/RotationalDeviceTracker.h>
#import <Vuforia/StateUpdater.h>
#import <Vuforia/GLRenderer.h>

//#import "Texture.h"
//#import "SampleApplicationUtils.h"
#import "Renderer.h"
#import "ShaderUtils.h"

@interface Renderer ()

@property (nonatomic, readwrite) Vuforia::Device::MODE deviceMode;
@property (nonatomic, readwrite) bool stereo;

@property (nonatomic, assign) id control;

@property (nonatomic, readwrite) GLuint vbShaderProgramID;
@property (nonatomic, readwrite) GLint vbVertexHandle;
@property (nonatomic, readwrite) GLint vbTexCoordHandle;
@property (nonatomic, readwrite) GLint vbTexSampler2DHandle;
@property (nonatomic, readwrite) GLint vbProjectionMatrixHandle;
@property (nonatomic, readwrite) CGFloat nearPlane;
@property (nonatomic, readwrite) CGFloat farPlane;
@property (nonatomic, readwrite) Vuforia::VIEW currentView;

@end

@implementation Renderer

- (id)initWithRendererControl:(id<RendererControl>) control deviceMode:(Vuforia::Device::MODE) deviceMode stereo:(bool) stereo {
    self = [super init];
    if (self) {
        self.control = control;
        self.stereo = stereo;
        self.deviceMode = deviceMode;
        self.nearPlane = 50.0f;
        self.farPlane = 5000.0f;
        
//        Vuforia::Device& device = Vuforia::Device::getInstance();
//        if (!device.setMode(self.deviceMode)) {
//            NSLog(@"ERROR: failed to set device mode");
//        }
//        device.setViewerActive(self.stereo);
    }
    return self;
}

- (void) initRenderering {
    // video background rendering
    self.vbShaderProgramID = [ShaderUtils createProgramWithVertexShaderFileName:@"Background.vertsh" fragmentShaderFileName:@"Background.frag.sh"];
    
    if (0 < self.vbShaderProgramID) {
        self.vbVertexHandle = glGetAttribLocation(self.vbShaderProgramID, "vertexPosition");
        self.vbTexCoordHandle = glGetAttribLocation(self.vbShaderProgramID, "vertexTexCoord");
        self.vbProjectionMatrixHandle = glGetAttribLocation(self.vbShaderProgramID, "texSampler2D");
    }
    else {
        NSLog(@"Could not initialise video background shader");
    }
}

@end

