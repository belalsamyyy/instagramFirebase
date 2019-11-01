//
//  Extensions.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/6/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
import Firebase

// UIColor Extension
extension UIColor {
    
    // rgb
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    // MAIN BLUE COLOR
    static func mainBlue() -> UIColor {
        return UIColor.rgb(17, 154, 237)
    }
    
}


// anchor extension
extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?,
                left: NSLayoutXAxisAnchor?,
                bottom: NSLayoutYAxisAnchor?,
                right: NSLayoutXAxisAnchor?,
                paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat,
                width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height ).isActive = true
        }
    }
}

// database extension
extension Database {
    // we will use complition to use fetchPostsWithUser that belongs to homeController and we unable to use it here
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        //  print("Fetching user with uid : ", uid)
        // fetch user --------------------------------------------------------
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value ?? "")
            guard let userDictionary = snapshot.value as? [String: Any] else { return  }
            let user = User(uid: uid, dictionary: userDictionary)
            // execution the completion block .. it will make you have to add @escaping to work
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user for posts : ", err)
        }
    }
}


extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int( Date().timeIntervalSince(self) )
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let number: Int
        let unit: String
        
        if secondsAgo < minute {
            number = secondsAgo
            unit = "second"
            
        } else if secondsAgo < hour {
            number = secondsAgo / minute
            unit = "min"
            
        } else if secondsAgo < day {
            number = secondsAgo / hour
            unit = "hour"
            
        } else if secondsAgo < week {
            number = secondsAgo / day
            unit = "day"
            
        } else if secondsAgo < month {
            number = secondsAgo / week
            unit = "week"
            
        } else {
            number = secondsAgo / month
            unit = "month"
        }
        
        return "\(number) \(unit)\(number == 1 ? "" : "s") ago"
    }
}


