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
    func receiveArt(art: NSObject!, artType: ArtType!, artPlaceId: String!);
}

class ChangeArtTableViewController: UITableViewController {
    
    var artData = [Dictionary<String,AnyObject>]()
    var sector:String!
    var lat:Double!
    var long:Double!

    
    var delegate:ChangeArtTableViewControllerDelegate?
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(backPressed))
        gesture.direction = .Right
        self.tableView.addGestureRecognizer(gesture)
        
        //TODO: Save image data locally
//
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
        
        if let backImage:UIImage = UIImage(named: "left-arrow.png") {
            let backButton: UIButton = UIButton(type: UIButtonType.Custom)
            backButton.frame = CGRectMake(0, 0, 15, 15)
            backButton.contentMode = UIViewContentMode.ScaleAspectFit
            backButton.setImage(backImage, forState: UIControlState.Normal)
            backButton.addTarget(self, action: #selector(backPressed), forControlEvents: .TouchUpInside)
            let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: backButton)
            
            self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        }
        
        getImageIds()
    

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func backPressed() {
        print("backpressed")
        self.performSegueWithIdentifier(ARViewController.getUnwindSegueFromChangeArtView(), sender: nil)
    }
    
    func getImageIds(){
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "place/find/artPlace/\(Store.lat)/\(Store.long)")!
        HTTPRequest.get(url) { (response, data) in
            if response.statusCode == 200 || response.statusCode == 304 {
                let json = JSON(data: data)
                print(json)
                for (_, obj):(String, JSON) in json {
                    self.artData.append(obj.dictionaryObject!)
                    self.artData.sortInPlace {
                        item1, item2 in
                        let netvotes1 = item1["netVotes"] as! Int
                        let netvotes2 = item2["netVotes"] as! Int
                        
                        return netvotes1 > netvotes2
                    }
                    print("Num IDS: \(self.artData.count)")
                    self.tableView.reloadData()
                }
                
                if self.artData.count == 0 {
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        let alert = UIAlertController(title: "Well look at that!", message: "No art has been posted to this location!", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok!", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artData.count
    }
    
    class func getEntrySegueFromARViewController() -> String {
        return "ARToChangeArtViewControllerSegue"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if let delegate = self.delegate {
//            delegate.receiveArt(self.art[indexPath.row], artType: .IMAGE)
//        }
        self.performSegueWithIdentifier(ARViewController.getUnwindSegueFromChangeArtView(), sender: indexPath.row)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ArtTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArtTableViewCell
        
        cell.thumbImageView.image = nil
        
        let backgroundLoadingView = Utils.genLoadingScreen(cell.bounds.width, height: cell.bounds.height, loadingText: "Teleporting Image....")
        cell.contentView.addSubview(backgroundLoadingView)
        
        if let cachedObj = Store.imageCache.objectForKey(artData[indexPath.row]["ArtId"] as! Int) as? NSDictionary {
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                let updateCell: ArtTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ArtTableViewCell
                updateCell.thumbImageView.image = cachedObj["image"] as? UIImage
                updateCell.upvoteLabel.text = cachedObj["upvotes"] as? String
                updateCell.upvoteLabel.text = cachedObj["downvotes"] as? String
                backgroundLoadingView.removeFromSuperview()
            })
        } else {
            let urlString = NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "art/\(artData[indexPath.row]["ArtId"] as! Int)/download"
            let url = NSURL(string: urlString)!
            
            
            HTTPRequest.get(url) { (response, data) in
                if response.statusCode == 200 {
                    let image = UIImage(data: data)!
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        let upvotes = String(self.artData[indexPath.row]["upvotes"]! as! Int)
                        let downvotes = String(self.artData[indexPath.row]["downvotes"]! as! Int)
                        Store.imageCache.setObject(["image":image, "upvotes":upvotes, "downvotes":downvotes], forKey: self.artData[indexPath.row]["ArtId"] as! Int)
                        backgroundLoadingView.removeFromSuperview()
                        let updateCell: ArtTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ArtTableViewCell
                        updateCell.thumbImageView.image = image
                        updateCell.upvoteLabel.text = upvotes
                        updateCell.downvoteLabel.text = downvotes
                        print("-------------Upvotes \(upvotes)")
                        print("-------------Downvotes \(downvotes)")
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ARViewController.getUnwindSegueFromChangeArtView() {
            let dest = segue.destinationViewController as! ARViewController
            if sender != nil {
                if let cachedImage = Store.imageCache.objectForKey(self.artData[sender as! Int]["id"]!) as? UIImage {
                    dest.receiveArt(cachedImage, artType: .IMAGE, artPlaceId: String(self.artData[sender as! Int]["ArtPlaceId"]))
                } else {
                    print("Cached Image no longer available")
                }
                
            }
            
        }
    }
 

}
