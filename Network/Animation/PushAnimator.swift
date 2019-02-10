//
//  PushAnimator.swift
//  Network
//
//  Created by Anastasia Romanova on 02/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

final class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.6
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let source = transitionContext.viewController(forKey: .from) else {return}
    guard let destination = transitionContext.viewController(forKey: .to) else {return}
    destination.view.frame = source.view.frame
    let xDestination = source.view.frame.width
    transitionContext.containerView.addSubview(destination.view)
    destination.view.layer.anchorPoint = CGPoint(x: 1, y: 0)
    destination.view.layer.position = CGPoint(x: 1, y: 0)
    let rotation = CGAffineTransform(rotationAngle: -90.degreesToRadians)
    let translation = CGAffineTransform(translationX: source.view.frame.width, y: 0)
    destination.view.transform = rotation.concatenating(translation)
    UIView.animateKeyframes(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .calculationModePaced, animations: {
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
        destination.view.transform = CGAffineTransform(translationX: xDestination, y: 0)
      })
    }) { finished in
      if finished && !transitionContext.transitionWasCancelled {
        source.view.transform = .identity
      }
      transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
    }
    
  }
  

}
