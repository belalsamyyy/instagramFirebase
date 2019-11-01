//
//  Comment.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/26/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import Foundation

struct Comment {
    
    let user: User
    let text: String
    let uid: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
