//
//  PhotoSelectorController.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/12/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit
import Photos // photos framework to get the photos on your device

// 4. we use ( UICollectionViewDelegateFlowLayout ) >> to able to conform sizing methods to our collection view cells >>> size for item
class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
    
        setupNavigationButtons()
        
        // 1. registering custom cells inside my collection view controller
        // update : replace UICollectionViewCell with PhotoSelctorCell
        collectionView.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        
        // 8. we need to register custom header at the top of photo selector >>> supplementry view of kind
        // update : replace UICollectionViewCell with PhotoSelectorHeader
        collectionView.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        // fetch photos framework
        fetchPhotos()
    }
    
    // 12.  method to handle the selection of the cells inside our collection view
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        self.collectionView.reloadData()
        //print(selectedImage)
        //print(indexPath)
        
    // to auto scroll to the top when select image
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        
    }
    
    var selectedImage: UIImage?
    var images = [UIImage]() // This syntax means >> give me an empty image array
    
    // we want to refetch the images in larger size version to show it when selected
    var assets = [PHAsset]()
    
    // some refactor to make our code more simple and cleaner
    fileprivate func assetFetchOptions() -> PHFetchOptions {
        //print("fetching photos")
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 300
        
        // to make the last image in the phone first
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetFetchOptions() )
        
        // it hangs until all the photos loading first then open the photo selector + the header photo blurry and lower quality
        // solution >>> put all the works in some kind of background threads so the ui doesnt hang
        DispatchQueue.global(qos: .background).async {
            // put all the code here
            allPhotos.enumerateObjects { (asset, count, stop) in
                //print(count )
                //print(asset)
                let imageManager = PHImageManager.default()
                // fetching images in very small size which is enough to fill small grids and we will get really fast respond
                let targetSize = CGSize(width: 200, height: 200)
                
                // we notice that the size of images not always correct so we need to add options
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    // put images in images array
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        // so the in each iteration adding images the selected image value changes to the latest image and wont be empty
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    
                    // we want to call that every time i finish fetching all of my images
                    if count == allPhotos.count - 1 {  // -1 >>> bec it stars from 0
                        
                        // always when you're in background thread you need to back to main thread
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                    //print(image ?? "")
                })
            }
        }
        
        
    }
    
    
    // 11. add spacing line after header >>> inset section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    // 10. the header will not show .. bec you need first to give it reference size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width) // >>> to make it perfect square
    }
    
    var header: PhotoSelectorHeader?
    
    // 9. method to render the header for us >>> view for supplementry element
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        
        self.header = header
        header.photoImageView.image = selectedImage // ?? images[0]

        
        if let selectedImage = selectedImage {
            if let index = self.images.firstIndex(of: selectedImage) {
                let selectedAsset = self.assets[index]
                let targetSize = CGSize(width: 600, height: 600)
                
                let imageManager = PHImageManager.default()
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    header.photoImageView.image = image
                    
                    /*let sharePhotoController = SharedPhotoController()
                    sharePhotoController.selectedImage = image*/
                }
            }
        }
        
        return header
    }
    
    // 2. to return couple of cells here >>> number of items
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    // 3. cell for item >>> to make the cells appears
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell // cast it to our custom cell
        cell.photoImageView.image = images[indexPath.item]
        return cell
    }
    
    // provide some sizing to the cells to look better ----------------------------------------------------------------------------
    
    // 5. size for item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ( view.frame.width - 3 ) / 4
        return CGSize(width: width, height: width)
    }
    
    // 6. reduce vertical spacing between cells >>> minimum line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // 7. reduce horizontal spaceing between cells >>> minimum inter item spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    
    // to hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupNavigationButtons() {
        // target >> self is the entire class that the selector need to be called on
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel) )
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext) )
        navigationController?.navigationBar.tintColor = .black
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNext() {
        //print("handling next")
        // we need to push on to navigation controller stack in new controller
        let sharedPhotoController = SharedPhotoController()
        sharedPhotoController.selectedImage = header?.photoImageView.image
        navigationController?.pushViewController(sharedPhotoController, animated: true)
    }
    
    
}
