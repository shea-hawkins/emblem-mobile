    //
//  LoginViewController.swift
//  Emblem
//
//  Created by Dane Jordan on 8/3/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import SafariServices
    

class LoginViewController: UIViewController, SFSafariViewControllerDelegate, FBSDKLoginButtonDelegate {
    
    var user:User!
    var serverUrl:NSURL?
    let env = NSProcessInfo.processInfo().environment
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        configureFacebook()
//        if FBSDKAccessToken.currentAccessToken() != nil {
//            print("loggedInAlready")
//            self.performSegueWithIdentifier(MapViewController.getEntrySegueFromLogin(), sender:nil )
//        }
        
        
        print("Env variables: \(env["DEV_SERVER"]! as String)")
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        if let server = env["DEV_SERVER"]! as String? {
            self.serverUrl = NSURL(string: server)!
            
        } else {
            self.serverUrl = NSURL(string: "http://138.68.23.39:3000/place")!
        }
        
        let url = NSURL(string: (env["DEV_SERVER/LOGIN"]! as String?)!)
        
        let sfvc = SFSafariViewController(URL: url!, entersReaderIfAvailable: true)
        sfvc.delegate = self
        self.presentViewController(sfvc, animated: true, completion: nil)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!){
        
        
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, email, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error != nil {
                print("FBLogin Error: \(error)")
            } else {
                print("in result", result)
                self.user = User(name: result["first_name"] as! String, email: result["email"] as! String, fbID: result["id"] as! String, imgURL: result["picture"]!["data"]!["url"] as! String)
                print(self.user as User)
                self.performSegueWithIdentifier(MapViewController.getEntrySegueFromLogin(), sender: self.user)
            }
            
            //Result Object Here
            
            //            let strFirstName: String = (result.objectForKey("first_name") as? String)!
            //            let strLastName: String = (result.objectForKey("last_name") as? String)!
            //            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
        }
        
    }
    
//    func configureFacebook(){
//        FBLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
//        FBLoginButton.delegate = self
//    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        print("login complete")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MapViewController.getEntrySegueFromLogin() {
            let dest = segue.destinationViewController as! MapViewController
            if let user = sender as? User {
                dest.user = user
            }
        }
    }
}
