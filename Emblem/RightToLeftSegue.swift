//
//  LeftToRightSegue.swift
//  Emblem
//
//  Created by Dane Jordan on 8/17/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class SegueFromRight: UIStoryboardSegue {
    
    override func perform() {
        let src: UIViewController = self.sourceViewController
        let dst: UIViewController = self.destinationViewController
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        src.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
        
    }
    //If not in a navigation controller
    //    override func perform()
    //    {
    //        let src = self.sourceViewController
    //        let dst = self.destinationViewController
    //
    //        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
    //        dst.view.transform = CGAffineTransformMakeTranslation(-src.view.frame.size.width, 0)
    //
    //        UIView.animateWithDuration(0.25,
    //                                   delay: 0.0,
    //                                   options: UIViewAnimationOptions.CurveEaseInOut,
    //                                   animations: {
    //                                    dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
    //            },
    //                                   completion: { finished in
    //                                    src.presentViewController(dst, animated: false, completion: nil)
    //            }
    //        )
    //    }
    
}