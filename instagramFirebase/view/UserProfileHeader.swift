//
//  UserProfileHeader.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/9/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
import Firebase

//1
protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}

// create sub class for header views
class UserProfileHeader: UICollectionViewCell {
    
    //2
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            //setupProfileImage()
            guard let profileImageUrl = user?.image else { return }
            ProfileImageView.loadImage(urlString: profileImageUrl)
            
            usernameLabel.text = user?.username
            
            setupEditFollowButton()
 
        }
    }
    
    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if userId == currentLoggedInUserId {
            //edit profile
        } else {
            // check if following
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot.value ?? "") // it will return 1
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    // unfollow
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    
                } else {
                    // follow
                    self.editProfileFollowButton.setTitle("Follow", for: .normal)
                    self.editProfileFollowButton.setTitleColor(.white, for: .normal)
                    self.editProfileFollowButton.backgroundColor = UIColor.rgb(17, 154, 237)
                    self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor // bec border color is cgColor
                }
                
            }, withCancel: { (err) in
                print("Failed to check if following : ", err)
            })
            
        }
    }
    
    @objc func handleEditProfileOrFollow() {
        print("Execute edit profile / follow / unfollow logic.")
       
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        let ref = Database.database().reference().child("following").child(currentLoggedInUserId)

        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            // unfollow
            ref.child(userId).removeValue { (err, ref) in
                if let err = err {
                    print("Failed to Unfollow user : ",err)
                    return
                }
                print("Successfully unfollowed user : ", self.user?.username ?? "")
                self.setupFollowStyle()
            }
            
        } else {
            // follow
            let values = [userId: 1]
            ref.updateChildValues(values) { (err, ref) in
                
                if let err = err {
                    print("Failed to follow user : ", err)
                    return
                }
                print("Successfully followed user :", self.user?.username ?? "")
                self.setupUnfollowStyle()
                
            }
        }
        
        
    }
    
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.rgb(17, 154, 237)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor // bec border color is cgColor
    }
    
    fileprivate func setupUnfollowStyle() {
        self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
        self.editProfileFollowButton.backgroundColor = .white
        self.editProfileFollowButton.setTitleColor(.black, for: .normal)
    }
    
    // add profile image view
    let ProfileImageView: CustomImageView = {  // use CustomImageView instead of UIImageView
        let iv = CustomImageView()
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return iv
    }()
    
    // add grid button
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        //button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToGridView() {
        print("Changing to grid view")
        gridButton.tintColor = .mainBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.1)
        
        //3
        delegate?.didChangeToGridView()
    }
    
    // add list button >>> turn it to (lazy var) so we can add a target
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToListView() {
        print("Changing to list view")
        listButton.tintColor = .mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.1)
        
        //3
        delegate?.didChangeToListView()
    }
    
    // add ribon button
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    // add user name label
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    // add posts label
    let postsLabel: UILabel = {
        let label = UILabel()
         
        // cool trick to make 11 posts with different attributes
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes:
            [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        //label.text = "11\nposts"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    // add followers label
    let followersLabel: UILabel = {
        let label = UILabel()
        
        // cool trick to make 11 followers with different attributes
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes:
            [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        
        //label.text = "11\nfollowers"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    // add following label
    let followingLabel: UILabel = {
        let label = UILabel()
        
        // cool trick to make 11 following with different attributes
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes:
            [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        
        //label.text = "11\nfollowing"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    //add edit profile button
    // the action didnt work bec need to use "lazy var" instead of "let"
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        // add action
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    
    // ui classes doesnt have view did load instead ...
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addSubview(ProfileImageView)
        
        // add auto layout constraints to the profile image view
        ProfileImageView.anchor(top: self.topAnchor, left: self.leftAnchor,
                                bottom: nil, right: nil,
                                paddingTop: 12, paddingLeft: 12,
                                paddingBottom: 0, paddingRight: 0,
                                width: 80, height: 80)
        // to make it rounded
        ProfileImageView.layer.cornerRadius = 80/2
        ProfileImageView.clipsToBounds = true
        
    
        //setupProfileImage()
        
        setupBottomToolbar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: ProfileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: nil,
                             paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 12,
                             width: 0, height: 0)
        
        setupUserStatsView()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor,
                                 paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                                 width: 0, height: 34)
    }
    
    fileprivate func setupUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: ProfileImageView.rightAnchor, bottom: nil, right: rightAnchor,
                         paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12,
                         width: 0, height: 50)
    }

    fileprivate func setupBottomToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left:  leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                         paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                         width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,
                              paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                              width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,
                              paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                              width: 0, height: 0.5)
    }
    
    
    
    // we didnt need this function any more ..........................................................................................
    // setup profile func >> make it fileprivate so other funcs cant access it
    /*fileprivate func setupProfileImage() {
        
        guard let name = user?.username else {return}
        print("Did set \(name)")
        guard let image = user?.image else {return}
        guard let url = URL(string: image) else {return}
        
        // to fetch the image .. it requires
        URLSession.shared.dataTask(with: url) { (data, respond, err) in
            // check for the error , then construct the image using data
            if let err = err {
                print("Failed to fetch profile image : ", err)
                return
            }
            // perhaps check for response status of 200 (HTTP OK)
            
            guard let data = data else {return}
            let image  = UIImage(data: data)
            
            // the image wont show bec in URL SESSION COMPLETION you still in background thread
            // need to get back onto the main UI thread
            DispatchQueue.main.async {
                self.ProfileImageView.image = image // now its in the main thread
            }
            
            }.resume() // dont forget to call resume after data task
        
        //>>>>>>>>>> ---------------- we dont need this code any more ---------------------------------------------------------
        /*guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value ?? "")
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            //let username = dictionary ["username"] as? String
            guard let profileImageUrl = dictionary ["image"] as? String else {return}
            //self.navigationItem.title = username
        }) { (err) in
            print("Failed to fetch user : ",err)
        }
        ---------------------------------------------------------------------------------------------------------------------*/
    }
    */
    
    // it requires initializer ... that you have to override as well
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
