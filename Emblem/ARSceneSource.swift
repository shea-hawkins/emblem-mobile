//
//  ARSceneSource.swift
//  Emblem
//
//  Created by Humanity on 8/17/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

class ARSceneSource: NSObject, ARSceneSourceProtocol {
    
    func sceneForEAGLView(view: AREAGLView!, viewInfo: [String : AnyObject]?) -> SCNScene! {
        return create2DScene(with: view);
    }
    
    private func create2DScene(with view: AREAGLView) -> SCNScene {
        let scene = SCNScene()
        
        let planeNode = SCNNode()
        planeNode.name = "plane"
        planeNode.geometry = SCNPlane(width: 247.0/view.objectScale, height: 173.0/view.objectScale)
        planeNode.position = SCNVector3Make(0, 0, -1)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = "Noblesse.png"
        planeMaterial.transparency = 0.95
        planeNode.geometry?.firstMaterial = planeMaterial
        scene.rootNode.addChildNode(planeNode)
        
        return scene
    }
    
    private func create3DScene(with view: AREAGLView) -> SCNScene {
        let scene = SCNScene()
        
        let boxMaterial = SCNMaterial()
        
        boxMaterial.diffuse.contents = UIColor.lightGrayColor()
        
        let planeNode = SCNNode()
        planeNode.name = "plane"
        planeNode.geometry = SCNPlane(width: 247.0/view.objectScale, height: 173.0/view.objectScale)
        planeNode.position = SCNVector3Make(0, 0, -1)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.redColor()
        planeMaterial.transparency = 0.6
        planeNode.geometry?.firstMaterial = planeMaterial
        scene.rootNode.addChildNode(planeNode)
        
        let boxNode = SCNNode()
        boxNode.name = "box"
        boxNode.geometry = SCNBox(width:1, height:1, length:1, chamferRadius:0.0)
        boxNode.geometry?.firstMaterial = boxMaterial
        scene.rootNode.addChildNode(boxNode)
        
        return scene
    }
}
