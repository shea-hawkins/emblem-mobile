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

protocol MapViewControllerDelegate {
    func logout()
}

class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var socket: SocketIOClient!
    var placeLat:Double = 0
    var placeLong:Double = 0
    var didInitializeCamera = false
    var MILEINDEGREES = 0.0144
    
    var delegate:MapViewControllerDelegate?
    
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
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationServices()

        socket = SocketIOClient(socketURL: NSURL(string: Store.serverLocation)!, options: [.Log(false), .ForcePolling(true)])
        socket.on("connect") {data, ack in
            print("Socket Connected")
        }
        socket.on("place/createPlace") {data, ack in
            if let dataDict = data[0] as? NSDictionary {
                let lat = String(dataDict["lat"]!)
                let long = String(dataDict["long"]!)
                let color = "#fe7569"
                self.createMarker(lat, longitude: long, color: color)
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
        let markerUrl = NSURL(string: Store.serverLocation + "artPlace/between/\(self.placeLat - MILEINDEGREES)/\(self.placeLat + MILEINDEGREES)/\(self.placeLong - MILEINDEGREES)/\(self.placeLong + MILEINDEGREES)")!
        HTTPRequest.get(markerUrl){(response, data) in
            if response.statusCode == 200 {
                let json = JSON(data:data)
                for(_, subJSON):(String, JSON) in json {
                    self.createMarker(subJSON["lat"].stringValue, longitude: subJSON["long"].stringValue, color: subJSON["markerColor"].stringValue)
                }
            }
        }
    }
    
    func createMarker(latitude: String, longitude: String, color: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let markerColor = UIColor().HexToColor(color)
            let marker = GMSMarker()
            guard let lat = CLLocationDegrees(latitude) else {
                return
            }
            guard let long = CLLocationDegrees(longitude) else {
                return
            }
            marker.position = CLLocationCoordinate2DMake(lat, long)
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.icon = GMSMarker.markerImageWithColor(markerColor)
            marker.map = self.mapView
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let delegate = self.delegate {
            delegate.logout()
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
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            HTTPRequest.get(NSURL(string: url)!, getCompleted: {(response, data) in
                let art = JSON(data: data)
                print(art)
                let artId:String = art[0]["ArtId"].stringValue
                if artId != "" {
                    let artType = ResourceHandler.getArtTypeFromExtension(art[0]["type"].stringValue)
                    ResourceHandler.retrieveResource(artId, type: artType, onComplete: {(resource: NSObject) in
                        dispatch_async(dispatch_get_main_queue(), {
                            ARView.receiveArt(resource, artType: artType, artPlaceId: art[0]["ArtPlaceId"].stringValue)
                        })
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        ARView.receiveArt(nil, artType: nil, artPlaceId: nil)
                    })
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

extension UIColor{
    func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: NSScanner = NSScanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersInString: "#")
        // Scan hex value
        scanner.scanHexInt(&hexInt)
        return hexInt
    }
}
