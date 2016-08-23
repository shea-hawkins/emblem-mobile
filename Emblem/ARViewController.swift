import UIKit

class ARViewController: UIViewController {
    
    let vuforiaLiceseKey = "AYJpO+D/////AAAAGXc7/OWJPUHjsb8bm4n4RlSOubbboimzkhNccixNsn3gsfnHEwFz8G4B3aMZrzGPPJj2hFSFNzpALj17d8v7MGsFvWa+wDUmN+3nHCmGRvBYafkHI7fpSJujrkvCpKqCL70uTp/mnp60q/wkGmvMmaMB7zSnKZBMNJcYbQUC3jDOhmxXnQDh3Dn3kmpMkpWal2kjadG5uQflQyxxDqtLo7p9nnz0M0vpX0kir615EBJKhMihnBYl+6BTGYwfbehqYwrOXNJSofm70tPELhMHkSG25tclvcg0O0je/sEefhzXA+uxpAyprLxKg7JgFKjY6dFJ42VjE919C9qcyqD2yK2XJfDNUYnDvDShthtDNCR8"
    let vuforiaDataSetFile = "Emblem.xml"
    
    private var vuforiaManager: ARManager? = nil
    private var sceneSource: ARSceneSource? = nil
    private var lastSceneName: String? = nil
    private var artType: ArtType? = nil
    private var art: NSObject? = nil
    
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
        
        let swipeleft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleMySwipeLeftGesture))
        swipeleft.direction = .Left
        let swiperight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleMySwipeRightGesture))
        swiperight.direction = .Right


        
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(didRecievePauseNotice),
                                       name: UIApplicationWillResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(didRecieveResumeNotice),
                                       name: UIApplicationDidBecomeActiveNotification, object: nil)
        
     
        prepare() //functionalize pls
        
        self.view.addGestureRecognizer(swipeleft)
        self.view.addGestureRecognizer(swiperight)
    }
    
    func swipeLeft(recognizer : UISwipeGestureRecognizer) {
        performSegueWithIdentifier(ChangeArtTableViewController.getEntrySegueFromARViewController(), sender: self)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == ChangeArtTableViewController.getEntrySegueFromARViewController()) {
            let dest = segue.destinationViewController as! ChangeArtTableViewController
            dest.delegate = sender as? ChangeArtTableViewControllerDelegate;
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
    func receiveArt(art: NSObject!, artType: ArtType!) {
        // Can create an observable pattern here  where this notifies
        // sub views (such as AREAGLView) listening for a change in order to 
        // change arts after the view has already been loaded.
        self.art = art;
        self.artType = artType;
        if (self.sceneSource != nil) {
            self.sceneSource!.setArt(art);
            let eaglView = self.vuforiaManager?.eaglView;
            let scene = self.sceneSource!.sceneForEAGLView(eaglView, viewInfo: nil);
            eaglView!.changeScene(scene);
        }
    }
    
    func upvoteArt() {
        NSLog("Upvoting!")
    }
    
    func downvoteArt() {
        NSLog("Downvoting!")
    }
}

private extension ARViewController {
    func prepare() {
        vuforiaManager = ARManager(licenseKey: vuforiaLiceseKey, dataSetFile: vuforiaDataSetFile)
        self.sceneSource = ARSceneSource(art: self.art, artType: self.artType)
        
        
        if let manager = vuforiaManager {
            manager.delegate = self
            manager.eaglView.sceneSource = self.sceneSource
            manager.eaglView.delegate = self
            manager.eaglView.setupRenderer()
            self.view = manager.eaglView
            
            let menuView = ARMenuView(frame: self.view.frame);
            
            menuView.on("upvote", callback: {() in self.upvoteArt()})
            menuView.on("downvote", callback: {() in self.downvoteArt()})
            
            self.view.addSubview(menuView)
            
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


