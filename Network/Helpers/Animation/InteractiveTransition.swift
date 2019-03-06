//
//  InteractiveTransition.swift
//  Network
//
//  Created by Anastasia Romanova on 02/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class InteractiveTransition: UIPercentDrivenInteractiveTransition {
  
  var viewController: UIViewController? {
    didSet {
      let recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgeGesture(_ :)))
      recognizer.edges = [.left]
      viewController?.view.addGestureRecognizer(recognizer)
    }
  }
  
  var hasStarted: Bool = false
  var shouldFinish: Bool = false
  
  @objc func handleScreenEdgeGesture(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    switch recognizer.state {
    case .began:
      self.hasStarted = true
      self.viewController?.navigationController?.popViewController(animated: true)
    case .changed:
      let translation = recognizer.translation(in: recognizer.view)
      let relativeTranslation = translation.y / 100
      let progress = max(0, min(4, relativeTranslation))
      self.shouldFinish = progress > 1
      self.update(progress)
    case .ended:
      self.hasStarted = false
      self.shouldFinish ? self.finish() : self.cancel()
    case .cancelled:
      self.hasStarted = false
      self.cancel()
    default: return
    }
  }

}
