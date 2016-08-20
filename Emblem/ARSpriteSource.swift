//
//  ARMenuView.swift
//  Emblem
//
//  Created by Humanity on 8/17/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//
//import UIKit
import SpriteKit

class MenuSpriteScene: SKScene {
    var upvoteNode: SKSpriteNode!
    var downvoteNode: SKSpriteNode!
    var events: [String: Array<() -> Void>] = [String: Array<() -> Void>]()
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let location = touch?.locationInNode(self)
        if self.upvoteNode.containsPoint(location!) {
            self.emit("upvote")
        }
        
        if self.downvoteNode.containsPoint(location!) {
            self.emit("downvote")
        }
    }
    
    func emit(eventName: String) {
        if let listeners = events[eventName] {
            listeners.forEach({(body) -> Void in
                body()
            });
        }
    }
    
    func on(eventName: String, callback: () -> Void) {
        if var eventArray = events[eventName] {
            eventArray.append(callback)
        } else {
            events[eventName] = [callback]
        }
    }
}
