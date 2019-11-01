//
//  CustomAnimationDismisser.swift
//  instagramFirebase
//
//  Created by Belal Samy on 10/25/19.
//  Copyright © 2019 Belal Samy. All rights reserved.
//

import UIKit

class CustomAnimationDismisser: NSObject, UIViewControllerAnimatedTransitioning{
    
    // transition duration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    // animate transition
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) else { return } // camera controller
        guard let toView = transitionContext.view(forKey: .to) else { return } // home controller
        
        containerView.addSubview(toView)
        
        // ------------------------ apply some animation ------------------------------------------
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            // fromView slides to left >>> x = -fromView.frame.width
            fromView.frame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            
            // to make the home controller move to the left
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            
        }) { (_) in
            transitionContext.completeTransition(true) // tell the system transition is done
        }
        
    }
}
