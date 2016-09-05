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
        getImageIds()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(backPressed))
        gesture.direction = .Right
        self.tableView.addGestureRecognizer(gesture)
        self.clearsSelectionOnViewWillAppear = false
        if let backImage:UIImage = UIImage(named: "left-arrow.png") {
            let backButton: UIButton = UIButton(type: UIButtonType.Custom)
            backButton.frame = CGRectMake(0, 0, 20, 20)
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
        let url = NSURL(string: "\(Store.serverLocation)place/find/artPlace/\(Store.lat)/\(Store.long)")!
        HTTPRequest.get(url) { (response, data) in
            if response.statusCode == 200 || response.statusCode == 304 {
                let json = JSON(data: data)
                print(json)
                self.artData = [Dictionary<String,AnyObject>]()
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
                        let alert = UIAlertController(title: "No art found!", message: "Post art to this location to see it live!", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok!", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

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
        self.performSegueWithIdentifier(ARViewController.getUnwindSegueFromChangeArtView(), sender: indexPath.row)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func hydrateCellAtIndexPath(indexPath: NSIndexPath, image: UIImage) {
        if let cell: ArtTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath) as? ArtTableViewCell {
            let upvotes = String(self.artData[indexPath.row]["upvotes"]! as! Int)
            let downvotes = String(self.artData[indexPath.row]["downvotes"]! as! Int)
            cell.thumbImageView.image = image
            cell.upvoteLabel.text = upvotes
            cell.downvoteLabel.text = downvotes
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ArtTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArtTableViewCell
        
        cell.thumbImageView.image = nil
        
        let backgroundLoadingView = Utils.genLoadingScreen(cell.bounds.width, height: cell.bounds.height, loadingText: "Teleporting Image....")
        cell.contentView.addSubview(backgroundLoadingView)
        
        if let artId = self.artData[indexPath.row]["ArtId"] as? Int{
            let stringArtId = String(artId)
            let artType = ResourceHandler.getArtTypeFromExtension(self.artData[indexPath.row]["type"] as! String)
            
            let that = self;
            ResourceHandler.retrieveResource(stringArtId, type: artType, onComplete: {(resource: NSObject) in
                dispatch_async(dispatch_get_main_queue(), {
                    if (artType == .IMAGE) {
                        that.hydrateCellAtIndexPath(indexPath, image: resource as! UIImage)
                    } else {
                        let image = UIImage(named: "Emblem.jpg")!
                        that.hydrateCellAtIndexPath(indexPath, image: image)
                    }
                    backgroundLoadingView.removeFromSuperview()
                })
            })
        }

        
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ARViewController.getUnwindSegueFromChangeArtView() {
            let dest = segue.destinationViewController as! ARViewController
            if let index = sender as? Int {
                let artId:String = String(self.artData[index]["ArtId"]!)
                let artPlaceId:String = String(self.artData[index]["ArtPlaceId"]!)
                let artType = ResourceHandler.getArtTypeFromExtension(self.artData[index]["type"] as! String)
                
                ResourceHandler.retrieveResource(artId, type: artType, onComplete: {(resource: NSObject) in
                    dispatch_async(dispatch_get_main_queue(), {
                        dest.receiveArt(resource, artType: artType, artPlaceId: artPlaceId)
                    })
                })
            }
        }
    }
 

}
