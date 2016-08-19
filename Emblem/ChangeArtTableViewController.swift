//
//  ChangeArtTableViewController.swift
//  Emblem
//
//  Created by Dane Jordan on 8/12/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChangeArtTableViewController: UITableViewController {
    
    var artIDs = [UInt]()
    var art = [UIImage?]()
    var regionId:Int = 0
    var lat:String!
    var long: String!
    var locationManager = CLLocationManager()
    
    var delegate:ChangeArtTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        let gesture = UISwipeGestureRecognizer(target: self, action: "backPressed")
        gesture.direction = .Right
        self.tableView.addGestureRecognizer(gesture)
        
        //TODO: Save image data locally
        //getRegionId()
        getImageIds()
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
        
        if let backImage:UIImage = UIImage(named: "letter-x.png") {
            let backButton: UIButton = UIButton(type: UIButtonType.Custom)
            backButton.frame = CGRectMake(0, 0, 15, 15)
            backButton.contentMode = UIViewContentMode.ScaleAspectFit
            backButton.setImage(backImage, forState: UIControlState.Normal)
            backButton.addTarget(self, action: Selector("backPressed"), forControlEvents: .TouchUpInside)
//            backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
            let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: backButton)
            
            self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        }
        
        if let addImage:UIImage = UIImage(named: "plus-symbol.png") {
            let addButton: UIButton = UIButton(type: UIButtonType.Custom)
            addButton.frame = CGRectMake(0, 0, 20, 20)
            addButton.contentMode = UIViewContentMode.ScaleAspectFit
            addButton.setImage(addImage, forState: UIControlState.Normal)
            addButton.addTarget(self, action: Selector("addArtPressed"), forControlEvents: .TouchUpInside)
            //            addButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
            let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: addButton)
            
            self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false)
        }

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func backPressed() {
        print("backpressed")
        self.performSegueWithIdentifier(SimpleViewController.getUnwindSegueFromChangeArtView(), sender: nil)
//        self.dismissViewControllerAnimated(false, completion: nil)
        
//         self.navigationController?.popViewControllerAnimated(true)
    }
    
    func getRegionId() {
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "art?lat=\(self.lat)&long=\(self.long)")!
        //get/ post request returns id
        HTTPRequest.get(url) { (response, data) in
            if response.statusCode == 200 {
                let json = JSON(data: data)
                print(json)
                //self.region = json["region"] as! Int
            }
        }
    }
    
    func getImageIds(){
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "\(self.regionId)/art")!
        HTTPRequest.get(url) { (response, data) in
            if response.statusCode == 200 {
                let json = JSON(data: data)
                print(json)
                for (_, obj):(String, JSON) in json {
                    self.artIDs.append(obj["id"].uIntValue)
                    print("IDS: \(self.artIDs.count)")
                    self.art = Array(count: self.artIDs.count, repeatedValue: nil)
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
            //loadingLabel.backgroundColor = UIColor.blackColor()
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
        return self.artIDs.count
    }
    
    class func getEntrySegueFromARViewController() -> String {
        return "ARtoAddArtTableViewControllerSegue"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = self.delegate {
            delegate.receiveArt(self.art[indexPath.row])
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
        self.lat = String(locations.first?.coordinate.latitude)
        self.long = String(locations.first?.coordinate.latitude)
    }
}

extension ChangeArtTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func addArtPressed() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        postImage(image)
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func postImage(image: UIImage) {
        let imageData = UIImagePNGRepresentation(image)!
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "art")!
        HTTPRequest.post(["image": imageData, "imageLength": imageData.length], dataType: "application/octet-stream", url: url) { (succeeded, msg) in
            if succeeded {
                print(msg)
                self.artIDs = Array<UInt>()
                self.getImageIds()
            }
            
        }
    }
}
