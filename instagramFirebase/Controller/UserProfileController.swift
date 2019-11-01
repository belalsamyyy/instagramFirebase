//
//  UserProfileController.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/8/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
import Firebase

// UICollectionViewDelegateFlowLayout >>> to give size for header
//4
class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    let headerId = "headerId"
    
    var userId: String?
    var isGridView = true // bec grid is default
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
     
    override func viewDidLoad() {
        super .viewDidLoad()
        
        //view.backgroundColor = .green
        collectionView.backgroundColor = .white
        
        // to access current user id
        /*
        let userId = Auth.auth().currentUser?.uid
        navigationItem.title = userId*/
        
        // navigationItem.title = "username"

        //HEADER
        //collectionView?.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        
        // we use UserProfileHeader instead of UICollectionViewCell
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        // we will create custom cell ( UserProfilePhotoCell )instead of UICollectionViewCell
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        // manual automatic post refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl

        fetchUser()

        // log out
        setupLogoutButton()
        
        //fetchPosts()
        //fetchOrderedPosts()
        
    }
    
    
    var user: User?
    // file privete >> this fetch user func will be only acessible inside of this user profile controller
    fileprivate func fetchUser() {
        
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
            //self.fetchOrderedPosts()
            self.paginatePosts()
        }
    }

    
    @objc func handleRefresh() {
        print("paginate by refresh ")
        self.paginatePosts()
    }
    
    var isFinishedPaging = false
    
    // create empty array for posts
    var posts = [Post]()
    
    // pagination
    fileprivate func paginatePosts() {
        print("Start paging for more posts")
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        
        // make the refresh stop
        self.collectionView.refreshControl?.endRefreshing()
        
        // let value = "-Lr9SybL8eepO01rNnin"
        // let query = ref.queryOrderedByKey().queryStarting(atValue: value).queryLimited(toFirst: 5)
        
        //var query = ref.queryOrderedByKey()
        var query = ref.queryOrdered(byChild: "creationDate") // using creationDate as a sorting key
        
        if posts.count > 0 {
            // let value = posts.last?.id
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
            // query = query.queryStarting(atValue: value)
        }
        
        query.queryLimited(toLast: 11).observeSingleEvent(of: .value, with: { (snapshot) in
            // all objects >> contains all reamaing objects in numerating order
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.reverse() // to reverse ordering
            
            if allObjects.count < 11 {
                self.isFinishedPaging = true
            }
            
            // to removing the first repeating image after every 4 images
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects .removeFirst()
            }
            
            guard let user = self.user else { return  }
            
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key
                
                self.posts.append(post)
                //print(snapshot.key)
            })
            
            self.posts.forEach { (post) in
                print(post.id ?? "")
            }
            
            // reload data
            self.collectionView.reloadData()
            
        }) { (err) in
            print("Failed to paginate for posts : ", err)
        }
    }
    
    fileprivate func fetchOrderedPosts() {
        print("fetch ordered posts")
        guard let uid = self.user?.uid else {return}
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        
            // observe is different from observe single event ...
            // perhaps later on we'll implement some pagination of date
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in  // add queryOrdered by child >>> to order our posts
                //print(snapshot.key, snapshot.value ?? "")
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                guard let user = self.user else {return}
                let post = Post(user: user, dictionary: dictionary)
                //self.posts.append(post)
                self.posts.insert(post, at: 0)
                // reload collection view after adding the new post to posts array
                self.collectionView.reloadData()
                
            }) { (err) in
                print("Failed to fetch ordered posts : ", err)
                return
            }
        }
    
    
    /*fileprivate func fetchPosts() {
        // print("fetch posts")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        ref.observe(.value, with: { (snapshot) in
            //print(snapshot.value ?? "")
            
            // cast snap shot value into something we can use
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
            //print("key: \(key) \nvalue: \(value)")
                
            // now we could get value >> so we can use it to get data
            guard let dictionary = value as? [String: Any] else { return }
                //let imageUrl = dictionary["imageUrl"] as? String
                //print("imageUrl: \(imageUrl ?? "")")
                guard let user = self.user else {return}
                let post = Post(user: user, dictionary: dictionary)
                //print(post.imageUrl)
                
                // set the value inside the post array
                self.posts.append(post)
            })
            
            // after get all posts in every iteration >>> reload the collection view
            // problem happens .. bec we reload data for collection view twice at fetch user and fetch posts
            self.collectionView.reloadData()
            
        }) { (err) in
            print("Failed to fetch posts : ",err)
        }
    }
 */
    
    fileprivate func setupLogoutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout) )
    }
    
    
    @objc func handleLogout() {
        //print("logging out")
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            //print("Perform Log out")
            do {
                try Auth.auth().signOut()
                // what happens? we need to present some kind of login controller
                let loginController = LoginController()
                // to do it with navigation controller >> bec we may potentailly push registration controller
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                 
            } catch let signOutErr{
                print("Failed to sign out : ",signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            print("Perform cancel")
        }))
        present(alertController, animated: true, completion: nil)
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return 7
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /*
        
         /* the logic says .. if we reach the last cell and if we're not finish paging ...
            we will continue the process of pagination */
         
        if indexPath.item == self.posts.count - 1 && !isFinishedPaging {
            print("pagination for posts")
            paginatePosts()
        }
 
 */
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            //cell.backgroundColor = UIColor(white: 0, alpha: 0.1)
            cell.post = posts[indexPath.item]
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
    }
    
    
    // horizontal spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    // vertical spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            
            let width = view.frame.width
            // 40 for userprofile image + 8 for top padding + 8 for bototm padding ( username + userfprofileImageView)
            
            var height: CGFloat = 40 + 8 + 8
            height += width // for the post image height
            height += 50 // for the bottom part height
            height += 60 // for caption section height
            
            return CGSize(width: width, height: height)
        }
    }
    
    
    // header
     override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
         let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        // to add view to our header
        // header.addSubview(UIImageView()) >>> not correct
        //header.backgroundColor = .green
        header.user = self.user
        //5
        header.delegate = self
        return header
    }
    
    
    // size for header >>> dont miss the protocol
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
/*
     var user: User?
     // file privete >> this fetch user func will be only acessible inside of this user profile controller
     fileprivate func fetchUser() {
     guard let uid = Auth.auth().currentUser?.uid else { return }
     Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
     //print(snapshot.value ?? "")
     
     guard let dictionary = snapshot.value as? [String: Any] else {return}
     //let profileImageUrl = dictionary["image"] as? String
     //let username = dictionary["username"] as? String
     
     self.user = User(uid: uid, dictionary: dictionary)
     
     self.navigationItem.title = self.user?.username
     
     // problem happens .. bec we reload data for collection view twice at fetch user and fetch posts
     self.collectionView?.reloadData()
     
     }) { (err) in
     print("Failed to fetch user : ",err)
     }
     }
     }
    
*/
    
}
    


