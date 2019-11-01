//
//  UserSearchController.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/19/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
import Firebase

// protocol >> UISearchBarDelegate for search filter
class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let cellId = "cellId"
    
    // search bar
    lazy var searchBar: UISearchBar = { // use lazy var instead of let to access self
        let sb = UISearchBar()
        sb.placeholder = "Search"
        sb.barTintColor = .gray
        // the color didnt change .. to change the appearance you have to do this
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(white: 0, alpha: 0.1)
        // to make search filter
        sb.delegate = self
        return sb
    }()
    
    //search filtering feature
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //print(searchText)
        
        if searchText.isEmpty {
            filteredUsers = users
        }else {
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased()) // to make all names lower case
            }
        }
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        // add search bar to navigation controller
        navigationController?.navigationBar.addSubview(searchBar)
        // search bar wont show up ... you have to anchor it to have a frame
        let navBar = navigationController?.navigationBar
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor,
                         paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8,
                         width: 0, height: 0)
        
        // registeration for our cells
        collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        // it will allow you to bounce the collection view up and down if it didnt fill the screen
        collectionView.alwaysBounceVertical = true
        // so every time i drag the collectionView ... it going to dismmis the keyboard
        collectionView.keyboardDismissMode = .onDrag
        
        // get the list of users
        fetchUsers()
        
    }
    
    // to make seach bar appear when return to search screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    var filteredUsers = [User]() //after filter search the master list disappear
    var users = [User]()
    
    fileprivate func fetchUsers() {
        print("Fetching users ...")
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value ?? "")
            guard let dictionaries = snapshot.value as? [String: Any] else {return}
            
            // forEach .. like loop all dictionaries in iterations
            dictionaries.forEach({ (key, value) in
                
                // remove mySelf from the list
                if key == Auth.auth().currentUser?.uid {
                    print("Found mySelf, omit from list")
                    return
                }
                
                //print(key, value)
                
                guard let userDictionary = value as? [String: Any] else {return}
                let user = User(uid: key, dictionary: userDictionary)
                //print(user.uid, user.username)
                self.users.append(user)
            })
            
            // to make alphabetical order
            self.users.sort(by: { (u1, u2) -> Bool in // user 1 and user 2
                return u1.username.compare(u2.username) == .orderedAscending
            })
            
            self.filteredUsers = self.users
            self.collectionView.reloadData()
            
        }) { (err) in
            print("Failed to fetch users for search : ", err)
        }
    }
    
    // COLLECTION VIEW FUNCTIONS -----------------------------------------------------------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        //cell.backgroundColor = .red
        cell.user = filteredUsers [indexPath.item]
          
        return cell
    }
    
    // protocol ... CollectionView Delegate FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: 66) // 66 bec image is 50 + 8 top padding + 8 bottom padding
    }
    
    // do something when i click the item
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.item]
          print("you clicked on : ",user.username)
        
        searchBar.isHidden = true
        // make the keyboard disapear when going to userprofile
        searchBar.resignFirstResponder()
        
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    
}
