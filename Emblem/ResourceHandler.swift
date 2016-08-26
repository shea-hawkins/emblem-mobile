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
    static func clearTempFolder() {
        let fileManager = NSFileManager.defaultManager()
        let tempFolderPath = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectoryAtPath(tempFolderPath)
            for filePath in filePaths {
                print("deleting \(filePath)")
                try fileManager.removeItemAtPath(NSTemporaryDirectory() + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
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
        let urlString = "\(Store.serverLocation)art/\(id)/download"
        let url = NSURL(string: urlString)!
        let tmpPath = NSTemporaryDirectory() as String;
        let zipPath = "\(tmpPath)\(id)/"
        HTTPRequest.get(url) { (response, data) in
            if response.statusCode == 200 {
                do{
                    try NSFileManager.defaultManager().createDirectoryAtPath(zipPath, withIntermediateDirectories: false, attributes: nil)
                    try data.writeToFile("\(zipPath)\(id).zip", options: NSDataWritingOptions.DataWritingAtomic)
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                SSZipArchive.unzipFileAtPath("\(zipPath)\(id).zip", toDestination: zipPath)
                
                
                do {
                    let items = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(zipPath)
                    for item in items {
                        print("Found \(item)")
                    }
                } catch {
                    // failed to read directory – bad permissions, perhaps?
                }
                
                
                let localUrl = NSURL(fileURLWithPath: "\(zipPath)main/main.obj")
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
    
    static func getArtTypeFromExtension(type: String) -> ArtType {
        let fileArr = type.componentsSeparatedByString("/")
        let ext = fileArr[fileArr.count - 1]
        var artType = ArtType.IMAGE
        if (ext == "zip") {
            artType = ArtType.MODEL
        }
        return artType
    }
    
}
