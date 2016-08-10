//
//  HTTPRequest.swift
//  Emblem
//
//  Created by Dane Jordan on 8/10/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import Foundation

class HTTPRequest {

    class func get(url:NSURL, getCompleted: (succeeded: Bool, data: NSData) -> ()) {
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            
            if error != nil {
                print("Get Request Error: \(error!)")
            } else {
                getCompleted(succeeded: true, data: data!)
            }
        }
        task.resume()
        
    }
    
    class func post(params: Dictionary<String, String>, url: NSURL, postCompleted: (succeeded: Bool, msg: String) -> ()){
        
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        do {
            
            let json = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            
            request.HTTPBody = json
        } catch {
            print("HTTPBody set error: \(error)")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                print("POST RESPONSE: \(json)")
                let parseJSON = json
                if let success = parseJSON["success"] as? Bool {
                    postCompleted(succeeded: success, msg: "Post Successful")
                    print("Success: \(success)")
                }
            } catch{
                print("JSON POST parse error: \(error)")
            }
        }
        task.resume()
    }
}