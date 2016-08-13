//
//  GLResourceHandler.h
//  Emblem
//
//  Created by Humanity on 8/13/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

#ifndef GLResourceHandler_h
#define GLResourceHandler_h

@protocol GLResourceHandler

@required
- (void)freeOpenGLESResources;
- (void)finishOpenGLESCommands;

@end

#endif /* GLResourceHandler_h */
