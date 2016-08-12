//
//  User.swift
//  Emblem
//
//  Created by Dane Jordan on 8/8/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import Foundation

class User {
    var name: String!
    var email: String!
    var fbID: String!
    var imgURL: NSURL!
    
    init(name: String, email: String, fbID: String, imgURL:String) {
        self.name = name
        self.email = email
        self.fbID = fbID
        self.imgURL = NSURL(string: imgURL)
    }
}