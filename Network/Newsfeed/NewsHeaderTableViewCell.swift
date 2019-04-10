//
//  NewsHeaderTableViewCell.swift
//  Network
//
//  Created by Anastasia Romanova on 29/03/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit
import RealmSwift

class NewsHeaderTableViewCell: UITableViewCell {

  static let reuseId = "NewsHeaderTableViewCell"
  static let sourcePhotoWidth: CGFloat = 50
  static let xOffsetFromCellEdge: CGFloat = 12
  static let yOffsetForSourceName: CGFloat = 14
  static let sourceNameLabelFont = UIFont.systemFont(ofSize: 15)
  static let postTimeLabelFont = UIFont.systemFont(ofSize: 13)
  static let sourceNameBottomOffset: CGFloat = 7
  static let sourceNameLeftOffset: CGFloat = 18
  static let sourceNameRightOffset: CGFloat = 12
  static let offsetForLabelMaxWidth = NewsHeaderTableViewCell.xOffsetFromCellEdge + NewsHeaderTableViewCell.sourcePhotoWidth + NewsHeaderTableViewCell.sourceNameRightOffset + NewsHeaderTableViewCell.sourceNameLeftOffset

  //MARK: - Subviews
  private var sourcePhotoImageView: UIImageView = {
    let photo = UIImageView()
    photo.contentMode = .scaleAspectFit
    photo.backgroundColor = .clear
    return photo
  }()
  private let sourceNameLabel = UILabel()
  private let postTimeLabel = UILabel()
  
  //MARK: - Privates
  private let sourcePhotoWidth: CGFloat = NewsHeaderTableViewCell.sourcePhotoWidth
  private let xOffsetFromCellEdge: CGFloat = NewsHeaderTableViewCell.xOffsetFromCellEdge
  private let yOffsetForSourceName: CGFloat = NewsHeaderTableViewCell.yOffsetForSourceName
  private let sourceNameLeftOffset: CGFloat = NewsHeaderTableViewCell.sourceNameLeftOffset
  private let sourceNameRightOffset: CGFloat = NewsHeaderTableViewCell.sourceNameRightOffset
  private let sourceNameBottomOffset: CGFloat = NewsHeaderTableViewCell.sourceNameBottomOffset
  private var sourceNameSize = CGSize()
  private var postTimeSize = CGSize()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupViews()
  }
  
  //MARK: - Inits
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }
  
  private func setupViews() {
    sourceNameLabel.font = NewsHeaderTableViewCell.sourceNameLabelFont
    sourceNameLabel.numberOfLines = 0
    self.contentView.addSubview(sourceNameLabel)
    
    postTimeLabel.font = NewsHeaderTableViewCell.postTimeLabelFont
    postTimeLabel.textColor = UIColor.darkGray
    postTimeLabel.numberOfLines = 0
    self.contentView.addSubview(postTimeLabel)
    
    self.contentView.addSubview(sourcePhotoImageView)
  }
  
  public func configure(with pieceOfNews: NewsfeedCompatible, sourceName: String, postTime: String, sourceNameSize: CGSize, postTimeSize: CGSize) {
    if pieceOfNews.sourceId > 0 {
      self.getSource(from: User.self, for: pieceOfNews.sourceId)
    } else if pieceOfNews.sourceId < 0 {
      self.getSource(from: Group.self, for: -pieceOfNews.sourceId)
    }
    sourceNameLabel.text = sourceName
    postTimeLabel.text = postTime
    self.sourceNameSize = sourceNameSize
    self.postTimeSize = postTimeSize
    
    self.setNeedsLayout()
    self.layoutIfNeeded()
  }
  
  //MARK: - Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    
    sourceNameLabel.backgroundColor = self.backgroundColor
    postTimeLabel.backgroundColor = self.backgroundColor
    
    setSourceNameFrame()
    setPostTimeFrame()
    setSourcePhotoFrame()
  }
  
  
  private func setSourcePhotoFrame() {
    let sourcePhotoSize = CGSize(width: sourcePhotoWidth, height: sourcePhotoWidth)
    let midY = (sourceNameLabel.frame.height + postTimeLabel.frame.height + sourceNameBottomOffset) / 2 + yOffsetForSourceName
    let y = midY - sourcePhotoWidth / 2
    let sourcePhotoOrigin = CGPoint(x: xOffsetFromCellEdge, y: y)
    sourcePhotoImageView.frame = CGRect(origin: sourcePhotoOrigin, size: sourcePhotoSize)
  }
  
  private func setSourceNameFrame() {
    let sourceNameX = sourcePhotoImageView.frame.maxX + sourceNameLeftOffset
    let sourceNameOrigin = CGPoint(x: sourceNameX, y: yOffsetForSourceName)
    
    sourceNameLabel.frame = CGRect(origin: sourceNameOrigin, size: self.sourceNameSize)
  }
  
  private func setPostTimeFrame() {
    let postTimeX = sourceNameLabel.frame.minX
    let postTimeY = sourceNameLabel.frame.maxY + sourceNameBottomOffset
    let postTimeOrigin = CGPoint(x: postTimeX, y: postTimeY)
    
    postTimeLabel.frame = CGRect(origin: postTimeOrigin, size: self.postTimeSize)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    sourcePhotoImageView.image = nil
    sourceNameLabel.text = nil
    postTimeLabel.text = nil
  }
  
  //MARK: - Helpers
  private func getSource<T> (from type: T.Type, for id: Int) where T: Object & HasParameters {
    guard let sourceArray = try? Realm().objects(T.self).filter("id = %@", id) else {return}
    let source = Array(sourceArray)[0]
    let sourceImageURL = source.photoURL
    sourcePhotoImageView.kf.indicatorType = .activity
    sourcePhotoImageView.kf.setImage(with: URL(string: sourceImageURL))
  }

}
