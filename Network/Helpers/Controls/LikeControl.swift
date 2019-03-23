//
//  LikeButton.swift
//  Network
//
//  Created by Anastasia Romanova on 13/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

@IBDesignable class LikeControl: UIControl {

  public var numberOfLikes = Int()
  public var isLiked = Bool()
  
  private var stackView: UIStackView!
  public var likeButton = LikeButton()
  private let likeCount = UILabel()
  
  private let offset: CGFloat = 5
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  private func setupView() {
    if isLiked {
      likeButton.filled = true
      self.likeButton.strokeColor = UIColor.red
      self.likeCount.textColor = UIColor.red
    } else {
      likeButton.filled = false
      self.likeButton.strokeColor = UIColor.black
      self.likeCount.textColor = UIColor.black
    }
    likeCount.text = String(numberOfLikes)
    likeCount.textAlignment = .left
    likeCount.font = UIFont.systemFont(ofSize: 15)
    stackView = UIStackView(arrangedSubviews: [likeButton, likeCount])
    stackView.spacing = offset
    stackView.distribution = .fill
    self.addSubview(stackView)
    stackView.axis = .horizontal
    stackView.alignment = .center
    likeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    likeCount.setContentCompressionResistancePriority(.required, for: .horizontal)
    self.layoutIfNeeded()
  }
  
  public func updateView() {
    if isLiked {
      likeButton.filled = true
      self.likeButton.strokeColor = UIColor.red
      self.likeCount.textColor = UIColor.red
    } else {
      likeButton.filled = false
      self.likeButton.strokeColor = UIColor.black
      self.likeCount.textColor = UIColor.black
    }
    likeButton.setNeedsDisplay()
    likeCount.text = String(numberOfLikes)
    self.setNeedsLayout()
    self.layoutIfNeeded()
  }
  
  @objc public func updateLikes() {
    guard !isLiked else {
      
//      self.numberOfLikes -= 1
      self.likeButton.filled = false
      self.likeButton.strokeColor = UIColor.black
      self.likeButton.setNeedsDisplay()
      UIView.transition(with: likeCount, duration: 0.25, options: .transitionCurlDown, animations: {
        self.likeCount.text = String(self.numberOfLikes)
      })
      self.likeCount.textColor = UIColor.black
      isLiked = false
      
      self.layoutIfNeeded()
      return
    }
//    self.numberOfLikes += 1
    self.likeButton.filled = true
    self.likeButton.strokeColor = UIColor.red
    self.likeButton.setNeedsDisplay()
    UIView.transition(with: likeCount, duration: 0.25, options: .transitionCurlDown, animations: {
      self.likeCount.text = String(self.numberOfLikes)
    })
    self.likeCount.textColor = UIColor.red

    self.layoutIfNeeded()
    isLiked = true
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    setStackViewFrame()
    setOwnFrame()
  }
  
  private func setStackViewFrame() {
    let labelWidth = likeCount.intrinsicContentSize.width
    let labelHeight = likeCount.intrinsicContentSize.height
    
    let stackViewWidth = LikeButton.desiredWidth + labelWidth + offset
    let stackViewHeight = max(LikeButton.desiredWidth, labelHeight)
    let stackViewSize = CGSize(width: stackViewWidth, height: stackViewHeight)
    stackView.frame = CGRect(origin: .zero, size: stackViewSize)
  }
  
  private func setOwnFrame() {
    let width = stackView.frame.width
    let height = stackView.frame.height
    let size = CGSize(width: width, height: height)
    self.frame = CGRect(origin: self.frame.origin, size: size)
  }
}

class LikeButton: UIButton {
  static let desiredWidth: CGFloat = 33
  static let desiredHeight: CGFloat = 25
  override var intrinsicContentSize: CGSize {
    return CGSize(width: LikeButton.desiredWidth, height: LikeButton.desiredHeight)
  }
  
  var strokeWidth: CGFloat = 2.0
  var strokeColor = UIColor.black
  var filled = false
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let context = UIGraphicsGetCurrentContext() else {return}
    let bezierPath = UIBezierPath(heartIn: self.bounds)
    
    context.setStrokeColor(strokeColor.cgColor)
    bezierPath.lineWidth = self.strokeWidth
    bezierPath.stroke()
    
    guard filled else {return}
    context.setFillColor(strokeColor.cgColor)
    bezierPath.fill()
  }
}

extension UIBezierPath {
  convenience init(heartIn rect: CGRect) {
    self.init()
    
    //Calculate Radius of Arcs using Pythagoras
    let sideOne = rect.width * 0.4
    let sideTwo = rect.height * 0.3
    let arcRadius = sqrt(sideOne*sideOne + sideTwo*sideTwo)/2
    
    //Left Hand Curve
    self.addArc(withCenter: CGPoint(x: rect.width * 0.3, y: rect.height * 0.35), radius: arcRadius, startAngle: 135.degreesToRadians, endAngle: 315.degreesToRadians, clockwise: true)
    
    //Top Centre Dip
    self.addLine(to: CGPoint(x: rect.width/2, y: rect.height * 0.2))
    
    //Right Hand Curve
    self.addArc(withCenter: CGPoint(x: rect.width * 0.7, y: rect.height * 0.35), radius: arcRadius, startAngle: 225.degreesToRadians, endAngle: 45.degreesToRadians, clockwise: true)
    
    //Right Bottom Line
    self.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.95))
    
    //Left Bottom Line
    self.close()
  }
}

extension Int {
  var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}
