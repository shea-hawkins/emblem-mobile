//
//  ArtModel.m
//  Emblem
//
//  Created by Humanity on 8/16/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import "ArtNode.h"


@implementation ArtNode {
    SCNNode* _node;
}

- (instancetype)init {
    if (self = [super init]) {
        
        /// Load character from external file
        
        _node = [SCNNode node];
        SCNScene *characterScene = [SCNScene sceneNamed:@"enemy.scn"];
        SCNNode *characterTopLevelNode = characterScene.rootNode.childNodes[0];
        [_node addChildNode:characterTopLevelNode];
        
    }
    return self;
}

-(SCNNode*)node {
    return _node;
}

@end
