//
//  ARMenuView.swift
//  Emblem
//
//  Created by Humanity on 8/17/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//
//import UIKit
import SpriteKit

class ARMenuView: UIView {
    var upvoteNode: SKSpriteNode!
    var downvoteNode: SKSpriteNode!
    var events: [String: Array<() -> Void>] = [String: Array<() -> Void>]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let upvote = UIButton(frame: CGRect(x: 200, y: 400, width:75, height: 75))
        upvote.backgroundColor = .greenColor()
        upvote.setTitle("upvote", forState: .Normal)
        upvote.addTarget(self, action: #selector(ARMenuView.emit(_:)), forControlEvents: .TouchDown)
        
        let downvote = UIButton(frame: CGRect(x: 100, y:400, width: 75, height: 75))
        downvote.backgroundColor = .redColor()
        downvote.setTitle("downvote", forState: .Normal)
        downvote.addTarget(self, action: #selector(ARMenuView.emit(_:)), forControlEvents: .TouchDown)
        
        
        self.addSubview(upvote)
        self.addSubview(downvote)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func emit(sender: UIButton) {
        let eventName = sender.currentTitle
        if let listeners = events[eventName!] {
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
