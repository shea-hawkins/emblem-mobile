import UIKit

class ARViewController: UIViewController {
    
    let vuforiaLiceseKey = "AYJpO+D/////AAAAGXc7/OWJPUHjsb8bm4n4RlSOubbboimzkhNccixNsn3gsfnHEwFz8G4B3aMZrzGPPJj2hFSFNzpALj17d8v7MGsFvWa+wDUmN+3nHCmGRvBYafkHI7fpSJujrkvCpKqCL70uTp/mnp60q/wkGmvMmaMB7zSnKZBMNJcYbQUC3jDOhmxXnQDh3Dn3kmpMkpWal2kjadG5uQflQyxxDqtLo7p9nnz0M0vpX0kir615EBJKhMihnBYl+6BTGYwfbehqYwrOXNJSofm70tPELhMHkSG25tclvcg0O0je/sEefhzXA+uxpAyprLxKg7JgFKjY6dFJ42VjE919C9qcyqD2yK2XJfDNUYnDvDShthtDNCR8"
    let vuforiaDataSetFile = "Emblem.xml"
    
    var vuforiaManager: ARManager? = nil
    var sceneSource: ARSceneSource? = nil
    
    private var lastSceneName: String? = nil
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(didRecieveWillResignActiveNotification),
                                       name: UIApplicationWillResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(didRecieveDidBecomeActiveNotification),
                                       name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        
        prepare()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        do {
            try vuforiaManager?.stop()
        }catch let error {
            print("\(error)")
        }
    }
    
    class func getEntrySegueFromMapView() -> NSString {
        return "MapToSimpleViewControllerSegue";
    }
}

extension ARViewController {
    func didRecieveWillResignActiveNotification(notification: NSNotification) {
        pause()
    }
    
    func didRecieveDidBecomeActiveNotification(notification: NSNotification) {
        resume()
    }
}

private extension ARViewController {
    
    func prepare() {
        
        vuforiaManager = ARManager(licenseKey: vuforiaLiceseKey, dataSetFile: vuforiaDataSetFile)
        sceneSource = ARSceneSource()
        if let manager = vuforiaManager {
            manager.delegate = self
            manager.eaglView.sceneSource = sceneSource
            manager.eaglView.delegate = self
            manager.eaglView.setupRenderer()
            self.view = manager.eaglView
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


