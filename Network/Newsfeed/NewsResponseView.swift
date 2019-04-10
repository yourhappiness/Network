//
//  NewsResponseView.swift
//  Network
//
//  Created by Anastasia Romanova on 29/03/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

class NewsResponseView: UIView {
  
  static let commentButtonSize = CGSize(width: 22, height: 22)
  static let shareButtonSize = CGSize(width: 28, height: 28)
  static let commentsAndSharesLabelsFont = UIFont.systemFont(ofSize: 15)

  //MARK: - Subviews
  public var newsLikesControl = LikeControl()
  private var commentButton = UIButton(type: .custom)
  private var commentsNumberLabel = UILabel()
  private var shareButton = UIButton(type: .custom)
  private var sharesNumberLabel = UILabel()
  
  //MARK: - Public parameters
  public var numberOfLikes: Int?
  public var isLiked: Bool?
  public var numberOfComments: Int?
  public var numberOfShares: Int?
  public var screenWidth: CGFloat?
  public var viewOrigin: CGPoint?
  public var height: CGFloat = 0
  public var commentsLabelSize = CGSize()
  public var sharesLabelSize = CGSize()
  
  //MARK: - Privates
  private var spaceBetweenElements: CGFloat = 5
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }
  
  private func setupViews() {
    newsLikesControl.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(newsLikesControl)
    
    let commentImage = UIImage(named: "Comment")
    commentButton.setImage(commentImage, for: .normal)
    self.addSubview(commentButton)
    
    commentsNumberLabel.font = NewsResponseView.commentsAndSharesLabelsFont
    commentsNumberLabel.textColor = .blue
    commentsNumberLabel.numberOfLines = 0
    self.addSubview(commentsNumberLabel)
    
    let shareImage = UIImage(named: "Share")
    shareButton.setImage(shareImage, for: .normal)
    self.addSubview(shareButton)

    sharesNumberLabel.font = NewsResponseView.commentsAndSharesLabelsFont
    sharesNumberLabel.textColor = .blue
    sharesNumberLabel.numberOfLines = 0
    self.addSubview(sharesNumberLabel)
  }
  
  public func updateViews() {
    guard let numberOfLikes = self.numberOfLikes, let isLiked = self.isLiked, let numberOfComments = self.numberOfComments, let numberOfShares = self.numberOfShares else {return}
    newsLikesControl.numberOfLikes = numberOfLikes
    newsLikesControl.isLiked = isLiked
    commentsNumberLabel.text = String(numberOfComments)
    sharesNumberLabel.text = String(numberOfShares)
    
    setNewsLikesControlFrame()
    setCommentButtonFrame()
    setCommentsNumberFrame()
    setShareButtonFrame()
    setSharesNumberFrame()
    setOwnFrame()
  }
  
  private func setNewsLikesControlFrame() {
    newsLikesControl.updateView()
    let newsLikesControlSize = CGSize(width: newsLikesControl.frame.width, height: newsLikesControl.frame.height)
    let newsLikesControlOrigin = CGPoint(x: spaceBetweenElements, y: newsLikesControl.frame.minY)
    self.newsLikesControl.frame = CGRect(origin: newsLikesControlOrigin, size: newsLikesControlSize)
  }
    
  private func setCommentButtonFrame() {
    let commentButtonSize = NewsResponseView.commentButtonSize
    let commentButtonY = newsLikesControl.frame.midY - commentButtonSize.height/2
    let commentButtonOrigin = CGPoint(x: newsLikesControl.frame.maxX + spaceBetweenElements, y: commentButtonY)
    self.commentButton.frame = CGRect(origin: commentButtonOrigin, size: commentButtonSize)
  }
    
  private func setCommentsNumberFrame() {
    let commentsNumberX = commentButton.frame.maxX + spaceBetweenElements
    let commentsNumberY = newsLikesControl.frame.midY - commentsLabelSize.height/2
    let commentsNumberOrigin = CGPoint(x: commentsNumberX, y: commentsNumberY)
    
    commentsNumberLabel.frame = CGRect(origin: commentsNumberOrigin, size: commentsLabelSize)
  }
    
  private func setShareButtonFrame() {
    let shareButtonSize = NewsResponseView.shareButtonSize
    let shareButtonY = newsLikesControl.frame.midY - shareButtonSize.height/2
    let shareButtonOrigin = CGPoint(x: commentsNumberLabel.frame.maxX + spaceBetweenElements, y: shareButtonY)
    self.shareButton.frame = CGRect(origin: shareButtonOrigin, size: shareButtonSize)
  }
    
  private func setSharesNumberFrame() {
    let sharesNumberX = shareButton.frame.maxX + spaceBetweenElements
    let sharesNumberY = newsLikesControl.frame.midY - sharesLabelSize.height/2
    let sharesNumberOrigin = CGPoint(x: sharesNumberX, y: sharesNumberY)
    
    sharesNumberLabel.frame = CGRect(origin: sharesNumberOrigin, size: sharesLabelSize)
  }
    
  private func setOwnFrame() {
    guard let origin = self.viewOrigin else {return}
    var width: CGFloat = 0
    DispatchQueue.global().sync {
      let commentsWidth = commentButton.frame.width + commentsNumberLabel.frame.width
      let shareWidth = shareButton.frame.width + sharesNumberLabel.frame.width
      width = newsLikesControl.frame.width + spaceBetweenElements * 6 + commentsWidth + shareWidth
    }
    let size = CGSize(width: width, height: height)
    
    self.frame = CGRect(origin: origin, size: size)
  }

}
