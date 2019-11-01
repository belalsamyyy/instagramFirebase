//
//  HomeController.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/15/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
import Firebase
//5 >>> homePostCellDelegate
class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
   
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        // every time share post .. it will auto refresh home controller ( observer design pattern )
        //let name = NSNotification.Name(rawValue: "UpdateFeed")
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharedPhotoController.updateFeedNotificationName, object: nil)
        
        // register cell for collection view
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.register(HomeStoriesHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        // manual automatic post refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        // navigation bar
        setupNavigationItems()
        
        // get posts
        //fetchPosts()

        /* to get the posts of following users
        Database.fetchUserWithUID(uid: "Yv9s9ihUvSQl6lWlT1gU2fL4Ta62") { (user) in
            self.fetchPostsWithUser(user: user)
        }*/
        
        //fetchFollowingUsersIds()
        
        fetchAllPosts()
    }
    
    
    @objc func handleUpdateFeed() {
            handleRefresh()
    }
    
    @objc func handleRefresh() {
        print("Handling refresh ...")
        // to fix the bugs of repeating posts and unfollowed users posts
        // still remains >> so we empty the posts array every time refresh
        posts.removeAll()
        fetchAllPosts()
    }
    
    //refactor
    fileprivate func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUsersIds()
    }
    
    
    var posts = [Post]() // create empty array for posts
    
    /* note : we didnt use childAdded
    bec it will reload the collection view every time some one post new image and it will ruin the user experience */
    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // use the completion closure
        Database.fetchUserWithUID(uid: uid) { (user) in
            print("Finished fetching user ....")
            // refactor the code into 2 seperate functions
            self.fetchPostsWithUser(user: user)
        }
    }
 
    
    
    fileprivate func fetchFollowingUsersIds() {
        // get the list of following users ...
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value ?? "")
            
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            userIdsDictionary.forEach({ (key, value) in
                //print(key, value)
                Database.fetchUserWithUID(uid: key) { (user) in
                    self.fetchPostsWithUser(user: user)
                }
            })
            
        }) { (err) in
            print("Failed to fetch following users ids : ", err)
        }
    }
    
    
    fileprivate func fetchPostsWithUser(user: User) {
        // fetch post -----------------------------------------------------------------------------
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // make the refresh stop
            self.collectionView.refreshControl?.endRefreshing()
            
            // cast snapshot value into something we can use
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                // now we could get value >> so we can use it to get data
                guard let dictionary = value as? [String: Any] else { return }
                
                //let dummyUser = User(dictionary: ["username": "Belal"])
                var post = Post(user: user, dictionary: dictionary)
                
                // set the post id to the value of the key .. so we can use it for comments
                post.id = key
                
                // likes
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    //print(snapshot)
                    
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    
                   // set the value inside the post array
                   self.posts.append(post)
                    
                   // make posts ordered by creation date
                   self.posts.sort(by: { (p1, p2) -> Bool in
                   return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                   })
                    
                   // after get all posts in every iteration >>> reload the collection view
                   self.collectionView.reloadData()
                    
                }, withCancel: { (err) in
                    print("Failed to fetch like info for post", err)
                })
            })
        
        }) { (err) in
            print("Failed to fetch posts : ",err)
        }
    }
    
    
    // navigation bar
    fileprivate func setupNavigationItems() {
        
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "instagram_logo_black"))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: nil)
    }
    
    
    @objc func handleCamera() {
        print("Showing camera")
        // to show the camera
        let cameraController = CameraController()
        cameraController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        present(cameraController, animated: true, completion: nil)
    }
    
    
    /* ----------------------------- collection view header funcs -----------------------------------------------
    
    // header
     override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
         let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! HomeStoriesHeader
        return header
    }
    
    // size for header >>> dont miss the protocol
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
 */
    
    
    // ----------------------------- collection view funcs ------------------------------------------------------
    
    // number of cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    // reusable cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.item]
        //4
        cell.delegate = self
        return cell
    }
    
    //6
    func didTapComment(post: Post) {
        print("Message coming from home controller")
        print(post.caption)
        
        // bec its collection view controller .. you have to specify collection view layout
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        
        commentsController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        //print("handling like inside of controller ...")
        // to get the index path for the cell
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        var post = self.posts[indexPath.item]
        //print("like for : ",post.caption)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = post.id else { return }
        
        // if it was true and click on it make it 0 / if it false make it 1
        let values = [uid: post.hasLiked == true ? 0 : 1]
        
        let ref = Database.database().reference().child("likes").child(postId)
        ref.updateChildValues(values) { (err, _) in
            if let err = err {
                print("Failed to like post : ", err)
                return
            }
            print("Successfully liked post. ")
            
            // when click on like button ... it will turn to the opposite value (true/false)
            post.hasLiked = !post.hasLiked
            
            // fix the bug .. when click nothing changes ...
            // bec whenever u get the post object outside the array .. u actually get a different reference for the post
            self.posts[indexPath.item] = post
            
            self.collectionView.reloadItems(at: [indexPath]) // it will only update the cell we like
        }

       }
    
    // to change cell size + u need to conform protocol first >>> UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        var height: CGFloat = 40 + 8 + 8  // 40 for userprofile image + 8 for top padding + 8 for bototm padding ( username + userfprofileImageView)
        height += width // for the post image height
        height += 50 // for the bottom part height
        height += 60 // for caption section height
        return CGSize(width: width, height: height)
    }

}
