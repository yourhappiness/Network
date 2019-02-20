//
//  PanGestureRecognizer.swift
//  Network
//
//  Created by Anastasia Romanova on 18/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class PanGestureRecognizer: UIPanGestureRecognizer {
  var initialTouchPoint : CGPoint = CGPoint.zero
  var trackedTouch : UITouch? = nil
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesBegan(touches, with: event)
    // Capture the first touch and store some information about it.
    if self.trackedTouch == nil {
      self.trackedTouch = touches.first
      self.initialTouchPoint = (self.trackedTouch?.location(in: self.view))!
    } else {
      // Ignore all but the first touch.
      for touch in touches {
        if touch != self.trackedTouch {
          self.ignore(touch, for: event)
        }
      }
    }
  }
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesCancelled(touches, with: event)
    self.initialTouchPoint = CGPoint.zero
    self.trackedTouch = nil
    self.state = .cancelled
  }
  
  override func reset() {
    super.reset()
    self.initialTouchPoint = CGPoint.zero
    self.trackedTouch = nil
  }
}
