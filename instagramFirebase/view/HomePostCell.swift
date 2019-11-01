//
//  HomePostCell.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/15/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit

// add protocol .. for comment section (delegate design pattern)
//1
protocol HomePostCellDelegate {
    // add post to know which post we're click on
    func didTapComment(post: Post)
    func didLike(for cell: HomePostCell)
}

class HomePostCell: UICollectionViewCell {
    
    //2
    var delegate: HomePostCellDelegate? // "optional" bec it starts off as nil
    
    // to render post image inside the cell
    var post: Post? { // make it optional >> bec it needs to be nil at first
        didSet{
            //print(post?.imageUrl ?? "")
            guard let postImageUrl = post?.imageUrl else { return }
            photoImageView.loadImage(urlString: postImageUrl)
            //usernameLabel.text = "TEST USERNAME"
            
            // wouldn't this be nice ?!!
            usernameLabel.text = post?.user.username
            
            guard let profileImageUrl = post?.user.image else { return }
            userProfileImage.loadImage(urlString: profileImageUrl)
            
            //captionLabel.text = post?.caption
            setupAttributedCaption()
            
            let like_red = #imageLiteral(resourceName: "like_red").withRenderingMode(.alwaysOriginal)
            let like_unselected = #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal)
            
            //like button
            likeButton.setImage(post?.hasLiked == true ? like_red : like_unselected , for: .normal)
        }
    }
    
    // setup attributed caption
    fileprivate func setupAttributedCaption() {
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: "\(post.user.username) ",
                                                       attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "\(post.caption).",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        attributedText.append(NSAttributedString(string: "\n\n",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay,
                                                 attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                                                              NSAttributedString.Key.foregroundColor: UIColor.gray ]))
        captionLabel.attributedText = attributedText
    }
    
    let userProfileImage: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)  // Alt + 8 = •••
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    // you have to change (let) to (lazy var) to make the target func work ...
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLike() {
        print("handling like from within cell ...")
        delegate?.didLike(for: self)
    }
    
    // without use "let" instead of "lazy var" the target didnt work
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    @objc func handleComment() {
        print("Trying to show comments ...")
        guard let post = self.post else { return }
        //3
        delegate?.didTapComment(post: post)
    }
    
    let sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        //label.text = "SOMETHING FOR NOW !"
        //label.attributedText = attributedText
        label.numberOfLines = 0
        
        //label.backgroundColor = .yellow
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(userProfileImage)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        addSubview(photoImageView)
        
        userProfileImage.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil,
                                paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0,
                                width: 40, height: 40)
        // make it circle
        userProfileImage.layer.cornerRadius = 40 / 2
        
        usernameLabel.anchor(top: topAnchor, left: userProfileImage.rightAnchor, bottom: photoImageView.topAnchor, right: optionsButton.leftAnchor,
                             paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0,
                             width: 0, height: 0)
        
        optionsButton.anchor(top: topAnchor, left: nil, bottom: photoImageView.topAnchor, right: rightAnchor,
                             paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8,
                             width: 44, height: 0)
        
        photoImageView.anchor(top: userProfileImage.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,
                              paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                              width: 0, height: 0)
        
        // we change bottom to nil + add this constraint >>> to make the bottom part appears
        // so the the height of image will be attached only to the width to make square 
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        // action buttons ( like + comment + send message )
        setupActionButtons()
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                            paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8,
                            width: 0, height: 0)
        
    }
    
    fileprivate func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil,
                         paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0,
                         width: 120, height: 50)
        
        addSubview(bookmarkButton)
        bookmarkButton.anchor(top: photoImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor,
                              paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                              width: 40, height: 50 )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
