//
//  HTTPRequest.swift
//  Emblem
//
//  Created by Dane Jordan on 8/10/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import Foundation

class HTTPRequest {

    class func get(url:NSURL, getCompleted: (response: NSHTTPURLResponse, data: NSData) -> ()) {
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            
            let httpresponse = response as! NSHTTPURLResponse

            if error != nil {
                print("Get Request Error: \(error!)")
            } else {
                print("Server Response: \(httpresponse))")
                getCompleted(response: httpresponse, data: data!)
            }
        }
        task.resume()
        
    }
    
    class func post(params: Dictionary<String, AnyObject>, dataType:String, url: NSURL, postCompleted: (succeeded: Bool, msg: String) -> ()){
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(dataType, forHTTPHeaderField: "Content-Type")
        request.addValue(dataType, forHTTPHeaderField: "Accept")
        request.addValue("close", forHTTPHeaderField: "Connection")
        request.addValue("png", forHTTPHeaderField: "File-Type")
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = 180.0
        sessionConfig.timeoutIntervalForResource = 180.0
        let session = NSURLSession(configuration: sessionConfig)
        
        if dataType == "application/json" {
            do {
                let json = try NSJSONSerialization.dataWithJSONObject(params, options: [])
                request.HTTPBody = json
            } catch {
                print("HTTPBody set error: \(error)")
            }
        } else if dataType == "application/octet-stream" {
            request.HTTPBody = params["image"] as? NSData
            let imageLength = String(params["imageLength"] as! Int)
            print("imagelenght: \(imageLength)")
            request.addValue(imageLength, forHTTPHeaderField: "Content-Length")
        }


        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if let error = error {
                print(error)
                return
            }
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                print("POST RESPONSE: \(json)")
                if data != nil {
                    postCompleted(succeeded: true, msg: "Post Successful")
                }
            } catch{
                print("JSON POST parse error: \(error)")
            }
        }
        task.resume()
    }
}