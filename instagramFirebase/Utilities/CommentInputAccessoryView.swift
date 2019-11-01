//
//  CommentInputAccessoryView.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/28/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit

// to make bridge / contranct between two classes
protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}

class CommentInputAccessoryView: UIView {
        
    var delegate: CommentInputAccessoryViewDelegate?
    
    func clearCommentTextField() {
        commentTextView.text = nil
        commentTextView.showPlaceholderLabel() 
    }
    
    // ---------- very imp trick -----------------------------------------
    // to renaming / refactor >>>> ctrl + command + E
    // ------------------------------------------------------------------------------

    // convert UITextField to UITextView ... bec it supports multiple lines
    fileprivate let commentTextView: CommentInputTextView = {
       let tv = CommentInputTextView()
       // tv.placeholder = "Enter Comment" >>>> text view doesnt have place holder property
       tv.isScrollEnabled = false
       // tv.backgroundColor = .red
       tv.font = UIFont.systemFont(ofSize: 18)
       return tv
    }()
    
    // add submit button to the container view ----------------------------------------------------------
    fileprivate let submitButton: UIButton = {
       let sb = UIButton(type: .system)
       sb.setTitle("Post", for: .normal)
       //sb.setTitleColor(.black, for: .normal)
        sb.isEnabled = false
        sb.setTitleColor(.gray, for: .normal)
       sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
       sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
       return sb
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         
        // 1
        // multi-line text field
        autoresizingMask = .flexibleHeight
        
        // background color
        backgroundColor = .white
        
        // add submitButton
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor,
                            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12,
                            width: 50, height: 50)
        
        // add text field to the container view ------------------------------------------
        addSubview(self.commentTextView)
        // 3 >> safe area bottom anchor
        commentTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor,
                       // so the text didnt write on submit button
                       paddingTop: 8, paddingLeft: 12, paddingBottom: 8, paddingRight: 0,
                       width: 0, height: 0)

        setupLineSeperator()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange),
        name: UITextView.textDidChangeNotification, object: nil)
     
    }
    
    @objc func handleTextChange() {
        guard let comment = commentTextView.text else { return }
        if comment.count > 0 {
            submitButton.isEnabled = true
            submitButton.setTitleColor(UIColor.mainBlue(), for: .normal)
        } else {
            submitButton.isEnabled = false
            submitButton.setTitleColor(.gray, for: .normal)
        }
    }
    
    //2
    //Multi-line text field
    override var intrinsicContentSize: CGSize {
        return .zero // it will change how the bottom area render ... it will make it shrink
    }
    
    fileprivate func setupLineSeperator() {
        // add seperator line
             let lineSeperatorView = UIView()
             lineSeperatorView.backgroundColor = UIColor(white: 0, alpha: 0.1)
             addSubview(lineSeperatorView)
             lineSeperatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,
                                      paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                                      width: 0, height: 0.5)
    }
    
    
    @objc func enableSubmitButton() {
            submitButton.isEnabled = true
            submitButton.setTitleColor(.blue, for: .normal)
    }
    
    @objc func handleSubmit() {
        print("submit comment ... ")
        guard let comment = commentTextView.text else { return }
        delegate?.didSubmit(for: comment)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
