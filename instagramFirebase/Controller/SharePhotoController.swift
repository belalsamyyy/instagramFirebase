//
//  SharePhotoController.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/12/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
import Firebase

class SharedPhotoController: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            print(selectedImage ?? "")
            self.imageView.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(240, 240, 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true // to prevent stretches
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        //tv.backgroundColor = .red
        return tv
    }()
    
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        // auto layout constraints to safe area >>> view.safeAreaLayoutGuide.topAnchor
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor,
                             paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                             width: 0, height: 100)
        
        // add image insid container view
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil,
                         paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0,
                         width: 84, height: 0) // 100 - ( 8 + 8 paddings ) = 84 .... to make it perfect square
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor,
                        paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0,
                        width: 0, height: 0)
    }
    
    @objc func handleShare() {
        // print("Sharing Photo")
        guard let caption = textView.text, caption.count > 0 else {return}
        guard let image = selectedImage else { return } // to get the image from selected image to upload it
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return } // to upload the image as data
        
        //disable share button >>> so after click share the button will diabled except if its not succesfully shared
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString // random uique string for images
        let storageRef = Storage.storage().reference().child("posts").child(filename+".jpg")
            
        storageRef.putData(uploadData, metadata: nil) { (metadata, err ) in
            if let err = err {
                // if its not succesfully shared .. re enabled the share button
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to Upload post image : ", err)
                return
            }
            
        storageRef.downloadURL { (url, error) in
            guard let postImageUrl = url else {
                print("Failed to get profile image url : ", error ?? "")
                return
            }
            
            print("Successfully uploaded image : ", postImageUrl)
            
            // refactor for more clean code
            self.saveToDatabaseWithImageUrl(imageUrl: "\(postImageUrl)")
            
            
            }
        }
    }
    
    // to make to accessable outside this sharePhotoController
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")

    // refactor for more clean code
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        // we also need to capture the size of image to maintain the aspect ratio in the news feed
        guard let postImage = selectedImage else {return}
        
        guard let caption = textView.text else {return}
        
        guard let uid = Auth.auth().currentUser?.uid else {return }
        let userPostRef = Database.database().reference().child("posts").child(uid)
        // list of items with random unique id >> child by auto id
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl": imageUrl,
                      "caption": caption,
                      "imageWidth": postImage.size.width,
                      "imageHeight": postImage.size.height,
                      "creationDate": Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                // if its not succesfully shared .. re enabled share button
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to DB: ", err)
                return
            }
            
            print("Successfully saved post to BD")
            // after sharing the post .. dismiss
            self.dismiss(animated: true, completion: nil)
            
            // every time share post .. it will auto refresh home controller ( observer design pattern )
            NotificationCenter.default.post(name: SharedPhotoController.updateFeedNotificationName, object: nil)
            
        }
    }
    
    // hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
