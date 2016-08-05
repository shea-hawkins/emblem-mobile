//
//  MapViewController.swift
//  Emblem
//
//  Created by Dane Jordan on 8/4/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit

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
        
        let scriptURL = "http://www.stackoverflow.com"
        let myUrl = NSURL(string: scriptURL)
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(myUrl!) {(data, response, error) in
            print("intask")
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
        }
        task.resume()
        
        
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
//            (data, response, error) in
//            
//            if error != nil {
//                print("error=\(error)")
//                return
//            }
//            
//            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("reponseString: \(responseString)")
//            
//            do {
//                if let convertedJSONIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
//                    print(convertedJSONIntoDict)
//                }
//            }
//        }
        
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
            print("authorized")
            
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
}
