//
//  NewsfeedCellCalculatedLayout.swift
//  Network
//
//  Created by Anastasia Romanova on 11/03/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class NewsfeedCellCalculatedLayout: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  static let reuseId = "NewsfeedCellCalculatedLayout"
  
  //MARK: - Subviews
  private let sourceView = SourceView()
  private var postTextView: UITextView?
  private var postPhotosCollectionView: UICollectionView?
  private var newsResponseView: UIView?
  private var newsViewsStackView: UIStackView?
  //Response views
  private var newsLikesControl: LikeControl?
  private var commentButton: UIButton?
  private var commentsNumberLabel: UILabel?
  private var shareButton: UIButton?
  private var sharesNumberLabel: UILabel?
  //NewsViews views
  private var newsViewsImageView: UIImageView?
  private var newsViewsNumberLabel: UILabel?
  
  //MARK: - Privates
  private var photos: [Photo]?
  private var photoUrls: [URL]?
  private let sourcePhotoWidth: CGFloat = 50
  private let xOffsetFromCellEdge: CGFloat = 12
  private let yOffsetForSourcePhoto: CGFloat = 6
  private let sourceNameLeftOffset: CGFloat = 18
  private let sourceNameRightOffset: CGFloat = 12
  private let sourceNameTopOffset: CGFloat = 14
  private let sourceNameBottomOffset: CGFloat = 7
  private let ySpaceBetweenElements: CGFloat = 15
  private let xOffsetForPostPhotos: CGFloat = 10
  private var postPhotosOriginY: CGFloat = 0
  private var newsResponseNewsViewsSpaceBetweenElements:CGFloat = 5
  private var screenWidth: CGFloat = 0
  
  //MARK: - Cell size
  public var cellHeight: CGFloat = 0
  
  //MARK: - Inits
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.contentView.addSubview(sourceView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    self.contentView.addSubview(sourceView)
  }
  
  func configure(with pieceOfNews: NewsfeedCompatible, postTime: String, using urls: [URL]?, for screenWidth: CGFloat) {
    self.screenWidth = screenWidth
    if pieceOfNews.sourceId > 0 {
      self.getSource(from: User.self, for: pieceOfNews.sourceId)
    } else if pieceOfNews.sourceId < 0 {
      self.getSource(from: Group.self, for: -pieceOfNews.sourceId)
    }

    sourceView.postTimeText = postTime
    sourceView.screenWidth = screenWidth
    
    self.photos = pieceOfNews.photos
    self.photoUrls = urls
    
    if self.photos != nil {
      self.postPhotosCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
      self.contentView.addSubview(postPhotosCollectionView!)
      self.postPhotosCollectionView?.delegate = self
      self.postPhotosCollectionView?.dataSource = self
      self.postPhotosCollectionView?.register(PostPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PostPhotoCell")
    }
    
    if let element = pieceOfNews as? NewsfeedPost {
      if element.postText != "" {
        self.postTextView = UITextView()
        self.postTextView?.font = UIFont.systemFont(ofSize: 12)
        postTextView?.isScrollEnabled = false
        postTextView?.isEditable = false
        postTextView?.textAlignment = .justified
        postTextView?.dataDetectorTypes = .all
        self.postTextView?.text = element.postText
        self.contentView.addSubview(postTextView!)
      }
      newsResponseView = UIView()
      self.contentView.addSubview(newsResponseView!)
      
      newsLikesControl = LikeControl()
      newsLikesControl?.translatesAutoresizingMaskIntoConstraints = false
      newsLikesControl?.numberOfLikes = element.numberOfLikes
      newsLikesControl?.isLiked = element.isLiked
      
      let commentImage = UIImage(named: "Comment")
      commentButton = UIButton(type: .custom)
      commentButton?.setImage(commentImage, for: .normal)
      commentsNumberLabel = UILabel()
      commentsNumberLabel?.font = UIFont.systemFont(ofSize: 15)
      commentsNumberLabel?.textColor = .blue
      commentsNumberLabel?.numberOfLines = 0
      commentsNumberLabel?.text = String(element.commentsNumber)
      let shareImage = UIImage(named: "Share")
      shareButton = UIButton(type: .custom)
      shareButton?.setImage(shareImage, for: .normal)
      sharesNumberLabel = UILabel()
      sharesNumberLabel?.font = UIFont.systemFont(ofSize: 15)
      sharesNumberLabel?.textColor = .blue
      sharesNumberLabel?.numberOfLines = 0
      sharesNumberLabel?.text = String(element.sharesNumber)
      newsResponseView?.addSubview(newsLikesControl!)
      newsResponseView?.addSubview(commentButton!)
      newsResponseView?.addSubview(commentsNumberLabel!)
      newsResponseView?.addSubview(shareButton!)
      newsResponseView?.addSubview(sharesNumberLabel!)

      //add and setup newsViewsControl
      newsViewsStackView = UIStackView()
      newsViewsStackView?.alignment = .center
      newsViewsStackView?.distribution = .fill
      newsViewsStackView?.spacing = 5
      newsViewsStackView?.axis = .horizontal
      self.contentView.addSubview(newsViewsStackView!)
      let newsViewsImage = UIImage(named: "View")
      newsViewsImageView = UIImageView()
      newsViewsImageView?.image = newsViewsImage
      newsViewsImageView?.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      newsViewsNumberLabel = UILabel()
      newsViewsNumberLabel?.font = UIFont.systemFont(ofSize: 15)
      newsViewsNumberLabel?.textColor = .blue
      newsViewsNumberLabel?.numberOfLines = 0
      newsViewsNumberLabel?.text = String(element.numberOfViews)
      newsViewsNumberLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
      newsViewsStackView?.addArrangedSubview(newsViewsImageView!)
      newsViewsStackView?.addArrangedSubview(newsViewsNumberLabel!)
    }
    self.layoutIfNeeded()
  }

  //MARK: - Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    //layout source
    sourceView.backgroundColor = self.backgroundColor
    let x = xOffsetFromCellEdge
    let y = yOffsetForSourcePhoto
    let origin = CGPoint(x: x, y: y)
    sourceView.viewOrigin = origin
    sourceView.updateViews()
    DispatchQueue.global().sync {
      self.cellHeight = yOffsetForSourcePhoto + sourceView.frame.height
    }
    //layout postText
    if self.postTextView != nil {
      setPostTextFrame()
      self.postTextView?.backgroundColor = self.backgroundColor
      DispatchQueue.global().sync {
        self.cellHeight = self.cellHeight + ySpaceBetweenElements + postTextView!.frame.height
      }
    }
    //layout CollectionView
    if self.postPhotosCollectionView != nil {
      self.setPostPhotosCollectionViewFrame()
      DispatchQueue.global().sync {
        self.cellHeight = self.cellHeight + ySpaceBetweenElements + postPhotosCollectionView!.frame.height
      }
    }
    //layout newsResponse
    if self.newsResponseView != nil {
      setNewsResponseFrame()
      self.commentsNumberLabel?.backgroundColor = self.backgroundColor
      self.sharesNumberLabel?.backgroundColor = self.backgroundColor
      DispatchQueue.global().sync {
        self.cellHeight = self.cellHeight + ySpaceBetweenElements + self.newsResponseView!.frame.height + ySpaceBetweenElements
      }
    }
    //layout viewsControl
    if self.newsViewsStackView != nil {
      setNewsViewsFrame()
      self.newsViewsNumberLabel?.backgroundColor = self.backgroundColor
//      DispatchQueue.global().sync {
//        self.cellHeight = self.cellHeight + ySpaceBetweenElements + self.newsViewsControl!.frame.height
//      }
    }
    //set contentSize
    let contentViewSize = CGSize(width: self.contentView.frame.width, height: cellHeight)
    self.contentView.frame = CGRect(origin: contentView.frame.origin, size: contentViewSize)
  }
  
  private func setPostTextFrame() {
    var postTextSize = postTextView!.sizeThatFits(CGSize(width: screenWidth - xOffsetFromCellEdge * 2, height: .greatestFiniteMagnitude))
    if postTextSize.height > 100 {
      postTextSize = CGSize(width: postTextSize.width, height: 100)
      postTextView?.isScrollEnabled = true
    }
    let postTextX = self.contentView.bounds.minX + xOffsetFromCellEdge
    let postTextY = sourceView.frame.maxY + ySpaceBetweenElements
    let postTextOrigin = CGPoint(x: postTextX, y: postTextY)
    
    postTextView?.frame = CGRect(origin: postTextOrigin, size: postTextSize)
  }
  
  private func setPostPhotosCollectionViewFrame() {
    let postPhotosWidth: CGFloat = screenWidth - xOffsetForPostPhotos * 2
    let postPhotosOriginX: CGFloat = self.contentView.bounds.minX + xOffsetForPostPhotos
    if self.postTextView != nil {
      self.postPhotosOriginY = self.postTextView!.frame.maxY + ySpaceBetweenElements
    } else {
      self.postPhotosOriginY = self.sourceView.frame.maxY + ySpaceBetweenElements
    }
    
    let postPhotosOriginPoint = CGPoint(x: postPhotosOriginX, y: self.postPhotosOriginY)
    let postPhotoSize = CGSize(width: postPhotosWidth, height: postPhotosWidth)
    self.postPhotosCollectionView?.frame =  CGRect(origin: postPhotosOriginPoint, size: postPhotoSize)
  }

  private func setNewsResponseFrame() {
    newsLikesControl?.updateView()
    let newsLikesControlSize = CGSize(width: newsLikesControl!.frame.width, height: newsLikesControl!.frame.height)
    let newsLikesControlOrigin = CGPoint(x: xOffsetFromCellEdge + newsResponseNewsViewsSpaceBetweenElements, y: newsLikesControl!.frame.minY)
    self.newsLikesControl?.frame = CGRect(origin: newsLikesControlOrigin, size: newsLikesControlSize)
    
    let commentButtonSize = CGSize(width: 22, height: 22)
    let commentButtonY = newsLikesControl!.frame.midY - commentButtonSize.height/2
    let commentButtonOrigin = CGPoint(x: newsLikesControl!.frame.maxX + newsResponseNewsViewsSpaceBetweenElements, y: commentButtonY)
    self.commentButton?.frame = CGRect(origin: commentButtonOrigin, size: commentButtonSize)
    
    guard let commentsNumberText = commentsNumberLabel!.text else {return}
    let commentsNumberSize = self.getLabelSize(text: commentsNumberText, font: commentsNumberLabel!.font)
    let commentsNumberX = commentButton!.frame.maxX + newsResponseNewsViewsSpaceBetweenElements
    let commentsNumberY = newsLikesControl!.frame.midY - commentsNumberSize.height/2
    let commentsNumberOrigin = CGPoint(x: commentsNumberX, y: commentsNumberY)
    
    commentsNumberLabel?.frame = CGRect(origin: commentsNumberOrigin, size: commentsNumberSize)
    
    let shareButtonSize = CGSize(width: 28, height: 28)
    let shareButtonY = newsLikesControl!.frame.midY - shareButtonSize.height/2
    let shareButtonOrigin = CGPoint(x: commentsNumberLabel!.frame.maxX + newsResponseNewsViewsSpaceBetweenElements, y: shareButtonY)
    self.shareButton?.frame = CGRect(origin: shareButtonOrigin, size: shareButtonSize)
    
    guard let sharesNumberText = sharesNumberLabel!.text else {return}
    let sharesNumberSize = self.getLabelSize(text: sharesNumberText, font: sharesNumberLabel!.font)
    let sharesNumberX = shareButton!.frame.maxX + newsResponseNewsViewsSpaceBetweenElements
    let sharesNumberY = newsLikesControl!.frame.midY - sharesNumberSize.height/2
    let sharesNumberOrigin = CGPoint(x: sharesNumberX, y: sharesNumberY)
    
    sharesNumberLabel?.frame = CGRect(origin: sharesNumberOrigin, size: sharesNumberSize)
    
    var width: CGFloat = 0
    var height: CGFloat = 0
    DispatchQueue.global().sync {
    let commentsWidth = commentButton!.frame.width + commentsNumberLabel!.frame.width
    let shareWidth = shareButton!.frame.width + sharesNumberLabel!.frame.width
    width = newsLikesControl!.frame.width + newsResponseNewsViewsSpaceBetweenElements * 6 + commentsWidth + shareWidth
    height = max(newsLikesControl!.frame.height, commentButton!.frame.height, commentsNumberLabel!.frame.height, shareButton!.frame.height, sharesNumberLabel!.frame.height)
    }
    let size = CGSize(width: width, height: height)
    var y: CGFloat
    if self.postTextView != nil {
      if self.postPhotosCollectionView != nil {
        y = self.postPhotosCollectionView!.frame.maxY + ySpaceBetweenElements
      } else {
        y = self.postTextView!.frame.maxY + ySpaceBetweenElements
      }
    } else {
      if self.postPhotosCollectionView != nil {
        y = self.postPhotosCollectionView!.frame.maxY + ySpaceBetweenElements
      } else {
        y = self.sourceView.frame.maxY + ySpaceBetweenElements
      }
    }
    let origin = CGPoint(x: xOffsetFromCellEdge, y: y)
    
    newsResponseView?.frame = CGRect(origin: origin, size: size)
  }
  
  private func setNewsViewsFrame() {
    //set label size
    guard let newsViewsNumberText = newsViewsNumberLabel?.text else {return}
    let newsViewsNumberSize = self.getLabelSize(text: newsViewsNumberText, font: newsViewsNumberLabel!.font)

    //set imageView size
    let newsViewsImageViewSize = CGSize(width: 24, height: 22)
    
    //set the whole UIStackView size and origin
    var width: CGFloat = 0
    var height: CGFloat = 0
    DispatchQueue.global().sync {
      width = newsViewsImageViewSize.width + newsResponseNewsViewsSpaceBetweenElements + newsViewsNumberSize.width
      height = max(newsViewsImageViewSize.height, newsViewsNumberSize.height)
    }
    let size = CGSize(width: width, height: height)
    let x = screenWidth - xOffsetFromCellEdge - width
    let y = newsResponseView!.frame.midY - size.height/2
    let origin = CGPoint(x: x, y: y)
    
    newsViewsStackView?.frame = CGRect(origin: origin, size: size)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    cellHeight = 0
    sourceView.sourceImageURL = nil
    sourceView.sourceNameText = nil
    sourceView.postTimeText = nil
    postTextView?.removeFromSuperview()
    postTextView?.text = nil
    postTextView = nil
    photos = nil
    photoUrls = nil
    postPhotosCollectionView?.removeFromSuperview()
    postPhotosCollectionView = nil
    newsResponseView?.removeFromSuperview()
    newsResponseView = nil
    newsViewsStackView?.removeFromSuperview()
    newsViewsStackView = nil
    newsLikesControl?.removeFromSuperview()
    newsLikesControl?.numberOfLikes = 0
    newsLikesControl?.isLiked = false
    newsLikesControl?.likeButton.setNeedsDisplay()
    newsLikesControl = nil
    commentButton?.removeFromSuperview()
    commentButton = nil
    commentsNumberLabel?.removeFromSuperview()
    commentsNumberLabel?.text = nil
    commentsNumberLabel = nil
    shareButton?.removeFromSuperview()
    shareButton = nil
    sharesNumberLabel?.removeFromSuperview()
    sharesNumberLabel?.text = nil
    sharesNumberLabel = nil
    newsViewsImageView?.removeFromSuperview()
    newsViewsImageView = nil
    newsViewsNumberLabel?.removeFromSuperview()
    newsViewsNumberLabel?.text = nil
    newsViewsNumberLabel = nil
  }
  
  
  //MARK: - CollectionView
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let numberOfPhotos = photos?.count else {return 0}
    if numberOfPhotos > 5 {
      return 5
    } else {
      return numberOfPhotos
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostPhotoCell", for: indexPath) as! PostPhotoCollectionViewCell
    guard let photoUrls = self.photoUrls else {return UICollectionViewCell()}
    cell.configure(with: photoUrls[indexPath.item])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard let collectionHeight = self.postPhotosCollectionView?.frame.height, let collectionWidth = self.postPhotosCollectionView?.frame.width else {return CGSize.zero}
    
    //arrays of heights based on image count
    let arrayHeightOf5: [CGFloat] = [collectionHeight/2, collectionHeight/2, collectionHeight/3, collectionHeight/3, collectionHeight/3]
    let arrayHeightOf4: [CGFloat] = [collectionHeight, collectionHeight/3, collectionHeight/3, collectionHeight/3]
    let arrayHeightOf3: [CGFloat] = [collectionHeight, collectionHeight/2, collectionHeight/2]
    
    var cellHeight: CGFloat
    var index = indexPath.item
    guard let numberOfPhotos = photos?.count else {return CGSize.zero}
    if numberOfPhotos >= 5 {
      if index > 4 {
        index = 4
      }
      cellHeight = arrayHeightOf5[index]
      return CGSize(width: collectionWidth/2, height: cellHeight)
    }
    switch numberOfPhotos {
    case 2:
      return CGSize(width: collectionWidth/2, height: collectionHeight)
    case 3:
      cellHeight = arrayHeightOf3[index]
      return CGSize(width: collectionWidth/2, height: cellHeight)
    case 4:
      cellHeight = arrayHeightOf4[index]
      return CGSize(width: collectionWidth/2, height: cellHeight)
    default:
      return CGSize(width: collectionWidth, height: collectionHeight)
    }
  }
  
  //MARK: - Helpers
  private func getSource<T> (from type: T.Type, for id: Int) where T: Object, T: HasParameters {
      guard let sourceArray = try? Realm().objects(T.self).filter("id = %@", id) else {return}
      let source = Array(sourceArray)[0]
      sourceView.sourceImageURL = source.photoURL
      if T.self == User.self {
        let sourceUser = source as! User
        self.sourceView.sourceNameText = sourceUser.firstName + " " + sourceUser.lastName
      } else if T.self == Group.self {
        let sourceGroup = source as! Group
        self.sourceView.sourceNameText = sourceGroup.name
    }
  }
  
  private func getLabelSize(text: String, font: UIFont) -> CGSize {
    let maxWidth = screenWidth - sourceNameLeftOffset - sourceNameRightOffset
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


