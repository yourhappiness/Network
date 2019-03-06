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
  private var likeView = [UIView]()
  public var likeButton = LikeButton()
  private let likeCount = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  func setupView() {
    if isLiked {
      likeButton.filled = true
      self.likeButton.strokeColor = UIColor.red
      self.likeCount.textColor = UIColor.red
    } else {
      likeButton.filled = false
      self.likeButton.strokeColor = UIColor.black
      self.likeCount.textColor = UIColor.black
    }
    likeButton.draw(CGRect(origin: .zero, size: CGSize(width: 38, height: 25)))
    likeView.append(likeButton)
    likeCount.text = String(numberOfLikes)
    likeCount.textAlignment = .left
    likeView.append(likeCount)
    likeCount.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 10)
//    likeButton.addTarget(self, action: #selector(updateLikes(_:)), for: .touchUpInside)
    stackView = UIStackView(arrangedSubviews: likeView)
    self.addSubview(stackView)
    stackView.axis = .horizontal
    stackView.alignment = .center
  }
  
  func updateView() {
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
    isLiked = true
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    stackView.frame = CGRect(x: 10, y: 0, width: 65, height: 22)
  }

}

class LikeButton: UIButton {
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
