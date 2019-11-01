//
//  CommentInputTextView.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/28/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {
        
    fileprivate let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter Comment"
        label.textColor = .lightGray
        return label
    }()
    
    // public method to access private  
    func showPlaceholderLabel() {
        placeholderLabel.isHidden = false
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange),
                                               name: UITextView.textDidChangeNotification, object: nil)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                                paddingTop: 8, paddingLeft: 8, paddingBottom: 0,paddingRight: 0,
                                width: 0, height: 0)
    }
    
    @objc func handleTextChange() {
        // print(self.text ?? "")
        
        // if the text is not empty then we gonna hidden the placeholder
        placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
