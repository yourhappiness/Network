//
//  NewsViewsStackView.swift
//  Network
//
//  Created by Anastasia Romanova on 29/03/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

class NewsViewsStackView: UIStackView {

  //MARK: - Subviews
  private var newsViewsImageView = UIImageView()
  private var newsViewsNumberLabel = UILabel()
  
  //MARK: - Public parameters
  public var numberOfViews: Int?
  public var screenWidth: CGFloat?
  public var newsResponseViewMidY: CGFloat?
  
  //MARK: - Privates
  private var spaceBetweenElements:CGFloat = 5
  private let xOffsetFromCellEdge: CGFloat = 12
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }
  
  private func setupViews() {
    self.alignment = .center
    self.distribution = .fillProportionally
    self.spacing = 5
    self.axis = .horizontal
   
    let newsViewsImage = UIImage(named: "View")
    newsViewsImageView.image = newsViewsImage
    newsViewsImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    self.addArrangedSubview(newsViewsImageView)
    
    newsViewsNumberLabel.font = UIFont.systemFont(ofSize: 15)
    newsViewsNumberLabel.textColor = .blue
    newsViewsNumberLabel.numberOfLines = 0
    newsViewsNumberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    self.addArrangedSubview(newsViewsNumberLabel)
  }
  
  public func updateViews() {
    guard let numberOfViews = self.numberOfViews else {return}
    newsViewsNumberLabel.text = String(numberOfViews)
    
    setOwnFrame()
  }
  
  private func setOwnFrame() {
    //set label size
    guard let newsViewsNumberText = newsViewsNumberLabel.text, let midY = newsResponseViewMidY, let screenWidth = self.screenWidth else {return}
    let newsViewsNumberSize = self.getLabelSize(text: newsViewsNumberText, font: newsViewsNumberLabel.font)
    
    //set imageView size
    let newsViewsImageViewSize = CGSize(width: 24, height: 22)
    
    //set the whole UIStackView size and origin
    var width: CGFloat = 0
    var height: CGFloat = 0
    DispatchQueue.global().sync {
      width = newsViewsImageViewSize.width + spaceBetweenElements + newsViewsNumberSize.width
      height = max(newsViewsImageViewSize.height, newsViewsNumberSize.height)
    }
    let size = CGSize(width: width, height: height)
    let x = screenWidth - width - xOffsetFromCellEdge
    let y = midY - size.height/2
    let origin = CGPoint(x: x, y: y)
    
    self.frame = CGRect(origin: origin, size: size)
  }
  
  //MARK: - Helpers
  private func getLabelSize(text: String, font: UIFont) -> CGSize {
    guard let screenWidth = self.screenWidth else {return .zero}
    let maxWidth = screenWidth
    let textblock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
    
    let rect = text.boundingRect(with: textblock,
                                 options: .usesLineFragmentOrigin,
                                 attributes: [NSAttributedString.Key.font : font],
                                 context: nil)
    
    let width = rect.size.width.rounded(.up)
    let height = rect.size.height.rounded(.up)
    
    return CGSize(width: width, height: height)
  }

}
