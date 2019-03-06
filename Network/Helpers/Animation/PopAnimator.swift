//
//  PopAnimator.swift
//  Network
//
//  Created by Anastasia Romanova on 02/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.6
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let source = transitionContext.viewController(forKey: .from) else {return}
    guard let destination = transitionContext.viewController(forKey: .to) else {return}
    transitionContext.containerView.addSubview(destination.view)
    transitionContext.containerView.sendSubviewToBack(destination.view)
    destination.view.frame = source.view.frame
    source.view.layer.anchorPoint = CGPoint(x: 1, y: 0)
    source.view.layer.position = CGPoint(x: 1, y: 0)
    UIView.animateKeyframes(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .calculationModePaced, animations: {
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
        let rotation = CGAffineTransform(rotationAngle: -90.degreesToRadians)
        let translation = CGAffineTransform(translationX: source.view.frame.width, y: 0)
        source.view.transform = rotation.concatenating(translation)
      })
    }) { finished in
      if finished && !transitionContext.transitionWasCancelled {
        source.removeFromParent()
      }
      transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
    }
  }
  

}
