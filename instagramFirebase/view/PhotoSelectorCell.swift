//
//  PhotoSelectorCell.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/12/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit

class PhotoSelectorCell: UICollectionViewCell {
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        //iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill // to make every image with its right aspect ratio
        iv.clipsToBounds = true // to make image didnt out from the boundaries bec of different aspect ratio
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        // to make the image fill the entire cell
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                              paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                              width: 0, height: 0)
        
        backgroundColor = UIColor(white: 0, alpha: 0.1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
