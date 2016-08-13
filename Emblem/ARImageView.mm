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
#import <Vuforia/Device.h>
#import <Vuforia/State.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/VideoBackgroundConfig.h>

#import "ARImageView.h"
#import "ShaderUtils.h"



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
        renderer = [[Renderer alloc] initWithRendererControl: self];
//        [self loadBuildingsModel];
        [self initShaders];
        
        [renderer initRendering];
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

#pragma mark - UIGLViewProtocol methods


- (void)renderFrameVuforia {
//    if (! vapp.cameraIsStarted) {
//        return;
//    }
    NSLog(@"Render!");
    [renderer renderFrameVuforia];
}

// method should take Vuforia State and projection matrix
- (void) renderFrameWithState {
    [self setFrameBuffer];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //[Renderer renderVideoBackground];
    
    glEnable(GL_DEPTH_TEST);
    
    if (offTargetTrackingEnabled) {
        glDisable(GL_CULL_FACE);
    } else {
        glEnable(GL_CULL_FACE);
    }
    glCullFace(GL_BACK);
    
//    // Vuforia code goes here
//    
//    glUseProgram(shaderProgramID);
//    
//    glEnableVertexAttribArray(vertexHandle);
//    glEnableVertexAttribArray(normalHandle);
//    glEnableVertexAttribArray(textureCoordHandle);
//    
//    // Mesh rendering code
//    
//    glDisableVertexAttribArray(vertexHandle);
//    glDisableVertexAttribArray(normalHandle);
//    glDisableVertexAttribArray(textureCoordHandle);
//    
//    // error check
    [self presentFrameBuffer];
    
}

- (void)createFrameBuffer {
    if (context) {
        glGenFramebuffers(1, &defaultFrameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
        
        // Create colour renderbuffer and allocate backing store
        glGenRenderbuffers(1, &colorRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
        
        // Allocate the renderbuffer's storage (shared with the drawable object)
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
        GLint framebufferWidth;
        GLint framebufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        // Create the depth render buffer and allocate storage
        glGenRenderbuffers(1, &depthRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
        
        // Attach colour and depth render buffers to the frame buffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
        
        // Leave the colour render buffer bound so future rendering operations will act on it
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    }
}

- (void)deleteFrameBuffer {
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFrameBuffer) {
            glDeleteFramebuffers(1, &defaultFrameBuffer);
            defaultFrameBuffer = 0;
        }
        
        if (colorRenderBuffer) {
            glDeleteFramebuffers(1, &colorRenderBuffer);
            colorRenderBuffer = 0;
        }
        
        if (depthRenderBuffer) {
            glDeleteRenderbuffers(1, &depthRenderBuffer);
            depthRenderBuffer = 0;
        }
    }
}

- (void)setFrameBuffer {
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    if (!defaultFrameBuffer) {
        [self performSelectorOnMainThread:@selector(createFrameBuffer) withObject:self waitUntilDone:YES];
    }
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
}

- (BOOL)presentFrameBuffer {
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - OpenGL ES management
- (void)initShaders {
    shaderProgramID = [ShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh" fragmentShaderFileName:@"Simple.fragsh"];
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





