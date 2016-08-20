#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>
#import <Vuforia/UIGLViewProtocol.h>

#import "ARManager.h"

@class ARManager;
@class AREAGLView;

@protocol ARSceneSourceProtocol <NSObject>

- (SCNScene *)sceneForEAGLView:(AREAGLView*)view viewInfo:(NSDictionary<NSString*, id>*)viewInfo;

@end

@protocol ARSpriteSourceProtocol <NSObject>

- (SKScene *)sceneForEAGLView:(AREAGLView*)view viewInfo:(NSDictionary<NSString*, id>*)viewInfo;

@end

@interface AREAGLView : UIView <UIGLViewProtocol>

@property (weak, nonatomic)id<ARSceneSourceProtocol> sceneSource;
@property (weak, nonatomic)id<ARSpriteSourceProtocol> spriteSource;
@property (weak, nonatomic)id delegate;
@property (nonatomic, assign)CGFloat objectScale;

- (id)initWithFrame:(CGRect)frame manager:(ARManager *) manager;

- (void)setupRenderer;
- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;
- (void)changeScene:(SCNScene*)scene;


- (void)setOffTargetTrackingMode:(BOOL) enabled;
@end
