    //
//  LoginViewController.swift
//  Emblem
//
//  Created by Dane Jordan on 8/3/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import SwiftyJSON
    

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, MapViewControllerDelegate {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var logoTitle: UILabel!
    @IBOutlet weak var logoSubTitle: UILabel!
    
    var blurEffect: UIBlurEffect!
    var blurEffectView1:UIVisualEffectView!
    var blurEffectView2:UIVisualEffectView!
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var firstFadeView: UIView!

    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.blurEffectView1.effect = nil
            }) { (true) in
               
                
            UIView.animateWithDuration(1, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.fbLoginButton.alpha = 1
                }, completion: {(true) -> Void in
                    self.blurEffectView1.removeFromSuperview()
                })
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
            blurEffectView1 = UIVisualEffectView(effect: blurEffect)
            blurEffectView1.frame = self.firstFadeView.bounds
            blurEffectView1.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.firstFadeView.addSubview(blurEffectView1)
            
        }
        
        fbLoginButton.alpha = 0
        
        configureFacebook()
        
        if Store.accessToken == "" && FBSDKAccessToken.currentAccessToken() != nil {
            
            
            
                let url = NSURL(string: "\(Store.serverLocation)auth/facebook/token?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)")!
            
                HTTPRequest.get(url, getCompleted: { (response, data) in
                    
                    if response.statusCode == 200 {
                        print("Returned User Token: \(NSString(data: data, encoding: NSUTF8StringEncoding) as! String)")
                        Store.accessToken = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
                        dispatch_async(dispatch_get_main_queue()) {
                            self.performSegueWithIdentifier(MapViewController.getEntrySegueFromLogin(), sender: nil)
                        }
                    } else {
                        print("FB Authentication Falure: \(response)")
                    }
                
                })
            }
        
    }

    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!){
        
        
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, email, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            
            
            if error != nil {
                print("FBLogin Error: \(error)")
            } else {
                
                if Store.accessToken == "" {
                    let url = NSURL(string: "\(Store.serverLocation)auth/facebook/token?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)")!
                    
                    HTTPRequest.get(url, getCompleted: { (response, data) in
                        if response.statusCode == 200 {
                            Store.accessToken = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
                            dispatch_async(dispatch_get_main_queue()) {
                                self.performSegueWithIdentifier(MapViewController.getEntrySegueFromLogin(), sender: nil)
                                
                            }
                        } else {
                            print("FB Authentication Falure: \(response)")
                        }
                    })
                } else {
                      self.performSegueWithIdentifier(MapViewController.getEntrySegueFromLogin(), sender: nil)
                }
                
            }
        }
        
    }
    
    func logout() {
        self.loginButtonDidLogOut(self.fbLoginButton)
    }
    
    func configureFacebook(){
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        fbLoginButton.delegate = self
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MapViewController.getEntrySegueFromLogin() {
            let dest = segue.destinationViewController as! MapViewController
            dest.delegate = self
        }
    }
}
