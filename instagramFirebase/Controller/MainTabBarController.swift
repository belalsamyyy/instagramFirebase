//
//  MainTabBarController.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/8/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
import Firebase
// custom tab bar"

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // first >> disable the selection of plus icon to show something custom
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        //print(index ?? "")
        if index == 2 {
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            // to add nav bar at the top to cancel or dismiss
            let navController = UINavigationController(rootViewController: photoSelectorController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
            return false
        }
        return true
    }
  
    
    // every time you want to override lifecycle important methods ..
    // you have to call the super version of it to make it work correctly
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // delegate
        self.delegate = self
        
        // check if there is user of not >>> show if not logged in
        if Auth .auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                loginController.modalPresentationStyle = .fullScreen
                let navController = UINavigationController(rootViewController: loginController)
                //self.present(loginController, animated: true, completion: nil)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)

            }
            return
        }
        
        //let redVC = UIViewController()
        //redVC.view.backgroundColor = .red
        
        //let userProfileController = UserProfileController() >>> it will crash .. you need it to be un nil
        
        setupViewControllers()
    }
    
    // refactor >>> put the code in func 
    func setupViewControllers() {
        
        // home ---------------------------------------------------------------------------------------
        let homeNavController = templateNavController(unselected: #imageLiteral(resourceName: "home_unselected"), selected: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout() ))
    
        // search ---------------------------------------------------------------------------------------
        let searchNavController = templateNavController(unselected: #imageLiteral(resourceName: "search_unselected"), selected: #imageLiteral(resourceName: "search_selected"), rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout() ))

    
        // plus ---------------------------------------------------------------------------------------
        let plusNavController = templateNavController(unselected: #imageLiteral(resourceName: "plus_unselected"), selected: #imageLiteral(resourceName: "plus_unselected"))

        
        // like ---------------------------------------------------------------------------------------
        let likeNavController = templateNavController(unselected: #imageLiteral(resourceName: "like_unselected"), selected: #imageLiteral(resourceName: "like_selected"))

        
        // user profile --------------------------------------------------------------------------------
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        
        let userProfileNavController = UINavigationController(rootViewController: userProfileController)
        // to put icons in tab bar
        userProfileNavController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected") // image invisible bec dark mode
        userProfileNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        // remove titletext and get center icon
        userProfileNavController.tabBarItem.title = nil
        userProfileNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 6,left: 0,bottom: -6,right: 0)
        tabBar.tintColor = .black
        
        // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, userProfileNavController]
        //viewControllers = [navController, UIViewController()]
        
        guard let items = tabBar.items else { return }
        // modify tab bar item insets
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
        
    }
    
    fileprivate func templateNavController(unselected: UIImage, selected: UIImage,
                                           rootViewController: UIViewController = UIViewController() ) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselected
        navController.tabBarItem.selectedImage = selected
        return navController
    }
}
