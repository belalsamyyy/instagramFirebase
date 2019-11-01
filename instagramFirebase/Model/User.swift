//
//  User.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/17/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import Foundation

// to avoid fetch user infos twice ...
struct User {
    let uid: String
    let username: String
    let image: String
    
    // build constructor to help us setup those properties
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid // it will make search for people easier
        self.username = dictionary["username"] as? String ?? ""
        self.image = dictionary["image"] as? String ?? ""
    }
}
