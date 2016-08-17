#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>
#import <Vuforia/UIGLViewProtocol.h>

#import "ARManager.h"

@class ARManager;
@class AREAGLView;

@protocol ARSceneSourceProtocol <NSObject>

- (SCNScene *)sceneForEAGLView:(AREAGLView*)view userInfo:(NSDictionary<NSString*, id>*)userInfo;

@end

@protocol ARSpriteSourceProtocol <NSObject>

- (SKScene *)sceneForEAGLView:(AREAGLView*)view userInfo:(NSDictionary<NSString*, id>*)userInfo;

@end

@interface AREAGLView : UIView <UIGLViewProtocol>

@property (weak, nonatomic)id<ARSceneSourceProtocol> sceneSource;
@property (weak, nonatomic)id<ARSpriteSourceProtocol> spriteSource;
@property (weak, nonatomic)id delegate;
@property (nonatomic, assign)CGFloat objectScale;

- (id)initWithFrame:(CGRect)frame manager:(ARManager *) manager;

- (void)setupRenderer;
- (void)setNeedsChangeSceneWithUserInfo: (NSDictionary*)userInfo;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

- (void)setOffTargetTrackingMode:(BOOL) enabled;
@end
