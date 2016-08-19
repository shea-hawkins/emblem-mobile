//
//  ScrollViewController.swift
//  Emblem
//
//  Created by Dane Jordan on 8/17/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arvc = self.storyboard!.instantiateViewControllerWithIdentifier("ARVC")
        
        self.addChildViewController(arvc)
        self.scrollView.addSubview(arvc.view)
        arvc.didMoveToParentViewController(self)

//        let changeArtVC = ViewControllerTest(nibName: "ViewControllerTest", bundle: nil)
        let changeArtVC = self.storyboard!.instantiateViewControllerWithIdentifier("changeArtVC")
        
        var changeArtFrame = arvc.view.frame
        changeArtFrame.origin.x = self.view.frame.size.width
        changeArtVC.view.frame = changeArtFrame
        
        self.addChildViewController(changeArtVC)
        self.scrollView.addSubview(changeArtVC.view)
        changeArtVC.didMoveToParentViewController(self)
        
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
