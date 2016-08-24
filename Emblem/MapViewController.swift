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
    var placeLat:Double = 0
    var placeLong:Double = 0
    var didInitializeCamera = false
    var MILEINDEGREES = 0.0144
    
    @IBOutlet weak var artButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBAction func addMarkerPressed(sender: AnyObject) {
        var lat = ""
        var long = ""
        if let location = mapView.myLocation {
            lat = String(location.coordinate.latitude)
            long = String(location.coordinate.longitude)

        }

        let url = "\(Store.serverLocation)place/find/\(lat)/\(long)"
        
        HTTPRequest.get(NSURL(string: url)!, getCompleted: {(response, data) in
            if response.statusCode == 200 || response.statusCode == 201 {
                let json = JSON(data:data)
                print(json)
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.performSegueWithIdentifier(ARViewController.getEntrySegueFromMapView(), sender: json["id"].stringValue)
                })
            } else {
                
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let server = env["DEV_SERVER"]! + "place" as String? {
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
        self.artButton.layer.backgroundColor = UIColor(red: 17/255, green: 153/255, blue: 158/255, alpha: 1).CGColor
        self.artButton.layer.cornerRadius = self.artButton.bounds.height / 2
        self.artButton.tintColor = .whiteColor()
        
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
    
    func getMarkers() {
        let markerUrl = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "artPlace/between/\(self.placeLat - MILEINDEGREES)/\(self.placeLat + MILEINDEGREES)/\(self.placeLong - MILEINDEGREES)/\(self.placeLong + MILEINDEGREES)")!
        HTTPRequest.get(markerUrl){(response, data) in
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
            guard let lat = CLLocationDegrees(latitude) else {
                return
            }
            guard let long = CLLocationDegrees(longitude) else {
                return
            }
            marker.position = CLLocationCoordinate2DMake(lat, long)
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
//            ARView.locationManager = locationManager
            let url = "\(Store.serverLocation)place/find/maxArtPlace/\(placeId)"
            
            HTTPRequest.get(NSURL(string: url)!, getCompleted: {(response, data) in
                let art = JSON(data: data)
                print(art)
                if let artid = art[0]["artid"].string {
                    let url = "\(Store.serverLocation)art/\(artid)/download"
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
            if !didInitializeCamera {
                didInitializeCamera = true
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

            }
            let newLat = Double(location.coordinate.latitude)
            let newLong = Double(location.coordinate.longitude)
            let distDiff = pow((pow((newLat - self.placeLat), 2) + pow((newLong - self.placeLong), 2)), 0.5)
            
            if distDiff > MILEINDEGREES {
                self.placeLat = newLat
                self.placeLong = newLong
                print("updating sector...")
                getMarkers()
            }
        }
    }
}
