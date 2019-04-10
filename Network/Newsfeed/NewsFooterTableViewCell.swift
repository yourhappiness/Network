//
//  NewsFooterTableViewCell.swift
//  Network
//
//  Created by Anastasia Romanova on 29/03/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

class NewsFooterTableViewCell: UITableViewCell {

  static let reuseId = "NewsFooterTableViewCell"
  static let yOffsetFromCellEdge: CGFloat = 15
  
  //MARK: - Subviews
  private var newsResponseView = NewsResponseView()
  private var newsViewsStackView = NewsViewsStackView()
  
  //MARK: - Privates
  private let yOffsetFromCellEdge: CGFloat = NewsFooterTableViewCell.yOffsetFromCellEdge
  private let xOffsetFromCellEdge: CGFloat = 12
  private var screenWidth: CGFloat = 0
  
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
    self.contentView.addSubview(newsResponseView)
    self.contentView.addSubview(newsViewsStackView)
  }
  
  public func configure(with pieceOfNews: NewsfeedPost, for screenWidth: CGFloat, commentsLabelSize: CGSize, sharesLabelSize: CGSize, heightOfNewsResponseView: CGFloat) {
    self.screenWidth = screenWidth
    
    newsResponseView.numberOfLikes = pieceOfNews.numberOfLikes
    newsResponseView.isLiked = pieceOfNews.isLiked
    newsResponseView.numberOfComments = pieceOfNews.commentsNumber
    newsResponseView.numberOfShares = pieceOfNews.sharesNumber
    newsResponseView.screenWidth = screenWidth
    newsResponseView.commentsLabelSize = commentsLabelSize
    newsResponseView.sharesLabelSize = sharesLabelSize
    newsResponseView.height = heightOfNewsResponseView
    
    newsViewsStackView.numberOfViews = pieceOfNews.numberOfViews
    newsViewsStackView.screenWidth = screenWidth
    
    self.layoutIfNeeded()
  }
  
  //MARK: - Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    
    newsResponseView.backgroundColor = self.backgroundColor
    newsViewsStackView.backgroundColor = self.backgroundColor
    
    newsResponseView.viewOrigin = CGPoint(x: xOffsetFromCellEdge, y: yOffsetFromCellEdge)
    
    newsViewsStackView.newsResponseViewMidY = newsResponseView.frame.midY
    
    newsResponseView.updateViews()
    newsViewsStackView.updateViews()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    newsResponseView.numberOfLikes = 0
    newsResponseView.isLiked = false
    newsResponseView.newsLikesControl.likeButton.setNeedsDisplay()
    newsResponseView.numberOfComments = 0
    newsResponseView.numberOfShares = 0
    newsViewsStackView.numberOfViews = 0
  }
}
