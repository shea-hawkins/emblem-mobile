//
//  MapViewController.swift
//  Emblem
//
//  Created by Dane Jordan on 8/4/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit
import SwiftyJSON

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(37.7836883,-122.4111727)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView
        
        let scriptURL = "http://138.68.23.39:3000/place"
        let myUrl = NSURL(string: scriptURL)
        
        //        post(["lat": "3", "long": "3"], url: "http://138.68.23.39:3000/place"){(suceeded, msg) in
        //
        //        }
        
        get(scriptURL){(succeeded, data) in
            
            if succeeded {
                let json = JSON(data:data)
                print(json)
                dispatch_async(dispatch_get_main_queue()) {
                    for (key, subJson):(String, JSON) in json {
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2DMake(CLLocationDegrees(subJson["long"].stringValue)!, CLLocationDegrees(subJson["lat"].stringValue)!)
                        marker.appearAnimation = kGMSMarkerAnimationPop
                        marker.map = self.mapView
                    }
                    
                }
            }
        }
    }
    
    
    func get(urlStr:String, getCompleted: (succeeded: Bool, data: NSData) -> ()) {
        
        let myUrl = NSURL(string: urlStr)
        let task = NSURLSession.sharedSession().dataTaskWithURL(myUrl!) {(data, response, error) in
            
            if error != nil {
                print("Get Request Error: \(error!)")
            } else {
                getCompleted(succeeded: true, data: data!)
            }
        }
        task.resume()
        
    }
    
    func post(params: Dictionary<String, String>, url: String, postCompleted: (succeeded: Bool, msg: String) -> ()){
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        do {
            
            let json = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            print(json.dynamicType)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            print("location authorized")
            
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
}
