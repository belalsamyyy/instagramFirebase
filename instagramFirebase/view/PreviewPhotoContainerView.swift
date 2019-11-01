//
//  PreviewPhotoContainerView.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/25/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
// photos sdk >>> to save image to images album
import Photos


class PreviewPhotoContainerView: UIView {
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "save").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = .yellow
        
        addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor , right: rightAnchor,
                                paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                                width: 0, height: 0)
        
        setupButtons()

    }
    
    @objc func handleCancel() {
        print("dismiss camera ...")
        self.removeFromSuperview()
    }
    
    @objc func handleSave() {
        print("handling save ...")
         
        // to get the captured image
        guard let previewImage = previewImageView.image else { return }
        
        // get reference to image library
        let library = PHPhotoLibrary.shared()
        
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage )
        }) { (success, err) in
            if let err = err {
                print("Failed to save image to photo library : ", err)
                return
            }
            print("Successfully saved image to library")
            
            // to add the label at the same main thread
            DispatchQueue.main.async {
                
                // saved successfully ui feedback
                let savedLabel = UILabel()
                savedLabel.text = "Saved Successfully"
                savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                savedLabel.textColor = .white
                savedLabel.numberOfLines = 0 // TO MAKE THE WHOLE TEXT APPEAR IN 2 LINES IF NECESSARY
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.textAlignment = .center
                
                // we need to add frame to make it appears
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = self.center
                
                self.addSubview(savedLabel)
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                // ADD ANIMATION ...
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0,
                               options: .curveEaseOut, animations: {
                                
                savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                                
                }) { (completed) in
                    
                    // add another animation inside the completion
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5,
                                   options: .curveEaseOut, animations: {
                                    
                    savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                    savedLabel.alpha = 0
                                    
                    }) { (_) in
                        savedLabel.removeFromSuperview()
                    }
                }
            }
            
        }
    }
    
    fileprivate func setupButtons() {
        // dismiss button
        addSubview(cancelButton)
        cancelButton .anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil,
                                  paddingTop: 12, paddingLeft: 12, paddingBottom: 0  , paddingRight: 0,
                                  width: 50, height: 50)
        // save button
        addSubview(saveButton)
        saveButton.anchor(top: nil , left: leftAnchor, bottom: bottomAnchor, right: nil,
                                  paddingTop: 0, paddingLeft: 24, paddingBottom: 24  , paddingRight: 0,
                                  width: 50, height: 50)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
