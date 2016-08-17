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
    func receiveArt(image: UIImage!);
}

class ChangeArtTableViewController: UITableViewController {
    
    var artIDs = [UInt]()
    var art = [UIImage?]()
    var isLoaded:[Bool]?
    var delegate:ChangeArtTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO: Save image data locally
        getImageIds();
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func getImageIds(){
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "art")!
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
