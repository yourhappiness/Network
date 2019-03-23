//
//  SourceView.swift
//  Network
//
//  Created by Anastasia Romanova on 23/03/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

class SourceView: UIView {

  //MARK: - Subviews
  private var sourcePhotoImageView: UIImageView = {
    let photo = UIImageView()
    photo.contentMode = .scaleAspectFit
    photo.backgroundColor = .clear
    return photo
  }()
  private let sourceNameLabel = UILabel()
  private let postTimeLabel = UILabel()
  
  //MARK: - Public parameters
  public var sourceImageURL: String?
  public var sourceNameText: String?
  public var postTimeText: String?
  public var screenWidth: CGFloat?
  public var viewOrigin: CGPoint?
  
  //MARK: - Privates
  private let sourcePhotoWidth: CGFloat = 50
  private let sourceNameLeftOffset: CGFloat = 18
  private let sourceNameTopOffset: CGFloat = 8
  private let sourceNameBottomOffset: CGFloat = 7
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }
  
  private func setupViews() {
    sourceNameLabel.font = UIFont.systemFont(ofSize: 15)
    sourceNameLabel.numberOfLines = 0
    self.addSubview(sourceNameLabel)
    
    postTimeLabel.font = UIFont.systemFont(ofSize: 13)
    postTimeLabel.textColor = UIColor.darkGray
    postTimeLabel.numberOfLines = 0
    self.addSubview(postTimeLabel)
    
    self.addSubview(sourcePhotoImageView)
  }
  
  public func updateViews() {
    guard let sourceImageURL = self.sourceImageURL else {return}
    sourcePhotoImageView.kf.indicatorType = .activity
    sourcePhotoImageView.kf.setImage(with: URL(string: sourceImageURL))
    sourceNameLabel.text = sourceNameText
    postTimeLabel.text = postTimeText
    
    setSourcePhotoFrame()
    setSourceNameFrame()
    setPostTimeFrame()
    setOwnFrame()
  }
  
  private func setSourcePhotoFrame() {
    let sourcePhotoSize = CGSize(width: sourcePhotoWidth, height: sourcePhotoWidth)
    sourcePhotoImageView.frame = CGRect(origin: .zero, size: sourcePhotoSize)
  }
  
  private func setSourceNameFrame() {
    guard let sourceText = sourceNameLabel.text else {return}
    let sourceNameSize = self.getLabelSize(text: sourceText, font: sourceNameLabel.font)
    let sourceNameX = sourcePhotoImageView.frame.maxX + sourceNameLeftOffset
    let sourceNameOrigin = CGPoint(x: sourceNameX, y: sourceNameTopOffset)
    
    sourceNameLabel.frame = CGRect(origin: sourceNameOrigin, size: sourceNameSize)
  }
  
  private func setPostTimeFrame() {
    guard let postTimeText = postTimeLabel.text else {return}
    let postTimeSize = self.getLabelSize(text: postTimeText, font: postTimeLabel.font)
    let postTimeX = sourceNameLabel.frame.minX
    let postTimeY = sourceNameLabel.frame.maxY + sourceNameBottomOffset
    let postTimeOrigin = CGPoint(x: postTimeX, y: postTimeY)
    
    postTimeLabel.frame = CGRect(origin: postTimeOrigin, size: postTimeSize)
  }
  
  private func setOwnFrame() {
    guard let origin = viewOrigin else {return}
    let width = sourcePhotoImageView.frame.width + sourceNameLeftOffset + sourceNameLabel.frame.width
    let height = sourceNameTopOffset + sourceNameLabel.frame.height + sourceNameBottomOffset + postTimeLabel.frame.height
    let size = CGSize(width: width, height: height)
    
    self.frame = CGRect(origin: origin, size: size)
  }
  
  private func getLabelSize(text: String, font: UIFont) -> CGSize {
    guard let screenWidth = self.screenWidth else {return .zero}
    let maxWidth = screenWidth - sourceNameLeftOffset - sourcePhotoImageView.frame.maxX
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
