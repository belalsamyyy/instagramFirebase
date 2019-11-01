//
//  Post.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/13/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import Foundation

struct Post {
    
    // to get the post random key id
    var id: String?
    
    let user: User
    let imageUrl: String
    let caption: String
    let creationDate: Date
    
    var hasLiked = false
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        
        // convert number from database into date
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
