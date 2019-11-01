//
//  CustomImageView.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/14/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

// refactor
import UIKit

// we need empty array to cashe the images <<<<<<<<<<<
var imageCache = [String: UIImage]()


class CustomImageView: UIImageView {
    
    var lastURLusedToLoadImage: String?  // it has to be optional ... bec you starting off as nil
    
    // func get image from url
    func loadImage(urlString: String) {
        //print("Loading image ...")
        
        // it will fix alittle bit the flickering whenever you update the images using this method
        self.image = nil
        
        // check cache for the image and is there is one use it and avoid URLSession task
        
        // if the imageChache array have value with the same urlString key it will use the cached image instead of fetch the image agian
        // it will avoid all unnecessairy fetching code
        if let cachedImage = imageCache[urlString] { 
            self.image = cachedImage
            return
        }
        
        // every time i'm trying to load a different image .. using this image view .. i'm going to set last url image used to that url string
        lastURLusedToLoadImage = urlString
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch post image :", err)
                return
            }
            
            // -----------------------------------------------------------------------------------------------------------------------------
            // solution for : problem happens .. bec we reload data for collection view twice at fetch user and fetch posts >>> so images repeating
            // that will prevent the images from loading incorrectly
            
            /* that means >>> if they're not equal ..
             then we're not going to set the (photoImageView) with the image being retreived from the (data) inside this (URLSession) */
            
             // if url.absoluteString != self.post?.imageUrl {
            if url.absoluteString != self.lastURLusedToLoadImage { // this will prevent the image to laod twice again 
                return
            }
            // -----------------------------------------------------------------------------------------------------------------------------

            
            // we get image as data .. so we need to cast it into UIImage
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            
            // Once i get photo image outside my data object .. i'm going to put it inside my cache array <<<<<<<<<<<<<<
            imageCache[url.absoluteString] = photoImage
            
            // execute all of this in the main thread
            DispatchQueue.main.async {
                // set the image value to our image view
                self.image = photoImage
            }
            }.resume() // without .resume() nothing will happend .. dont forget to write it
        
        
    }
    
}
