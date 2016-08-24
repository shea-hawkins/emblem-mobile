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
    private var upvote: UIButton!
    private var downvote: UIButton!
    var events: [String: Array<() -> Void>] = [String: Array<() -> Void>]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        
        let buttonWidth = screenWidth / 6
        let buttonHeight = screenHeight / 8
        
        
        
        upvote = UIButton(frame: CGRect(x: screenWidth / 3, y: screenHeight - buttonHeight, width: buttonWidth, height: buttonHeight))
        upvote.backgroundColor = .greenColor()
        upvote.setTitle("upvote", forState: .Normal)
        upvote.addTarget(self, action: #selector(ARMenuView.emit(_:)), forControlEvents: .TouchDown)
        
        downvote = UIButton(frame: CGRect(x: screenWidth - (screenWidth / 3), y:screenHeight - buttonHeight, width: buttonWidth, height: buttonHeight))
        downvote.backgroundColor = .redColor()
        downvote.setTitle("downvote", forState: .Normal)
        downvote.addTarget(self, action: #selector(ARMenuView.emit(_:)), forControlEvents: .TouchDown)
        
        
        self.addSubview(upvote)
        self.addSubview(downvote)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func upvoted() {
        self.upvote.enabled = false
        self.downvote.enabled = true
    }
    
    func downvoted() {
        self.upvote.enabled = true
        self.downvote.enabled = false
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
