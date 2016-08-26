//
//  ARMenuView.swift
//  Emblem
//
//  Created by Humanity on 8/17/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//
//import UIKit
import SpriteKit

class EventedButton: UIButton {
    var eventName:String? = nil
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}

class ARMenuView: UIView {
    private var upvote: EventedButton!
    private var downvote: EventedButton!
    var events: [String: Array<() -> Void>] = [String: Array<() -> Void>]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let screenWidth:CGFloat = UIScreen.mainScreen().bounds.width
        let screenHeight:CGFloat = UIScreen.mainScreen().bounds.height
        
//        let buttonWidth = screenWidth / 2 - 10
//        let buttonHeight = screenHeight / 8 - 10
        
        let buttonWidth:CGFloat = screenWidth / 2 - 10
        let buttonHeight:CGFloat = 50
        

        let downImage:UIImage = UIImage(named: "down-arrow3.png")!

        downvote = EventedButton(frame: CGRect(x: screenWidth / 4 - buttonWidth / 2, y:(screenHeight - buttonHeight - 2), width: buttonWidth, height: buttonHeight))
        downvote.setImage(downImage, forState: UIControlState.Normal)
        downvote.addTarget(self, action: #selector(ARMenuView.emit(_:)), forControlEvents: .TouchUpInside)
        downvote.eventName = "downvote"
        downvote.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        downvote.layer.backgroundColor = UIColor(red: 17/255, green: 153/255, blue: 158/255, alpha: 1).CGColor
        downvote.layer.cornerRadius = downvote.bounds.height / 2
        downvote.tintColor = .whiteColor()
        downvote.setTitle("Upvote", forState: .Normal)
        
        
        let upImage:UIImage = UIImage(named: "up-arrow3.png")!
        upvote = EventedButton(frame: CGRect(x: screenWidth - (screenWidth / 4 + buttonWidth / 2), y: screenHeight - buttonHeight - 2, width: buttonWidth, height: buttonHeight))
        upvote.setImage(upImage, forState: UIControlState.Normal)
        upvote.addTarget(self, action: #selector(ARMenuView.emit(_:)), forControlEvents: .TouchUpInside)
        upvote.eventName = "upvote"
        upvote.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        upvote.layer.backgroundColor = UIColor(red: 17/255, green: 153/255, blue: 158/255, alpha: 1).CGColor
        upvote.layer.cornerRadius = upvote.bounds.height / 2
        upvote.tintColor = .whiteColor()
        upvote.setTitle("Downvote", forState: .Normal)
        
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
    
    func emit(sender: EventedButton) {
        let eventName = sender.eventName
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
