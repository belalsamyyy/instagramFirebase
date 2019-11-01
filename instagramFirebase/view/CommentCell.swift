//
//  CommentCell.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/26/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            //guard let profileImageUrl = comment.user.image else { return }
            //guard let username = comment.user.username else { return }
            
            let attributedText =
                NSMutableAttributedString(string: comment.user.username, attributes:
                [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(NSAttributedString(string: " "+comment.text, attributes:
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
             
            //print(comment?.text ?? "")
            //textLabel.text = comment.text
            
            textView.attributedText = attributedText
            profileImageView.loadImage(urlString: comment.user.image)
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return iv
    }()
    
    // we use UITextView instead of UILabel bec text view start from the top but label is in the center
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        //label.numberOfLines = 0
        //label.backgroundColor = .lightGray
        textView.isScrollEnabled = false // to make the controller konw how to calculated the height right 
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = .yellow

        addSubview(profileImageView)
        profileImageView.layer.cornerRadius = 40 / 2
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil,
                                paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0,
                                width: 40, height: 40)

        addSubview(textView)
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor,
                         paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4,
                         width: 0, height: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


