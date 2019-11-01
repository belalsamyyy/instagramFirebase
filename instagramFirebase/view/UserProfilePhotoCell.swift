//
//  UserProfilePhotoCell.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/14/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit

class UserProfilePhotoCell: UICollectionViewCell {
    
    // how to get image data from url to set the value in image view
    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else { return }
            photoImageView.loadImage(urlString: imageUrl)  // use our custom image view func to get image from url
            //print(post?.imageUrl ?? "")
            //print(1)
        }
    }
    
    // use our custom image view instead of UIImageView
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        iv.contentMode = .scaleAspectFill // to make every image with its right aspect ratio
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // add image to the cell
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                              paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                              width: 0, height: 0)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
