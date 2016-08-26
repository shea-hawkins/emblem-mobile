//
//  ResourceHandler.swift
//  Emblem
//
//  Created by Humanity on 8/25/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import SSZipArchive

class ResourceHandler {
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
                onComplete(asset: MDLAsset(URL: localUrl));
            }
        }
    }
    
}
