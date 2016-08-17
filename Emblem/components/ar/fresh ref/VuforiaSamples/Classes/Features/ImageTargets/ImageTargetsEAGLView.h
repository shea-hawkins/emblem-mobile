#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <Vuforia/UIGLViewProtocol.h>

#import "SampleApplicationSession.h"

@class VuforiaManager;
@class VuforiaEAGLView;

// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface ImageTargetsEAGLView : UIView <UIGLViewProtocol>

//@property (weak, nonatomic)id<VuforiaEAGLViewSceneSource> sceneSource;
@property (weak, nonatomic)id delegate;
@property (nonatomic, assign)CGFloat objectScale;

- (id)initWithFrame:(CGRect)frame manager:(SampleApplicationSession*) manager;

- (void)setupRenderer;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

- (void)setOffTargetTrackingMode:(BOOL) enabled;
@end