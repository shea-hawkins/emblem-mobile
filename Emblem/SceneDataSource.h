//
//  SceneDataSource.h
//  Emblem
//
//  Created by Humanity on 8/15/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

#ifndef SceneDataSource_h
#define SceneDataSource_h
#import "ImageTargetsEAGLView.h"



@interface SceneDataSource : NSObject <SceneDataSourceProtocol>

- (SCNScene *)sceneForEAGLView:(UIView *)view;

@end

#endif /* SceneDataSource_h */
