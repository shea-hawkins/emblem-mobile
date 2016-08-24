//
//  HTTPRequest.swift
//  Emblem
//
//  Created by Dane Jordan on 8/10/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import Foundation
import FBSDKCoreKit

class HTTPRequest {

    
    class func get(url:NSURL, needsToken:Bool, getCompleted: (response: NSHTTPURLResponse, data: NSData) -> ()) {
        var url = url
        
        //TODO: enable without internet access
        if (Store.accessToken != "") {
            if let newUrl = NSURL(string: url.absoluteString + "?access_token=\(Store.accessToken)") {
                url = newUrl
            }
        } else {
            print("No access token")
        }
        
        //TODO: Replace with NSURLRequest
        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithURL(url) {(data, response, error) in
            
            if let httpresponse = response as? NSHTTPURLResponse {
                if error != nil {
                    print("GET Request Error: \(error!)")
                } else {
                    print("GET Server Response: \(httpresponse.statusCode)")
                    print("GET Server URL: \(httpresponse.URL!.absoluteString)")
                    getCompleted(response: httpresponse, data: data!)
                }
            } else {
                print("No Server Response")
            }
        } 
        task.resume()
        
    }
    
    class func post(params: Dictionary<String, AnyObject>, dataType:String, needsToken:Bool, url: NSURL, postCompleted: (succeeded: Bool, msg: String) -> ()){
        var url = url
        if (Store.accessToken != "" && needsToken) {
            if let newUrl = NSURL(string: url.absoluteString + "?access_token=\(Store.accessToken)") {
                url = newUrl
            }
        } else {
            print("No access token")
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(dataType, forHTTPHeaderField: "Content-Type")
        request.addValue(dataType, forHTTPHeaderField: "Accept")
        request.addValue("close", forHTTPHeaderField: "Connection")
        
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
            request.addValue("png", forHTTPHeaderField: "File-Type")
            let imageLength = String(params["imageLength"] as! Int)
            request.addValue(imageLength, forHTTPHeaderField: "Content-Length")
        }


        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if let error = error {
                print(error)
                return
            }
            print("POST URL: \(response?.URL) \r\n POST Response Status Code: \((response as! NSHTTPURLResponse).statusCode)")
            if let resString = NSString(data: data!, encoding: NSUTF8StringEncoding) {
                print("Post Response Body: \(resString)")
            }
            
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