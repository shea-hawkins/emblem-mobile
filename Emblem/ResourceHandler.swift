//
//  ResourceHandler.swift
//  Emblem
//
//  Created by Humanity on 8/25/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import SSZipArchive

enum ArtType {
    case IMAGE
    case MODEL
}

class ResourceHandler {
    static func download2DAsset(id: String, onComplete: (asset: UIImage) -> Void) {
        let urlString = "\(Store.serverLocation)art/\(id)/download"
        let url = NSURL(string: urlString)!
        HTTPRequest.get(url) { (response, data) in
            if response.statusCode == 200 {
                let image = UIImage(data: data)!
                Store.dataCache.setObject(image, forKey: id)
                onComplete(asset: image)
            }
        }
    }
    
    static func download3DAsset(id: String, onComplete: (asset: MDLAsset) -> Void) {
        let urlString = "\(Store.serverLocation)storage/\(id).zip"
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
                let asset = MDLAsset(URL: localUrl)
                Store.dataCache.setObject(asset, forKey: id)
                onComplete(asset: asset)
            }
        }
    }
    
    static func retrieveResource(id: String, type: ArtType, onComplete: (resource: NSObject) -> Void) {
        if let cachedObj = Store.dataCache.objectForKey(id) as? NSObject {
            onComplete(resource: cachedObj)
        } else {
            if (type == .IMAGE) {
                download2DAsset(id, onComplete: onComplete)
            } else {
                download3DAsset(id, onComplete: onComplete)
            }
        }
    }
    
}
