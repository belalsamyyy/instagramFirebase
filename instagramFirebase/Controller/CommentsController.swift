//
//  CommentsController.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/26/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CommentInputAccessoryViewDelegate {
   
    // to pass the value of the specific post i tapped comments icon for ... from home controller
    var post: Post?
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        // keyboard dismiss trick
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        // to make the the comment collection view fill the screen except the ( 50 height of the container view )
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        // add title to nav controller
        navigationItem.title = "Comments"
        
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchComments()

    }
    
       /*
    let commentTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Enter Comment"
            return textField
        }()
 
 */
    
    /*
    @objc func handleSubmit() {
           //print("post id : ", self.post?.id ?? "" )
           //print("Inserting comment : ", commentTextField.text ?? "")
           
           guard let uid = Auth.auth().currentUser?.uid else { return }
           
           let postId = self.post?.id ?? ""
           let values = ["text": commentTextField.text ?? "",
                         "creationDate": Date().timeIntervalSince1970,
                         "uid": uid] as [String : Any]
           
           
           Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
               if let err = err {
                   print("Failed to insert comment : ", err)
                   return
               }
               print("Successfully inserted comment ...")
           }
       }
 */
    
    
    var comments = [Comment]()
    
    fileprivate func fetchComments() {
        print("fetching comments ... ")
        guard let postId = post?.id else { return }
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(.childAdded, with: { (snapshot) in

            //print(snapshot.value ?? "")
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            // to get the user from the comment
            guard let uid = dictionary["uid"] as? String else { return }
            Database.fetchUserWithUID(uid: uid) { (user) in
                // now we have access to this particular user ...
                let comment = Comment(user: user, dictionary: dictionary)
                //comment.user = user
                self.comments.append(comment)
                self.collectionView.reloadData()
            }
            
        }) { (err) in
             print("Failed to observe comments")
        }
    }
    
    // ------------------- collection view funcs ---------------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = self.comments[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // dynamic cell sizing
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dynamicCell = CommentCell(frame: frame)
        dynamicCell.comment = comments[indexPath.item]
        dynamicCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000) // make the height very big
        let estimatedSize = dynamicCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40+8+8, estimatedSize.height) // 40 imageview + 8 padding top + 8 padding bottom
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // to remove the spacing/gaps between the cells
        return 0
    }
    
    // to fix bug .. when swipe back and return quickly the tab bar appears in comments section
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // to remove the tab bar
          tabBarController?.tabBar.isHidden = true
    }
    
    // every time we dismiss .. make tab bar appears again
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // to give the container view a reference ... to be able write on it
    // we use lazy var so we can access commentTextField with self property
    lazy var containerView: CommentInputAccessoryView = {
        // get ref to comment input accessory view
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    
      /*
      let containerView = UIView()
      containerView.backgroundColor = . white
      // container view .. need to have a frame to appears
      containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
      return containerView
 */

    }()
    
    func didSubmit(for comment: String) {
        print("Trying to insert comment into firebase")
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let postId = self.post?.id ?? ""
        let values = ["text": comment,
                      "creationDate": Date().timeIntervalSince1970,
                      "uid": uid] as [String : Any]
        
        let ref = Database.database().reference().child("comments").child(postId).childByAutoId()
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to insert comment : ", err)
                return
            }
            print("Successfully inserted comment ...")
            self.containerView.clearCommentTextField()
        }
     }
    
    // every page in ios has "input accessory view " allows you to type in information
     
    /* the huge advantage to use this approach that .. now you dont have to manage the location of your views
    based on the sizing of your keyboard .. and you just allow ui kit to do all the work for you */
    
    override var inputAccessoryView: UIView? {
        get {
          return containerView
        }
    }
    
    // to make input accessory view appears we have to do this
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
}
