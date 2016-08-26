//
//  LibraryTableViewController.swift
//  Emblem
//
//  Created by Dane Jordan on 8/18/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit
import SwiftyJSON

class LibraryTableViewController: UITableViewController {

    var artData = [Dictionary<String,AnyObject>]()
    var artPlaceId:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImageIdsForUser()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(LibraryTableViewController.handleSwipeLeft(_:)))
        gesture.direction = .Left
        tableView.addGestureRecognizer(gesture)
        
        if let addImage:UIImage = UIImage(named: "right-arrow.png") {
            let backButton: UIButton = UIButton(type: UIButtonType.Custom)
            backButton.frame = CGRectMake(0, 0, 20, 20)
            backButton.contentMode = UIViewContentMode.ScaleAspectFit
            backButton.setImage(addImage, forState: UIControlState.Normal)
            backButton.addTarget(self, action: #selector(LibraryTableViewController.handleSwipeLeft(_:)), forControlEvents: .TouchUpInside)
            let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: backButton)
            
            self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false)
        }
        
        if let addImage:UIImage = UIImage(named: "plus-symbol.png") {
            let addButton: UIButton = UIButton(type: UIButtonType.Custom)
            addButton.frame = CGRectMake(0, 0, 20, 20)
            addButton.contentMode = UIViewContentMode.ScaleAspectFit
            addButton.setImage(addImage, forState: UIControlState.Normal)
            addButton.addTarget(self, action: #selector(LibraryTableViewController.addArtPressed), forControlEvents: .TouchUpInside)
            let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: addButton)
            
            self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func handleSwipeLeft(recognizer: UISwipeGestureRecognizer) {
        print("swipeLeft")
        self.performSegueWithIdentifier(ARViewController.getUnwindSegueFromLibraryView(), sender: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.artData.count
    }
    
    class func getEntrySegueFromARViewController() -> String {
        return "ARToLibraryViewControllerSegue"
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func getImageIdsForUser(){
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "user/art")!
        HTTPRequest.get(url) { (response, data) in
            if response.statusCode == 200 {
                let json = JSON(data: data)
                for (_, obj):(String, JSON) in json {
                    self.artData.append(obj.dictionaryObject!)
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        self.tableView.reloadData()
                    })
                }
            }
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ArtTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArtTableViewCell
        
        cell.thumbImageView.image = nil
        
        let backgroundLoadingView = Utils.genLoadingScreen(cell.bounds.width, height: cell.bounds.height, loadingText: "Beaming down image ether....")
        cell.contentView.addSubview(backgroundLoadingView)
        
        if let cachedImage = Store.imageCache.objectForKey(artData[indexPath.row]["id"]!) as? UIImage {
            dispatch_async(dispatch_get_main_queue(), {
                let updateCell: ArtTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ArtTableViewCell
                updateCell.thumbImageView.image = cachedImage
                backgroundLoadingView.removeFromSuperview()
            })
        } else {
            let artID = self.artData[indexPath.row]["id"] as! Int
            let urlString = NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "art/\(artID)/download"
            let url = NSURL(string: urlString)!
            HTTPRequest.get(url) { (response, data) in
                if response.statusCode == 200 {
                    let image = UIImage(data: data)!
                    dispatch_async(dispatch_get_main_queue(), {
                        backgroundLoadingView.removeFromSuperview()
                        Store.imageCache.setObject(image, forKey: self.artData[indexPath.row]["id"] as! Int)
                        let updateCell: ArtTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ArtTableViewCell
                        updateCell.thumbImageView.image = image
                    })
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let artID = self.artData[indexPath.row]["id"] as! Int
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "art/\(artID)/place")!
        HTTPRequest.post(["lat": Store.lat, "long": Store.long], dataType: "application/json", url: url) { (succeeded, msg) in
            if succeeded {
                self.artPlaceId = msg["id"].intValue
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.performSegueWithIdentifier(ARViewController.getUnwindSegueFromLibraryView(), sender: indexPath.row)
                })
            }
            
        }
    }



    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ARViewController.getUnwindSegueFromLibraryView() {
            let dest = segue.destinationViewController as! ARViewController
            if sender != nil {
                let artPlaceIdStr = String(self.artPlaceId)
                if let cachedImage = Store.imageCache.objectForKey(self.artData[sender as! Int]["id"]!) as? UIImage{
                    dest.receiveArt(cachedImage, artType: .IMAGE, artPlaceId: artPlaceIdStr)
                } else {
                    print("image no longer in cache")
                }
            }
            
        }
    }


}
extension LibraryTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "art/")!
        
        let loadingScreen = Utils.genLoadingScreen(self.view.bounds.width, height: self.view.bounds.height, loadingText: "Pulsating quasi-data to the cloud....")

        self.view.addSubview(loadingScreen)
        HTTPRequest.post(["image": imageData, "imageLength": imageData.length], dataType: "application/octet-stream", url: url) { (succeeded, msg) in
            if succeeded {
                print(msg)
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    loadingScreen.removeFromSuperview()
                    self.artData = []
                    self.getImageIdsForUser()
                })
            }
            
        }
    }
}

