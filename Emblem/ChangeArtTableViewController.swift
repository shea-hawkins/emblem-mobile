//
//  ChangeArtTableViewController.swift
//  Emblem
//
//  Created by Dane Jordan on 8/12/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ChangeArtTableViewControllerDelegate {
    func receiveArt(art: NSObject!, artType: ArtType!);
}

class ChangeArtTableViewController: UITableViewController {
    
    var artData = [Dictionary<String,AnyObject>]()
    var art = [UIImage?]()
    var sectorId:Int = 0
    var lat:Double = 0
    var long: Double = 0
    var locationManager = CLLocationManager()
    let MILEINDEGREES = 0.0144
    
    var delegate:ChangeArtTableViewControllerDelegate?
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        let gesture = UISwipeGestureRecognizer(target: self, action: "backPressed")
        gesture.direction = .Right
        self.tableView.addGestureRecognizer(gesture)
        
        //TODO: Save image data locally
        getSectorId()
//        getImageIds()
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
        
        if let backImage:UIImage = UIImage(named: "left-arrow.png") {
            let backButton: UIButton = UIButton(type: UIButtonType.Custom)
            backButton.frame = CGRectMake(0, 0, 15, 15)
            backButton.contentMode = UIViewContentMode.ScaleAspectFit
            backButton.setImage(backImage, forState: UIControlState.Normal)
            backButton.addTarget(self, action: Selector("backPressed"), forControlEvents: .TouchUpInside)
            let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: backButton)
            
            self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        }
    

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func backPressed() {
        print("backpressed")
        self.performSegueWithIdentifier(ARViewController.getUnwindSegueFromChangeArtView(), sender: nil)
    }
    
    func getSectorId() {
        
//        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "place/    find/\(self.lat)/\(self.long)")!
//        HTTPRequest.get(url) { (response, data) in
//            if response.statusCode == 200 {
//                let json = JSON(data: data)
//                print(json)
//                //self.region = json["region"] as! Int
//            }
//        }
        
        //TODO: Remove after testing
        self.sectorId = 1
    }
    
    func getImageIds(){
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "\(self.sectorId)/art")!
        HTTPRequest.get(url) { (response, data) in
            if response.statusCode == 200 || response.statusCode == 304 {
                let json = JSON(data: data)
                print(json)
                for (_, obj):(String, JSON) in json {
                    self.artData.append(obj.dictionaryObject!)
                    self.artData.sortInPlace {
                        item1, item2 in
                        let upvotes1 = item1["upvotes"] as! Int
                        let downvotes1 = item1["downvotes"] as! Int
                        let upvotes2 = item2["upvotes"] as! Int
                        let downvotes2 = item2["downvotes"] as! Int
                        
                        return (upvotes1 - downvotes1) > (upvotes2 - downvotes2)
                    }
                    print("Num IDS: \(self.artData.count)")
                    self.art = Array(count: self.artData.count, repeatedValue: nil)
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var sections = 0
        if (false) {
            print("tableViewLoading")
            let indicatorWidth: CGFloat = 20
            let indicatorHeight: CGFloat = 20
            let yOffset: CGFloat = 60
            let textColor = UIColor.blackColor()
            
            let backgroundView = UIView(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            let loadingIndicator = UIActivityIndicatorView(frame: CGRectMake((self.view.bounds.size.width - indicatorWidth) / 2, (self.view.bounds.size.height - indicatorHeight - yOffset) / 2, indicatorWidth, indicatorHeight))
            
            let loadingLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            
            loadingLabel.text = "Loading Photos..."
            loadingLabel.textColor = textColor
            loadingLabel.numberOfLines = 0
            loadingLabel.textAlignment = .Center
            loadingLabel.font = UIFont(name: "Neuton", size: 17)
            
            
            loadingIndicator.color = UIColor.blackColor()
            loadingIndicator.startAnimating()
            
            backgroundView.addSubview(loadingLabel)
            backgroundView.addSubview(loadingIndicator)
            
            self.tableView.backgroundView = backgroundView
            self.tableView.separatorStyle = .None
        } else{
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .SingleLine
            sections = 1
        }
        return sections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artData.count
    }
    
    class func getEntrySegueFromARViewController() -> String {
        return "ARToChangeArtViewControllerSegue"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = self.delegate {
            delegate.receiveArt(self.art[indexPath.row], artType: .IMAGE)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ArtTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArtTableViewCell
        
        cell.thumbImageView.image = nil


        if let image = self.art[indexPath.row] {
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                let updateCell: ArtTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ArtTableViewCell
                updateCell.thumbImageView.image = image
            })
        } else {
            let urlString = NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "storage/art/\(indexPath.row+1)/\(indexPath.row+1)_FULL"
            let url = NSURL(string: urlString)!
            HTTPRequest.get(url) { (response, data) in
                if response.statusCode == 200 {
                    let image = UIImage(data: data)!
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        self.art[indexPath.row] = image
                        let updateCell: ArtTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ArtTableViewCell
                        updateCell.thumbImageView.image = image
                    })
                }
            }
        }

        return cell
    }
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ChangeArtTableViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLat = Double(locations.first!.coordinate.latitude)
        let newLong = Double(locations.first!.coordinate.longitude)

        if pow((pow((newLat - self.lat), 2) + pow((newLong - self.long), 2)), 0.5) > MILEINDEGREES {
            self.lat = newLat
            self.long = newLong
            print("updating sector...")
            getSectorId()
        }
    }
}