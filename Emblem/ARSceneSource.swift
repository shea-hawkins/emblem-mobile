//
//  ARSceneSource.swift
//  Emblem
//
//  Created by Humanity on 8/17/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//
import SceneKit.ModelIO
import SSZipArchive

enum ArtType {
    case IMAGE
    case MODEL
}

class ARSceneSource: NSObject, ARSceneSourceProtocol {
    
    private var art: NSObject? = nil
    private var artType: ArtType? = nil
    private var scene: SCNScene? = nil
    
    init(art: NSObject?, artType: ArtType?) {
        super.init()
        
        self.artType = artType
        self.art = art
        
        if (self.artType == nil) {
            self.artType = .IMAGE;
            self.art = UIImage(named: "Emblem.jpg")
        }
    }
    
    func setArt(art: NSObject!) {
        self.art = art;
    }
    
    func sceneForEAGLView(view: AREAGLView!, viewInfo: [String : AnyObject]?) -> SCNScene! {
        //return create2DScene(with: view);
        return create3DScene(with: view);
    }
    
    private func create2DScene(with view: AREAGLView) -> SCNScene {
        let scene = SCNScene()
        let planeNode = SCNNode()
        planeNode.name = "plane"
        planeNode.geometry = SCNPlane(width: 247.0/view.objectScale, height: 173.0/view.objectScale)
        planeNode.position = SCNVector3Make(0, 0, -1)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = art as? UIImage
        planeMaterial.transparency = 0.95
        planeNode.geometry?.firstMaterial = planeMaterial
        scene.rootNode.addChildNode(planeNode)
        
        return scene
    }
    
    
    private func unzip() {
        SSZipArchive.unzipFileAtPath("", toDestination: "")
    }


    
    private func create3DScene(with view: AREAGLView) -> SCNScene {
        
        

        
        self.scene = SCNScene()

        
        func download3DAsset(id: String, onComplete: (asset: MDLAsset) -> Void) {
            let urlString = "http://10.8.24.31:3000/storage/\(id).zip"
            let url = NSURL(string: urlString)!
            let zipPath = NSTemporaryDirectory() as String;
            HTTPRequest.get(url) { (response, data) in
                if response.statusCode == 200 {
                    do{
                        try data.writeToFile("\(zipPath)\(id).zip", options: NSDataWritingOptions.DataWritingAtomic)
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    SSZipArchive.unzipFileAtPath("\(zipPath)\(id).zip", toDestination: zipPath)
                    
                    let localUrl = NSURL(fileURLWithPath: "\(zipPath)\(id)/\(id).obj")
                    onComplete(asset: MDLAsset(URL: localUrl));
                }
            }
        }
        
        download3DAsset("2", onComplete: {(asset: MDLAsset) in
            let node = SCNNode(MDLObject: asset.objectAtIndex(0))
            var center = SCNVector3Make(1, 1 ,1)
            var radius = CGFloat()
            
            node.getBoundingSphereCenter(&center, radius: &radius)
            
            let scalefactor = 5 / Float(radius);
            
            node.position = SCNVector3Make(0, 0, -1)
            node.scale = SCNVector3Make(scalefactor, scalefactor, scalefactor)
            
            self.scene!.rootNode.addChildNode(node);
        })
        
        
        return self.scene!
    }
}
