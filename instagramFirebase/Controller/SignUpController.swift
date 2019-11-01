//
//  ViewController.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/6/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     
    // create button programmatically
    let plusPhotoButton: UIButton = {  // open closure
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        //>>> if you wanted the original color of image
        //button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        //button.backgroundColor = .red
        //button.translatesAutoresizingMaskIntoConstraints = false // to make auto layout works
        
        // add action >>> add target
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        
        return button
    }() // execute this closure block
    
    @objc func handlePlusPhoto() {
        //print(123)
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        // to make it circle
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        //print(originalImage?.size ?? 0, editedImage?.size ?? 0)
        dismiss(animated: true, completion: nil)
    }
    
    // create email textfield programmatically
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        //tf.translatesAutoresizingMaskIntoConstraints = false // to make auto layout works
        //tf.backgroundColor = UIColor.lightGray
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03) // zero means complete black with low alpha
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        // add action
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    
    // func for handle text input change
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && userNameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(17, 154, 237)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(149, 204, 244) // using extension
        }
    }
    
    
    // create username textfield programmatically
    let userNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        //tf.translatesAutoresizingMaskIntoConstraints = false // to make auto layout works
        //tf.backgroundColor = UIColor.lightGray
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03) // zero means complete black with low alpha
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)

        return tf
    }()
    
    
    // create password textfield programmatically
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true // bec its password
        //tf.translatesAutoresizingMaskIntoConstraints = false // to make auto layout works
        //tf.backgroundColor = UIColor.lightGray
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03) // zero means complete black with low alpha
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)

        return tf
    }()
    
    
    // create signUp Button programmatically
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        //button.backgroundColor = .blue
        //button.backgroundColor = UIColor(displayP3Red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.backgroundColor = UIColor.rgb(149, 204, 244) // using extension
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        // add action when clicks
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    
    // func for handle sign up action when clicks
    @objc func handleSignUp() {
        guard let email = emailTextField.text, email.count > 0  else { return }
        guard let username = userNameTextField.text, username.count > 0  else { return }
        guard let password = passwordTextField.text, password.count > 0  else { return }
        //let email = "belalsamy10@gmail.com"
        //let password = "123123"
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            let userId = user?.user.uid // TO GET THE USER ID
            if let err = error {
                print("Failed To Create User : ", err)
                return
            }
            print("Successfully Created User : ", userId ?? "" )
            
            // store image in firebase storage
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
            
            let filename = NSUUID().uuidString // random uique string for images
            let storageRef = Storage.storage().reference().child("profile_images").child(filename+".jpg")
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                if let err = err {
                    print("Failed to upload profile image : ", err)
                    return
                }
                
            storageRef.downloadURL { (url, error) in
                guard let profileImageUrl = url else {
                    print("Failed to get profile image url : ", error ?? "")
                    return
                }
                
                //let profileImageUrl = metadata.downloadURL
                print("Successfully uploaded profile image : ", profileImageUrl)
                
                // store user info into real time database
                guard let uid = userId else { return }
                let userInfoValues = ["username": username, "email": email, "image": "\(profileImageUrl)"]
                let values = [uid: userInfoValues] // dictionary
                
                // adding new user without removing the other users
                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if let err = err {
                        print("Failed to save user info into db : ", err)
                        return
                    }
                    
                    print("Successfully saved user info to db")
                    // to solve the problem of reload the ui to set the new user info by access the rootViewController to call the func when press sign up
                    guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                    mainTabBarController.setupViewControllers()
                    
                    self.dismiss(animated: true, completion: nil)
                })
                
            }
        })
        
            
            //-----------------------------------------------------------------------------------------------------
            // problem - when we add new user removes all users and replace them
            /*Database.database().reference().child("users").setValue(values, withCompletionBlock: { (err, ref) in
                
                if let err = err {
                    print("Failed to save user info into db : ", err)
                    return
                }
                
                print("Successfully saved user info to db")
                
            })*/
        }
    }
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle =
            NSMutableAttributedString(string: "Already have an account? ", attributes:
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                 NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign In.", attributes:
            [NSAttributedString.Key.foregroundColor: UIColor.rgb(17, 154, 237),
             NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    @objc func handleAlreadyHaveAccount() {
        /*let loginContoroller = LoginController()
        navigationController?.pushViewController(loginContoroller, animated: true) */
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                            width: 0, height: 50)
        
        
        
        // auto layout for add photo button
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil,
                               bottom: nil, right: nil,
                               paddingTop: 40, paddingLeft: 0,
                               paddingBottom: 0, paddingRight: 0,
                               width: 140, height: 140)
        
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true // center
        /*plusPhotoButton.heightAnchor.constraint(equalToConstant: 140).isActive = true
        plusPhotoButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plusPhotoButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true*/
        
        // ------ photo button without auto layout ----------------------------
        //plusPhotoButton.frame = CGRect(x: 0, y: 0, width: 140, height: 140)
        //plusPhotoButton.center = view.center
        
        // auto layout for email text field
        // view.addSubview(emailTextField)
        
        setupInputFields() // <<< stackView
        
    }
    
    // quicker way to make the rest of textfields with (stack view)
    fileprivate func setupInputFields() {
        
        //let greenView = UIView()
        //greenView.backgroundColor = .green
        
        //let redView = UIView()
        //redView.backgroundColor = .red
        
        let stackview = UIStackView(arrangedSubviews: [
            emailTextField, userNameTextField, passwordTextField, signUpButton])
        
        //  stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.distribution = .fillEqually // to make the red veiw appears
        stackview.axis = . vertical // to make green and red view vertical
        stackview.spacing = 10 // to make space between green and white
        
        view.addSubview(stackview)
        
        // to acitvate all of this code >>>
        /*NSLayoutConstraint.activate([
            //stackview.topAnchor.constraint(equalTo: plusPhotoButton.bottomAnchor, constant: 20),
            stackview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            stackview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            stackview.heightAnchor.constraint(equalToConstant: 200)
            ])*/
        
        stackview.anchor(top: plusPhotoButton.bottomAnchor , left: view.leftAnchor,
                         bottom: nil, right: view.rightAnchor,
                         paddingTop: 20, paddingLeft: 40,
                         paddingBottom: 0, paddingRight: 40,
                         width: 0, height: 200)
    }
}



