//
//  ActivityIndicatorView.swift
//  Network
//
//  Created by Anastasia Romanova on 25/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIView {
  
  var dot1: dotView?
  var dot2: dotView?
  var dot3: dotView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  private func setupView() {
    self.backgroundColor = .clear
    let dotWidth = (self.bounds.width - 15) / 3
    dot1 = dotView(frame: CGRect(x: self.bounds.minX, y: self.bounds.minY, width: dotWidth, height: dotWidth))
    dot2 = dotView(frame: CGRect(x: (dot1?.frame.maxX)! + 5, y: self.bounds.minY, width: dotWidth, height: dotWidth))
    dot3 = dotView(frame: CGRect(x: (dot2?.frame.maxX)! + 5, y: self.bounds.minY, width: dotWidth, height: dotWidth))
    self.addSubview(dot1!)
    self.addSubview(dot2!)
    self.addSubview(dot3!)
    dot1?.alpha = 0
    dot2?.alpha = 0
    dot3?.alpha = 0
  }
  
  func startAnimation() {
    self.isHidden = false
    UIView.animate(withDuration: 1.5,
                   animations: {
                    UIView.animate(withDuration: 0.5,
                                   delay: 0,
                                   options: [.repeat, .autoreverse],
                                   animations: {
                                    self.dot1?.alpha = 1
                    },
                                   completion: nil)
                    UIView.animate(withDuration: 0.5,
                                   delay: 0.5,
                                   options: [.repeat, .autoreverse],
                                   animations: {
                                    self.dot2?.alpha = 1
                    },
                                   completion: nil)
                    UIView.animate(withDuration: 0.5,
                                   delay: 1,
                                   options: [.repeat, .autoreverse],
                                   animations: {
                                    self.dot3?.alpha = 1
                    },
                                   completion: nil)
    }, completion: nil)
  }
  
  func stopAnimation() {
    self.isHidden = true
    dot1?.alpha = 0
    dot2?.alpha = 0
    dot3?.alpha = 0
  }
}


class dotView: UIView {
  
  var x: CGFloat?
  var y: CGFloat?
  var width: CGFloat?
  var height: CGFloat?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.x = frame.minX
    self.y = frame.minY
    self.width = frame.width
    self.height = frame.height
    self.draw(CGRect(x: x!, y: y!, width: width!, height: height!))
    self.backgroundColor = .clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let context = UIGraphicsGetCurrentContext() else {return}
    context.setFillColor(UIColor.white.cgColor)
    context.fillEllipse(in: rect)
  }

}
