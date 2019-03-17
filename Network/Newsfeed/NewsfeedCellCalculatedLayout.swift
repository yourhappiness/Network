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
  private var sourcePhoto: UIImageView = {
    let photo = UIImageView()
    photo.contentMode = .scaleAspectFit
    photo.backgroundColor = .clear
    return photo
  }()
  private let sourceName = UILabel()
  private let postTime = UILabel()
  private var postText: UITextView? = nil
  private var postPhotosCollectionView: UICollectionView? = nil
  private var newsResponse: UIView? = nil
  private var newsViewsControl: UIView? = nil
  //Response views
  private var newsLikesControl: LikeControl? = nil
  private var commentButton: UIButton? = nil
  private var commentsNumber: UILabel? = nil
  private var shareButton: UIButton? = nil
  private var sharesNumber: UILabel? = nil
  //NewsViews views
  private var newsViewsImage: UIImageView? = nil
  private var newsViewsNumber: UILabel? = nil
  
  //MARK: - Privates
  private var photos: [Photo]?
  private var photoUrls: [URL]?
  private let sourcePhotoWidth: CGFloat = 50
  private let xOffsetForSourcePhotoAndPostText: CGFloat = 12
  private let yOffsetForSourcePhoto: CGFloat = 4
  private let sourceNameLeftOffset: CGFloat = 18
  private let sourceNameRightOffset: CGFloat = 12
  private let sourceNameTopOffset: CGFloat = 14
  private let sourceNameBottomOffset: CGFloat = 7
  private let ySpaceBetweenElements: CGFloat = 15
  private let xOffsetForPostPhotos: CGFloat = 10
  private var postPhotosOriginY: CGFloat = 0
  private var newsResponseSpaceBetweenElements:CGFloat = 5
  private var screenWidth: CGFloat = 0
  
  //MARK: - Cell size
  public var cellHeight: CGFloat = 0
  
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
    sourceName.font = UIFont.systemFont(ofSize: 15)
    sourceName.numberOfLines = 0
    self.contentView.addSubview(sourceName)
    
    postTime.font = UIFont.systemFont(ofSize: 13)
    postTime.textColor = UIColor.darkGray
    postTime.numberOfLines = 0
    self.contentView.addSubview(postTime)
    
    self.contentView.addSubview(sourcePhoto)
  }
  
  func configure(with pieceOfNews: NewsfeedCompatible, postTime: String, using urls: [URL]?, for screenWidth: CGFloat) {
    self.screenWidth = screenWidth
    if pieceOfNews.sourceId > 0 {
      self.getSource(from: User.self, for: pieceOfNews.sourceId)
    } else if pieceOfNews.sourceId < 0 {
      self.getSource(from: Group.self, for: -pieceOfNews.sourceId)
    }

    self.postTime.text = postTime
    
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
        self.postText = UITextView()
        self.postText?.backgroundColor = self.backgroundColor
        self.postText?.font = UIFont.systemFont(ofSize: 12)
        postText?.isScrollEnabled = false
        postText?.isEditable = false
        postText?.textAlignment = .justified
        postText?.dataDetectorTypes = .all
        self.postText?.text = element.postText
        self.contentView.addSubview(postText!)
      }
      newsResponse = UIView(frame: .zero)
      self.contentView.addSubview(newsResponse!)
      newsLikesControl = LikeControl(frame: .zero)
      newsLikesControl?.numberOfLikes = element.numberOfLikes
      newsLikesControl?.isLiked = element.isLiked
      let commentImage = UIImage(named: "Comment")
      commentButton = UIButton(type: .custom)
      commentButton?.setImage(commentImage, for: .normal)
      commentsNumber = UILabel(frame: .zero)
      commentsNumber?.font = UIFont.systemFont(ofSize: 15)
      commentsNumber?.textColor = .yellow
      commentsNumber?.numberOfLines = 0
      commentsNumber?.text = String(element.commentsNumber)
      let shareImage = UIImage(named: "Share")
      shareButton = UIButton(type: .custom)
      shareButton?.setImage(shareImage, for: .normal)
      sharesNumber = UILabel(frame: .zero)
      sharesNumber?.font = UIFont.systemFont(ofSize: 15)
      sharesNumber?.textColor = .yellow
      sharesNumber?.numberOfLines = 0
      sharesNumber?.text = String(element.sharesNumber)
      newsResponse?.addSubview(newsLikesControl!)
      newsResponse?.addSubview(commentButton!)
      newsResponse?.addSubview(commentsNumber!)
      newsResponse?.addSubview(shareButton!)
      newsResponse?.addSubview(sharesNumber!)
      newsLikesControl?.centerYAnchor.constraint(equalTo: newsResponse!.centerYAnchor).isActive = true
      commentButton?.centerYAnchor.constraint(equalTo: newsResponse!.centerYAnchor).isActive = true
      commentsNumber?.centerYAnchor.constraint(equalTo: newsResponse!.centerYAnchor).isActive = true
      shareButton?.centerYAnchor.constraint(equalTo: newsResponse!.centerYAnchor).isActive = true
      sharesNumber?.centerYAnchor.constraint(equalTo: newsResponse!.centerYAnchor).isActive = true
      
      
    }
    self.layoutSubviews()
  }

  //MARK: - Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    //layout source
    setSourcePhotoFrame()
    setSourceNameFrame()
    sourceName.backgroundColor = self.backgroundColor
    setPostTimeFrame()
    postTime.backgroundColor = self.backgroundColor
    self.cellHeight = yOffsetForSourcePhoto + sourcePhoto.frame.height
    //layout postText
    if self.postText != nil {
      setPostTextFrame()
      self.cellHeight = self.cellHeight + ySpaceBetweenElements + postText!.frame.height + ySpaceBetweenElements
    }
    //layout CollectionView
    if self.postPhotosCollectionView != nil {
      self.setPostPhotosCollectionViewFrame()
      self.cellHeight = self.cellHeight + ySpaceBetweenElements + postPhotosCollectionView!.frame.height + ySpaceBetweenElements
    }
    //layout newsResponse
    if self.newsResponse != nil {
      setNewsResponseFrame()
      self.commentsNumber?.backgroundColor = self.backgroundColor
      self.sharesNumber?.backgroundColor = self.backgroundColor
      self.cellHeight = self.cellHeight + ySpaceBetweenElements + self.newsResponse!.frame.height
    }
    //layout viewsControl
    
    
    //set contentSize
    let contentViewSize = CGSize(width: self.contentView.frame.width, height: cellHeight)
    self.contentView.frame = CGRect(origin: contentView.frame.origin, size: contentViewSize)
  }
  
  private func setSourcePhotoFrame() {
    let sourcePhotoSize = CGSize(width: sourcePhotoWidth, height: sourcePhotoWidth)
    let sourcePhotoOrigin = CGPoint(x: self.contentView.bounds.minX + xOffsetForSourcePhotoAndPostText, y: self.contentView.bounds.minY + yOffsetForSourcePhoto)
    sourcePhoto.frame = CGRect(origin: sourcePhotoOrigin, size: sourcePhotoSize)
  }
  
  private func setSourceNameFrame() {
    guard let sourceText = sourceName.text else {return}
    let sourceNameSize = self.getLabelSize(text: sourceText, font: sourceName.font)
    let sourceNameX = sourcePhoto.frame.maxX + sourceNameLeftOffset
    let sourceNameOrigin = CGPoint(x: sourceNameX, y: self.contentView.bounds.minY + sourceNameTopOffset)
    
    sourceName.frame = CGRect(origin: sourceNameOrigin, size: sourceNameSize)
  }
  
  private func setPostTimeFrame() {
    guard let postTimeText = postTime.text else {return}
    let postTimeSize = self.getLabelSize(text: postTimeText, font: postTime.font)
    let postTimeX = sourceName.frame.minX
    let postTimeY = sourceName.frame.maxY + sourceNameBottomOffset
    let postTimeOrigin = CGPoint(x: postTimeX, y: postTimeY)
    
    postTime.frame = CGRect(origin: postTimeOrigin, size: postTimeSize)
  }
  
  private func setPostTextFrame() {
    var postTextSize = postText!.sizeThatFits(CGSize(width: screenWidth - xOffsetForSourcePhotoAndPostText * 2, height: .greatestFiniteMagnitude))
    if postTextSize.height > 100 {
      postTextSize = CGSize(width: postTextSize.width, height: 100)
      postText?.isScrollEnabled = true
    }
    let postTextX = self.contentView.bounds.minX + xOffsetForSourcePhotoAndPostText
    let postTextY = sourcePhoto.frame.maxY + ySpaceBetweenElements
    let postTextOrigin = CGPoint(x: postTextX, y: postTextY)
    
    postText?.frame = CGRect(origin: postTextOrigin, size: postTextSize)
  }
  
  private func setPostPhotosCollectionViewFrame() {
    let postPhotosWidth: CGFloat = screenWidth - xOffsetForPostPhotos * 2
    let postPhotosOriginX: CGFloat = self.contentView.bounds.minX + xOffsetForPostPhotos
    if self.postText != nil {
      self.postPhotosOriginY = self.postText!.frame.maxY + ySpaceBetweenElements
    } else {
      self.postPhotosOriginY = self.sourcePhoto.frame.maxY + ySpaceBetweenElements
    }
    
    let postPhotosOriginPoint = CGPoint(x: postPhotosOriginX, y: self.postPhotosOriginY)
    let postPhotoSize = CGSize(width: postPhotosWidth, height: postPhotosWidth)
    self.postPhotosCollectionView?.frame =  CGRect(origin: postPhotosOriginPoint, size: postPhotoSize)
  }

  private func setNewsResponseFrame() {
    self.newsLikesControl?.setupView()
    let newsLikesControlSize = CGSize(width: newsLikesControl!.frame.width, height: 22)
    let newsLikesControlOrigin = CGPoint(x: xOffsetForSourcePhotoAndPostText + newsResponseSpaceBetweenElements, y: newsLikesControl!.frame.minY)
    self.newsLikesControl?.frame = CGRect(origin: newsLikesControlOrigin, size: newsLikesControlSize)
    
    let commentButtonSize = CGSize(width: 22, height: 22)
    let commentButtonOrigin = CGPoint(x: newsLikesControl!.frame.maxX + newsResponseSpaceBetweenElements, y: commentButton!.frame.minY)
    self.commentButton?.frame = CGRect(origin: commentButtonOrigin, size: commentButtonSize)
    
    guard let commentsNumberText = commentsNumber!.text else {return}
    let commentsNumberSize = self.getLabelSize(text: commentsNumberText, font: commentsNumber!.font)
    let commentsNumberX = commentButton!.frame.maxX + newsResponseSpaceBetweenElements
    let commentsNumberOrigin = CGPoint(x: commentsNumberX, y: commentsNumber!.frame.minY)
    
    commentsNumber?.frame = CGRect(origin: commentsNumberOrigin, size: commentsNumberSize)
    
    let shareButtonSize = CGSize(width: 28, height: 28)
    let shareButtonOrigin = CGPoint(x: commentsNumber!.frame.maxX + newsResponseSpaceBetweenElements, y: shareButton!.frame.minY)
    self.shareButton?.frame = CGRect(origin: shareButtonOrigin, size: shareButtonSize)
    
    guard let sharesNumberText = sharesNumber!.text else {return}
    let sharesNumberSize = self.getLabelSize(text: sharesNumberText, font: sharesNumber!.font)
    let sharesNumberX = shareButton!.frame.maxX + newsResponseSpaceBetweenElements
    let sharesNumberOrigin = CGPoint(x: sharesNumberX, y: commentsNumber!.frame.minY)
    
    sharesNumber?.frame = CGRect(origin: sharesNumberOrigin, size: sharesNumberSize)
    
    let commentsWidth = commentButton!.frame.width + commentsNumber!.frame.width
    let shareWidth = shareButton!.frame.width + sharesNumber!.frame.width
    let width = newsLikesControl!.frame.width + newsResponseSpaceBetweenElements * 6 + commentsWidth + shareWidth
    let height = max(newsLikesControl!.frame.height, commentButton!.frame.height, commentsNumber!.frame.height, shareButton!.frame.height, sharesNumber!.frame.height)
    let size = CGSize(width: width, height: height)
    var y: CGFloat
    if self.postText != nil {
      if self.postPhotosCollectionView != nil {
        y = self.postPhotosCollectionView!.frame.maxY + ySpaceBetweenElements
      } else {
        y = self.postText!.frame.maxY + ySpaceBetweenElements
      }
    } else {
      if self.postPhotosCollectionView != nil {
        y = self.postPhotosCollectionView!.frame.maxY + ySpaceBetweenElements
      } else {
        y = self.sourcePhoto.frame.maxY + ySpaceBetweenElements
      }
    }
    let origin = CGPoint(x: xOffsetForSourcePhotoAndPostText, y: y)
    
    newsResponse?.frame = CGRect(origin: origin, size: size)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    cellHeight = 0
    sourceName.text = nil
    sourcePhoto.image = nil
    postTime.text = nil
    postText?.removeFromSuperview()
    postText?.text = nil
    postText = nil
    photos = nil
    photoUrls = nil
    postPhotosCollectionView?.removeFromSuperview()
    postPhotosCollectionView = nil
    newsResponse?.removeFromSuperview()
    newsResponse = nil
    newsViewsControl?.removeFromSuperview()
    newsViewsControl = nil
    newsLikesControl?.removeFromSuperview()
    newsLikesControl?.numberOfLikes = 0
    newsLikesControl?.isLiked = false
    newsLikesControl?.likeButton.setNeedsDisplay()
    newsLikesControl = nil
    commentButton?.removeFromSuperview()
    commentButton = nil
    commentsNumber?.removeFromSuperview()
    commentsNumber?.text = nil
    commentsNumber = nil
    shareButton?.removeFromSuperview()
    shareButton = nil
    sharesNumber?.removeFromSuperview()
    sharesNumber?.text = nil
    sharesNumber = nil
    newsViewsImage?.removeFromSuperview()
    newsViewsImage = nil
    newsViewsNumber?.removeFromSuperview()
    newsViewsNumber?.text = nil
    newsViewsNumber = nil
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
      self.sourcePhoto.kf.indicatorType = .activity
      self.sourcePhoto.kf.setImage(with: URL(string: source.photoURL))
      if T.self == User.self {
        let sourceUser = source as! User
        self.sourceName.text = sourceUser.firstName + " " + sourceUser.lastName
      } else if T.self == Group.self {
        let sourceGroup = source as! Group
        self.sourceName.text = sourceGroup.name
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


