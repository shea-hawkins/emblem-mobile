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
    
    
    var serverUrl:NSURL?
    var user:User?
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBAction func addMarkerPressed(sender: AnyObject) {
        if let location = mapView.myLocation {
            let x = String(location.coordinate.latitude)
            let y = String(location.coordinate.longitude)
            post(["lat": x, "long": y], url: serverUrl!, postCompleted: { (succeeded, msg) in
                print("Post Complete \(msg)")
            })
            
            //TODO: Replace with websockets
            getMarkers(serverUrl!)
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let env = NSProcessInfo.processInfo().environment
        if let server = env["DEV_SERVER"]! as String? {
            self.serverUrl = NSURL(string: server)!
            
        } else {
            self.serverUrl = NSURL(string: "http://138.68.23.39:3000/place")!
        }

        initLocationServices()
        getMarkers(self.serverUrl!)
        
    }
    
    class func getEntrySegueFromLogin() -> String {
        return "MapViewControllerSegue"
    }
    
    func initLocationServices() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func getMarkers(scriptURL: NSURL) {
        get(scriptURL){(succeeded, data) in
            
            if succeeded {
                let json = JSON(data:data)
                print(json)
                dispatch_async(dispatch_get_main_queue()) {
                    for (_, subJson):(String, JSON) in json {
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2DMake(CLLocationDegrees(subJson["lat"].stringValue)!, CLLocationDegrees(subJson["long"].stringValue)!)
                        marker.appearAnimation = kGMSMarkerAnimationPop
                        marker.map = self.mapView
                    }
                    
                }
            }
        }
    }
    
    func get(url:NSURL, getCompleted: (succeeded: Bool, data: NSData) -> ()) {
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            
            if error != nil {
                print("Get Request Error: \(error!)")
            } else {
                getCompleted(succeeded: true, data: data!)
            }
        }
        task.resume()
        
    }
    
    func post(params: Dictionary<String, String>, url: NSURL, postCompleted: (succeeded: Bool, msg: String) -> ()){
        
        let request = NSMutableURLRequest(URL: url)
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
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
        print("resuming location updates")
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()

        }
    }
}
