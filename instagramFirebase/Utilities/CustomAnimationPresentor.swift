//
//  CustomAnimationPresentor.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/25/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit

// create custom presenter
class CustomAnimationPresentor: NSObject, UIViewControllerAnimatedTransitioning {
    
    // transition Duration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    // animate transition
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // my custom transition animation code login ...
        
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) else { return } // home controller
        guard let toView = transitionContext.view(forKey: .to) else { return } // camera controller
            
        // to make transition come from the left side  >>> x = -toView.frame.width
        let startingFrame = CGRect(x: -toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        toView.frame = startingFrame
        
        
        // ------------------------ apply some animation ------------------------------------------
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            // toView slides to right >>> x = 0
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            
            // fromView slides to right >>> x = fromView.frame.width
            fromView.frame = CGRect(x: fromView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
            
        }) { (_) in
            transitionContext.completeTransition(true) // tell the system transition is done
        }
        
        containerView.addSubview(toView)
    }
}
