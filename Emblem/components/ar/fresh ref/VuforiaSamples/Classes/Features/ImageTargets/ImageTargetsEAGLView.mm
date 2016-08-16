/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

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

#import <SceneKit/SceneKit.h>

#import "ImageTargetsEAGLView.h"
#import "SampleApplicationUtils.h"


//******************************************************************************
// *** OpenGL ES thread safety ***
//
// OpenGL ES on iOS is not thread safe.  We ensure thread safety by following
// this procedure:
// 1) Create the OpenGL ES context on the main thread.
// 2) Start the Vuforia camera, which causes Vuforia to locate our EAGLView and start
//    the render thread.
// 3) Vuforia calls our renderFrameVuforia method periodically on the render thread.
//    The first time this happens, the defaultFramebuffer does not exist, so it
//    is created with a call to createFramebuffer.  createFramebuffer is called
//    on the main thread in order to safely allocate the OpenGL ES storage,
//    which is shared with the drawable layer.  The render (background) thread
//    is blocked during the call to createFramebuffer, thus ensuring no
//    concurrent use of the OpenGL ES context.
//
//******************************************************************************


namespace {

    const float kObjectScaleNormal = 3.0f;
    const float kObjectScaleOffTargetTracking = 12.0f;
    const float kObjectScale = 3.0f;
}

@interface ImageTargetsEAGLView ()
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;

@property (nonatomic, readwrite) UIInterfaceOrientation mARViewOrientation;

@end



@implementation ImageTargetsEAGLView

@synthesize vapp = vapp;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

#pragma mark - Matrix Utils

- (SCNMatrix4)VuMatrix44ToSCNMatrix4:(Vuforia::Matrix44F)matrix {
    GLKMatrix4 glkMatrix;
    
    for (int i =0; i<16; i++) {
        glkMatrix.m[i] = matrix.data[i];
    }
    
    return SCNMatrix4FromGLKMatrix4(glkMatrix);
}


- (void)setCameraMatrix:(Vuforia::Matrix44F)matrix {
    SCNMatrix4 extrinsic = [self VuMatrix44ToSCNMatrix4:matrix];
    SCNMatrix4 inverted = SCNMatrix4Invert(extrinsic);
    self.cameraNode.transform = inverted;
}

- (void)setProjectionMatrix:(Vuforia::Matrix44F)matrix {
    self.cameraNode.camera.projectionTransform = [self VuMatrix44ToSCNMatrix4:matrix];
}

#pragma mark - Scene Stuff
- (SCNScene*)createScene {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    self.scene = [SCNScene new];
    
    SCNNode* planeNode = [SCNNode new];
    planeNode.name = @"plane";
    
    SCNPlane* planeGeometry = [SCNPlane new];
    
    planeGeometry.width = 247.0;
    planeGeometry.height = 173.0;
    
    planeNode.geometry = planeGeometry;
    planeNode.position = SCNVector3Make(0, 0, -1);
    
    SCNMaterial* planeMaterial = [SCNMaterial new];
    planeMaterial.diffuse.contents = color;
    planeMaterial.transparency = 10;
    
    planeNode.geometry.firstMaterial = planeMaterial;
    [self.scene.rootNode addChildNode:planeNode];
    
    SCNNode* boxNode = [SCNNode new];
    boxNode.name = @"box";
    
    SCNBox* boxGeometry = [SCNBox new];
    
    boxGeometry.width = 1;
    boxGeometry.height = 1;
    boxGeometry.length = 1;
    boxGeometry.chamferRadius = 0.0;
    
    SCNMaterial* boxMaterial = [SCNMaterial new];
    boxMaterial.diffuse.contents = color;
    
    
    boxNode.geometry = boxGeometry;
    boxNode.geometry.firstMaterial = boxMaterial;
    
    
    [self.scene.rootNode addChildNode:planeNode];
    
    return self.scene;
}


//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame appSession:(SampleApplicationSession *) app
{
    self = [super initWithFrame:frame];
    
    if (self) {
        vapp = app;
        
        // Enable retina mode if available on this device
        if (YES == [vapp isRetinaDisplay]) {
            [self setContentScaleFactor:[UIScreen mainScreen].nativeScale];
        }

        // Create the OpenGL ES context
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        // The EAGLContext must be set for each thread that wishes to use it.
        // Set it the first time this method is called (on the main thread)
        if (context != [EAGLContext currentContext]) {
            [EAGLContext setCurrentContext:context];
        }
        
        [self createScene];
        [self setupRenderer];
    }
    
    return self;
}

-(void)setupRenderer {
    self.renderer = [SCNRenderer rendererWithContext: context options: nil];
    self.renderer.autoenablesDefaultLighting = YES;
    self.renderer.playing = YES;
    
    
    if (self.scene != nil) {
        self.renderer.scene = self.scene;
        SCNCamera* camera = [SCNCamera camera];

        self.cameraNode.camera = camera;
        [self.renderer.scene.rootNode addChildNode:self.cameraNode];
        self.renderer.pointOfView = self.cameraNode;
    }
}



- (void)dealloc
{
    [self deleteFramebuffer];
    
    // Tear down context
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
}


- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  The render loop has
    // been stopped, so we now make sure all OpenGL ES commands complete before
    // we (potentially) go into the background
    if (context) {
        [EAGLContext setCurrentContext:context];
        glFinish();
    }
}


- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Free easily
    // recreated OpenGL ES resources
    [self deleteFramebuffer];
    glFinish();
}

- (void) setOffTargetTrackingMode:(BOOL) enabled {
    offTargetTrackingEnabled = enabled;
}


//------------------------------------------------------------------------------
#pragma mark - UIGLViewProtocol methods

// Draw the current frame using OpenGL
//
// This method is called by Vuforia when it wishes to render the current frame to
// the screen.
//
// *** Vuforia will call this method periodically on a background thread ***
- (void)renderFrameVuforia
{
    [self setFramebuffer];
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render video background and retrieve tracking state
    Vuforia::State state = Vuforia::Renderer::getInstance().begin();
    Vuforia::Renderer::getInstance().drawVideoBackground();
    
    glEnable(GL_DEPTH_TEST);
    // We must detect if background reflection is active and adjust the culling direction.
    // If the reflection is active, this means the pose matrix has been reflected as well,
    // therefore standard counter clockwise face culling will result in "inside out" models.
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    if(Vuforia::Renderer::getInstance().getVideoBackgroundConfig().mReflection == Vuforia::VIDEO_BACKGROUND_REFLECTION_ON)
        glFrontFace(GL_CW);  //Front camera
    else
        glFrontFace(GL_CCW);   //Back camera
    
    // Set the viewport
    glViewport(vapp.viewport.posX, vapp.viewport.posY, vapp.viewport.sizeX, vapp.viewport.sizeY);
    
    // Render the RefFree UI elements depending on the current state
    //refFreeFrame->render();
    
    [self setProjectionMatrix:vapp.projectionMatrix];
    
    for (int i = 0; i < state.getNumTrackableResults(); ++i) {
        // Get the trackable
        const Vuforia::TrackableResult* result = state.getTrackableResult(i);
        //const Vuforia::Trackable& trackable = result->getTrackable();
        Vuforia::Matrix44F modelViewMatrix = Vuforia::Tool::convertPose2GLMatrix(result->getPose());
        
        SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScale, &modelViewMatrix.data[0]);
        SampleApplicationUtils::scalePoseMatrix(kObjectScale, kObjectScale, kObjectScale, &modelViewMatrix.data[0]);
        
        
        [self setCameraMatrix:modelViewMatrix];
        [self.renderer renderAtTime:CFAbsoluteTimeGetCurrent() - self.startTime];
        
        SampleApplicationUtils::checkGlError("EAGLView renderFrameVuforia");
    }
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    Vuforia::Renderer::getInstance().end();
    [self presentFramebuffer];
}


//------------------------------------------------------------------------------
#pragma mark - OpenGL ES management

- (void)createFramebuffer
{
    if (context) {
        // Create default framebuffer object
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create colour renderbuffer and allocate backing store
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        // Allocate the renderbuffer's storage (shared with the drawable object)
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
        GLint framebufferWidth;
        GLint framebufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        // Create the depth render buffer and allocate storage
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
        
        // Attach colour and depth render buffers to the frame buffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        // Leave the colour render buffer bound so future rendering operations will act on it
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    }
}


- (void)deleteFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer) {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}


- (void)setFramebuffer
{
    // The EAGLContext must be set for each thread that wishes to use it.  Set
    // it the first time this method is called (on the render thread)
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    if (!defaultFramebuffer) {
        // Perform on the main thread to ensure safe memory allocation for the
        // shared buffer.  Block until the operation is complete to prevent
        // simultaneous access to the OpenGL context
        [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
}


- (BOOL)presentFramebuffer
{
    // setFramebuffer must have been called before presentFramebuffer, therefore
    // we know the context is valid and has been set for this (render) thread
    
    // Bind the colour render buffer and present it
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}



@end
