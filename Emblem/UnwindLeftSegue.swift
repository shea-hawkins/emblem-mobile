//
//  UnwindFromRightSegue.swift
//  Emblem
//
//  Created by Dane Jordan on 8/18/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import QuartzCore

class UnwindFromLeftSegue: UIStoryboardSegue {
    
    override func perform() {
        let src: UIViewController = self.sourceViewController
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        src.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
        src.navigationController?.popViewControllerAnimated(true)
        
    }
}
