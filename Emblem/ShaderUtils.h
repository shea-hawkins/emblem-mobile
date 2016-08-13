//
//  ShaderUtils.h
//  Emblem
//
//  Created by Humanity on 8/13/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

#ifndef ShaderUtils_h
#define ShaderUtils_h

#import <Foundation/Foundation.h>

@interface ShaderUtils : NSObject

+ (int)createProgramWithVertexShaderFileName:(NSString*) vertexShaderFileName fragmentShaderFileName:(NSString*) fragmentShaderFileName;

+ (int)createProgramWithVertexShaderFileName:(NSString*) vertexShaderFileName withVertexShaderDefs:(NSString*) vertexShaderDefs fragmentShaderFileName:(NSString*) fragmentShaderFileName withFragmentShaderDefs:(NSString*) fragmentShaderDefs;
@end

#endif /* ShaderUtils_h */
