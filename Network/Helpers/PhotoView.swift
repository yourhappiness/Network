//
//  PhotoView.swift
//  Network
//
//  Created by Anastasia Romanova on 12/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoView: UIView {
  
  var shadowView = UIView()

  var containerView = UIImageView()

  var shadowOffset: CGSize = CGSize(width: 5, height: 8) {
    didSet {
      shadowView.layer.shadowOffset = shadowOffset
    }
  }
  
  var shadowRadius: CGFloat = 3 {
    didSet {
      shadowView.layer.shadowRadius = shadowRadius
    }
  }
  
  var shadowOpacity: Float = 0.8 {
    didSet {
      shadowView.layer.shadowOpacity = shadowOpacity
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  override var intrinsicContentSize: CGSize {
    return containerView.image?.size ?? CGSize(width: 50, height: 50)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    sizeChanged()
  }
  
  func setup() {
    self.containerView.clipsToBounds = true
    self.containerView.contentMode = .scaleAspectFit
    self.addSubview(containerView)
    self.containerView.translatesAutoresizingMaskIntoConstraints = false
    self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    self.containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    setupShadow()
    self.bringSubviewToFront(containerView)
    self.layoutIfNeeded()
  }
  
  func setupShadow() {
    self.shadowView.layer.shadowOffset = shadowOffset
    self.shadowView.layer.shadowOpacity = shadowOpacity
    self.shadowView.layer.shadowRadius = shadowRadius
    self.shadowView.backgroundColor = .clear
    self.addSubview(shadowView)
    self.shadowView.translatesAutoresizingMaskIntoConstraints = false
    self.shadowView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    self.shadowView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    self.shadowView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    self.shadowView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
  }
  
  func sizeChanged() {
    containerView.frame = self.bounds
    self.containerView.layer.cornerRadius = self.containerView.frame.width / 2
    shadowView.frame = self.bounds
    self.shadowView.layer.shadowPath = UIBezierPath(ovalIn: self.shadowView.bounds).cgPath
    
  }
}
