import UIKit
import SwiftyJSON

class ARViewController: UIViewController {
    
    let vuforiaLiceseKey = "AYJpO+D/////AAAAGXc7/OWJPUHjsb8bm4n4RlSOubbboimzkhNccixNsn3gsfnHEwFz8G4B3aMZrzGPPJj2hFSFNzpALj17d8v7MGsFvWa+wDUmN+3nHCmGRvBYafkHI7fpSJujrkvCpKqCL70uTp/mnp60q/wkGmvMmaMB7zSnKZBMNJcYbQUC3jDOhmxXnQDh3Dn3kmpMkpWal2kjadG5uQflQyxxDqtLo7p9nnz0M0vpX0kir615EBJKhMihnBYl+6BTGYwfbehqYwrOXNJSofm70tPELhMHkSG25tclvcg0O0je/sEefhzXA+uxpAyprLxKg7JgFKjY6dFJ42VjE919C9qcyqD2yK2XJfDNUYnDvDShthtDNCR8"
    let vuforiaDataSetFile = "Emblem.xml"
    
    private var vuforiaManager: ARManager? = nil
    private var sceneSource: ARSceneSource? = nil
    private var menuView:ARMenuView!
    private var lastSceneName: String? = nil
    private var artType: ArtType? = nil
    private var art: NSObject? = nil
    var locationManager:CLLocationManager = CLLocationManager()
    let FIFTYFEETINDEGREES = 0.000137
    var sector:String!
    private var artPlaceId: String? = nil
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    @IBAction func unwindFromLibaryToARVC(segue: UIStoryboardSegue) {
        print("unwindFromLibraryToARVC")
    }
    
    @IBAction func unwindFromChangeArtToARVC(segue: UIStoryboardSegue) {
        print("unwindFromChangeArtToARVC")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleMySwipeLeftGesture))
        swipeLeft.direction = .Left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleMySwipeRightGesture))
        swipeRight.direction = .Right
        
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(didRecievePauseNotice),
                                       name: UIApplicationWillResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(didRecieveResumeNotice),
                                       name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.locationManager.requestLocation()
        
        
        prepare() //functionalize pls
        
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)
      
        if let leftImage = UIImage(named: "plus-symbol-white.png") {
            let leftButton = UIButton(type: UIButtonType.Custom)
            leftButton.frame = CGRectMake(20, 20, 20, 20)
            leftButton.contentMode = UIViewContentMode.ScaleAspectFit
            leftButton.setImage(leftImage, forState: .Normal)
            leftButton.addTarget(self, action: #selector(ARViewController.handleMySwipeRightGesture(_:)), forControlEvents: .TouchUpInside)
            self.view.addSubview(leftButton)
        }
        
        
        if let rightImage = UIImage(named: "menu.png") {
            let rightButton = UIButton(type: UIButtonType.Custom)
            rightButton.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 40, 20, 20, 20)
            rightButton.contentMode = UIViewContentMode.ScaleAspectFit
            rightButton.setImage(rightImage, forState: .Normal)
            rightButton.addTarget(self, action: #selector(ARViewController.handleMySwipeLeftGesture(_:)), forControlEvents: .TouchUpInside)
            self.view.addSubview(rightButton)
        }
        
        if let downImage = UIImage(named: "down-arrow-white.png") {
            let downButton = UIButton(type: UIButtonType.Custom)
            downButton.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 20) / 2, 20, 20, 20)
            downButton.contentMode = UIViewContentMode.ScaleAspectFit
            downButton.setImage(downImage, forState: .Normal)
            downButton.addTarget(self, action: #selector(ARViewController.back), forControlEvents: .TouchUpInside)
            self.view.addSubview(downButton)
        }
    
    }
    func back() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
        self.didRecieveResumeNotice()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.didRecievePauseNotice();
        super.viewWillDisappear(animated)
    }
    
    
    func handleMySwipeLeftGesture(gestureRecognizer: UISwipeGestureRecognizer) {
        self.performSegueWithIdentifier(ChangeArtTableViewController.getEntrySegueFromARViewController(), sender: nil)
    }
    
    func handleMySwipeRightGesture(gestureRecognizer: UISwipeGestureRecognizer) {
        self.performSegueWithIdentifier(LibraryTableViewController.getEntrySegueFromARViewController(), sender: nil)
    }
    
    class func getEntrySegueFromMapView() -> String {
        return "MapToSimpleViewControllerSegue";
    }
    
    class func getUnwindSegueFromLibraryView() -> String {
        return "UnwindToARVCSegue"
    }
    
    class func getUnwindSegueFromChangeArtView() -> String {
        return "UnwindFromChangeArtToARVCSegue"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ChangeArtTableViewController.getEntrySegueFromARViewController() {
            let dest = segue.destinationViewController as! ChangeArtTableViewController
            dest.delegate = sender as? ChangeArtTableViewControllerDelegate
        }
    }
}

extension ARViewController {
    func didRecievePauseNotice(notification: NSNotification?=nil) {
        pause()
    }
    
    func didRecieveResumeNotice(notification: NSNotification?=nil) {
        resume()
    }
}

extension ARViewController: ChangeArtTableViewControllerDelegate {
    func receiveArt(art: NSObject!, artType: ArtType!, artPlaceId: String!) {
        // Can create an observable pattern here  where this notifies
        // sub views (such as AREAGLView) listening for a change in order to 
        // change arts after the view has already been loaded.
        print("receiveArt")
        self.art = art;
        self.artType = artType;
        self.artPlaceId = artPlaceId;
        if (self.sceneSource != nil) {
            self.sceneSource!.setArt(art, artType: self.artType!);
            let eaglView = self.vuforiaManager?.eaglView;
            let scene = self.sceneSource!.sceneForEAGLView(eaglView, viewInfo: nil);
            eaglView!.changeScene(scene);
        }
    }
    
    func upvoteArt() {
        NSLog("Upvoting!")
        
        let url = NSURL(string: "\(Store.serverLocation)artplace/\(self.artPlaceId!)/vote")!
        
        HTTPRequest.post(["vote": 1], dataType: "application/json", url: url, postCompleted: {(succeeded, msg) in
            if succeeded {
                self.menuView.upvoted()
                print("upvoted")
            }
        })
    }
    
    func downvoteArt() {
        let url = NSURL(string: "\(Store.serverLocation)artplace/\(self.artPlaceId)/vote")
        
        HTTPRequest.post(["vote": -1], dataType: "application/json", url: url!, postCompleted: {(succeeded, msg) in
            if succeeded {
                self.menuView.downvoted()
                print("upvoted")
            }
        })
    }
}

private extension ARViewController {
    func prepare() {
        vuforiaManager = ARManager(licenseKey: vuforiaLiceseKey, dataSetFile: vuforiaDataSetFile)
        self.artType = .MODEL;
        self.sceneSource = ARSceneSource(art: self.art, artType: self.artType)
        
        
        if let manager = vuforiaManager {
            manager.delegate = self
            manager.eaglView.sceneSource = self.sceneSource
            manager.eaglView.delegate = self
            manager.eaglView.setupRenderer()
            self.view = manager.eaglView
            
            self.menuView = ARMenuView(frame: self.view.frame);
            let that = self
            self.menuView.on("upvote", callback: {() in that.upvoteArt()})
            self.menuView.on("downvote", callback: {() in that.downvoteArt()})
            
            
            self.view.addSubview(menuView!)
            
        }
        vuforiaManager?.prepareWithOrientation(.Portrait)
    }
    
    func pause() {
        do {
            try vuforiaManager?.pause()
        }catch let error {
            print("\(error)")
        }
    }
    
    func resume() {
        do {
            try vuforiaManager?.resume()
        }catch let error {
            print("\(error)")
        }
    }
}



extension ARViewController: ARManagerDelegate {
    func vuforiaManagerDidFinishPreparing(manager: ARManager!) {
        print("did finish preparing\n")
        
        do {
            try vuforiaManager?.start()
            vuforiaManager?.setContinuousAutofocusEnabled(true)
        }catch let error {
            print("\(error)")
        }
    }
    
    func vuforiaManager(manager: ARManager!, didFailToPreparingWithError error: NSError!) {
        print("did faid to preparing \(error)\n")
    }
    
    func vuforiaManager(manager: ARManager!, didUpdateWithState state: VuforiaState!) {}
}

extension ARViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let newLat = Double(location.coordinate.latitude)
            let newLong = Double(location.coordinate.longitude)
            let distDiff = pow((pow((newLat - Store.lat), 2) + pow((newLong - Store.long), 2)), 0.5)
            
            if distDiff > FIFTYFEETINDEGREES {
                Store.lat = newLat
                Store.long = newLong
                print("updating lat & long...")

            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager error: \(error)")
    }
}


