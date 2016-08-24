//
//  MapViewController.swift
//  Emblem
//
//  Created by Dane Jordan on 8/4/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit
import SwiftyJSON
import SocketIOClientSwift

class MapViewController: UIViewController {
    
    
    var serverUrl:NSURL!
    var user:User?
    let locationManager = CLLocationManager()
    let env = NSProcessInfo.processInfo().environment
    var socket: SocketIOClient!
    var currLat:CLLocation!
    var currLong:CLLocation!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBAction func addMarkerPressed(sender: AnyObject) {
        var lat = ""
        var long = ""
        if let location = mapView.myLocation {
            lat = String(location.coordinate.latitude)
            long = String(location.coordinate.longitude)

        }

        let url = "\(EnvironmentVars.serverLocation)place/find/\(lat)/\(long)"
        
        HTTPRequest.get(NSURL(string: url)!, getCompleted: {(response, data) in
            if response.statusCode == 200 || response.statusCode == 201 {
                let json = JSON(data:data)
                print(json)
                self.performSegueWithIdentifier(ARViewController.getEntrySegueFromMapView(), sender: json["id"].stringValue)
            } else {
                
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let server = env["DEV_SERVER/PLACE"] as String? {
            self.serverUrl = NSURL(string: server)!
            
        } else {
            self.serverUrl = NSURL(string: "http://138.68.23.39:3000/place")!
        }

        initLocationServices()
        
        socket = SocketIOClient(socketURL: self.serverUrl!, options: [.Log(false), .ForcePolling(true)])
        socket.on("connect") {data, ack in
            print("Socket Connected")
        }
        
        socket.on("place/createPlace") {data, ack in

            if let dataDict = data[0] as? NSDictionary {
                let lat = String(dataDict["lat"]!)
                let long = String(dataDict["long"]!)
                self.createMarker(lat, longitude: long)
            }
        }
        
        socket.connect()

        getMarkers(self.serverUrl!)
        
    }
    
    class func getEntrySegueFromLogin() -> String {
        return "LoginToMapViewSegue"
    }
    
    func initLocationServices() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func getMarkers(scriptURL: NSURL) {
        HTTPRequest.get(scriptURL){(response, data) in
            print("GetMarkers: \(response.statusCode)")
            if response.statusCode == 200 {
                let json = JSON(data:data)
                for(_, subJSON):(String, JSON) in json {
                    self.createMarker(subJSON["lat"].stringValue, longitude: subJSON["long"].stringValue)
                }
            }
        }
    }
    
    func createMarker(latitude: String, longitude: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(CLLocationDegrees(latitude)!, CLLocationDegrees(longitude)!)
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = self.mapView
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == ARViewController.getEntrySegueFromMapView()) {
            let placeId = sender as! String
            
            let nav = segue.destinationViewController as! UINavigationController
            let ARView = nav.topViewController as! ARViewController
            let url = "\(EnvironmentVars.serverLocation)place/find/maxArtPlace/\(placeId)"
            
            HTTPRequest.get(NSURL(string: url)!, getCompleted: {(response, data) in
                let art = JSON(data: data)
                print(art)
                if let artid = art[0]["artid"].string {
                    let url = "\(EnvironmentVars.serverLocation)art/\(artid)"
                    HTTPRequest.get(NSURL(string: url)!, getCompleted: { (response, data) in
                        if response.statusCode == 200 {
                            let image = UIImage(data: data)!
                            ARView.receiveArt(image, artType: .IMAGE, artPlaceId: art["artplaceid"].stringValue)
                        }
                    });
                }
            });
        }
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
