#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <Vuforia/UIGLViewProtocol.h>

#import "ARManager.h"

@class ARManager;
@class AREAGLView;

@protocol AREAGLViewSceneSource <NSObject>

- (SCNScene *)sceneForEAGLView:(AREAGLView*)view userInfo:(NSDictionary<NSString*, id>*)userInfo;

@end

@protocol AREAGLViewDelegate <NSObject>

//- (void)vuforiaEAGLView:(VuforiaEAGLView*)view didTouchDownNode:(SCNNode *)node;
//- (void)vuforiaEAGLView:(VuforiaEAGLView*)view didTouchUpNode:(SCNNode *)node;
//- (void)vuforiaEAGLView:(VuforiaEAGLView*)view didTouchCancelNode:(SCNNode *)node;

@end


// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface AREAGLView : UIView <UIGLViewProtocol>

@property (weak, nonatomic)id<AREAGLViewSceneSource> sceneSource;
@property (weak, nonatomic)id<AREAGLViewDelegate> delegate;
@property (nonatomic, assign)CGFloat objectScale;

- (id)initWithFrame:(CGRect)frame manager:(ARManager *) manager;

- (void)setupRenderer;
- (void)setNeedsChangeSceneWithUserInfo: (NSDictionary*)userInfo;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

- (void)setOffTargetTrackingMode:(BOOL) enabled;
@end
