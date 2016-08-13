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
- (void)loadBuildingsModel;
- (void)createFrameBuffer;
- (void)deleteFrameBuffer;
- (void)setFrameBuffer;
- (BOOL)presentFrameBuffer;
- (EAGLContext*)context;
// SampleApplication3DModel* buildingModel;
// SampleAppRenderer* sampleAppRenderer;
@end

@implementation ARImageView
// @synthesize vapp = vapp;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
//
#pragma Lifecycle
// function that takes in a CGRect frame and
// an appSession
// appSession is a variable that is of type
// sampleapplicationsessionpointer and
// the input variable is an app
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // loads textures and connects to API
        // vapp = app; //application session
//        for (int i = 0; i < kNumAugmentationTextures; i++) {
//            augmentationTexture[i] = [[Texture alloc] initWithImageFile:[NSString stringWithCString:textureFilenames[i] encoding:NSASCIIStringEncoding]];
//                                                                         
//        }
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        // THe EAGLContext must be set for each thread that wishes to use it.
        // on the first call of this view, we set the current context to the
        // previously made context.
        if (context != [EAGLContext currentContext]) {
            [EAGLContext setCurrentContext:context];
        }
        
        // Generate the OpenGL ES texture from the texture files loaded previously
        // upload the texture to openGL
        // and render
//        for (int i = 0; i < kNumAgumentationTextures; ++i) {
//            GLuint textureID;
//            glGenTextures(1, &textureID);
//            [augmentationTexture[i] setTextureID: textureID];
//            glBindTexture(GL_TEXTURE_2D, textureID);
//            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [augmentationTexture[i] width], [augmentationTexture[i] height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*) [augmentationTexture[i] pngData]);
//        }
        // unknown purpose
//        sampleAppRenderer = [[SampleAppRenderer alloc] initWithSampleAppRendererControl: self deviceMode:Vuforia::Device::MODE_AR stereo: false];
//        [self loadBuildingsModel];
        [self initShaders];
    }
    return self;
}

- (void)dealloc
{
    [self deleteFrameBuffer];
    
    // Tear down context
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    // unload textures;
//    for (int i = 0; i < kNumAugmentationTextures; ++i) {
//        augmentationTexture[i] = nil;
//    }
}

- (void)finishOpenGLESCommands
{
    // called when applicationWillResignActive
    // we let actions complete before returning to background
    if (context) {
        [EAGLContext setCurrentContext:context];
        glFinish();
    }
}

- (void)freeOpenGLESResources
{
    // called in response to application entering background
    [self deleteFrameBuffer];
    glFinish();
}

#pragma mark - OpenGL ES management
- (void)initShaders {
//    shaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh" fragmentShaderFileName:@"Simple.fragsh"];
    GLuint shaderProgramID = -10;
    if (0 < shaderProgramID) {
        vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
        normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
        textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
        mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");
        texSampler2DHandle = glGetUniformLocation(shaderProgramID, "texSampler2D");
    } else {
        NSLog(@"Could not initialize augmentation shader");
    }
}

//- (void)loadingBuildingsModel {
//    buildingModel = [[SampleApplication3DModel alloc]
//                     initWithTxtResourceName:@"buildings"];
//    [buildingModel read];
//}

@end





