//
//  LoginController.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/10/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let logoContainerView: UIView = {
        let view = UIView()
        
        // add logo image inside the view
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        //logoImageView.backgroundColor = .red
        view.addSubview(logoImageView)
        
        // anchor instagram logo
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil,
                             paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                             width: 250, height: 50)
        // center the logo inside the view
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.backgroundColor = UIColor.rgb(0, 120, 175)
        return view
    }()
    
    // create email textfield programmatically
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        //tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    
    // create password textfield programmatically
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true // bec its password
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03) // zero means complete black with low alpha
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    // create Login Button programmatically
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor.rgb(149, 204, 244) // using extension
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc func handleLogin() {
        //print(123)
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            let userId = user?.user.uid // TO GET THE USER ID
            if let err = err {
                print("Failed to sign in with email : ", err)
            } 
            print("Successfully Logged back in with user : ", userId ?? "")
            
            // to solve the problem of reload the ui to set the new user info by access the rootViewController to call the func when press login 
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle =
            NSMutableAttributedString(string: "Dont have an account? ", attributes:
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                 NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up.", attributes:
            [NSAttributedString.Key.foregroundColor: UIColor.rgb(17, 154, 237),
             NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleDontHaveAccount), for: .touchUpInside)
        return button
    }()
    
    @objc func handleDontHaveAccount() {
        let signUpController = SignUpController()
        signUpController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    // change status bar style >>> to white color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // func for handle text input change
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(17, 154, 237)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(149, 204, 244) // using extension
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = .white
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                            width: 0, height: 50)
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor,
                                 paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                                 width: 0, height: 150)
        
        setupInputFields()

    }
    
    fileprivate func setupInputFields() {
        let stackview = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackview.distribution = .fillEqually
        stackview.axis = . vertical
        stackview.spacing = 10
        view.addSubview(stackview)
        stackview.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor,
                                 paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40,
                                 width: 0, height: 140)
        // trick : the height is 140 because .. 40 + 40 + 40 for textfields and button + remaining 20 for 10 + 10 spacing >>> do the math
    }
    
}
