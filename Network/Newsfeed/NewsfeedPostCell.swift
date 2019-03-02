//
//  NewsfeedCell.swift
//  Network
//
//  Created by Anastasia Romanova on 21/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import RealmSwift

class NewsfeedPostCell: UITableViewCell {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var sourcePhoto: UIImageView!
  @IBOutlet weak var sourceName: UILabel!
  @IBOutlet weak var postTime: UILabel!
  @IBOutlet weak var postText: UITextView!
  @IBOutlet weak var postPhoto: UIImageView!
  @IBOutlet weak var newsResponse: UIView!
  @IBOutlet weak var newsLikes: LikeControl!
  @IBOutlet weak var commentButton: UIButton!
  @IBOutlet weak var commentsNumber: UILabel!
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var sharesNumber: UILabel!
  @IBOutlet weak var newsViewsControl: UIView!
  @IBOutlet weak var newsViews: UILabel!
  
  var sourceUser: Results<User>?
  var sourceGroup: Results<Group>?
  var photos: [Photo]?
  

  //MARK: - Cell configuration
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.postText.translatesAutoresizingMaskIntoConstraints = true
    self.newsResponse.topAnchor.constraint(greaterThanOrEqualTo: self.postText.bottomAnchor, constant: 15).isActive = true
  }
  
  func configure(with pieceOfNews: NewsfeedPost, completion: @escaping () -> Void) {
    if pieceOfNews.sourceId > 0 {
      self.sourceUser = try? Realm().objects(User.self).filter("id = %@", pieceOfNews.sourceId)
      guard let sourceUser = self.sourceUser else {return}
      let source = Array(sourceUser)[0]
      self.sourceName.text = source.firstName + " " + source.lastName
      self.sourcePhoto.kf.setImage(with: URL(string: source.photoURL))
    } else if pieceOfNews.sourceId < 0 {
      self.sourceGroup = try? Realm().objects(Group.self).filter("id = %@", -pieceOfNews.sourceId)
      guard let sourceGroup = self.sourceGroup else {return}
      let source = Array(sourceGroup)[0]
      self.sourceName.text = source.name
      self.sourcePhoto.kf.setImage(with: URL(string: source.photoURL))
    }
    self.postTime.text = self.getTimePassed(from: pieceOfNews.postDate)
    if pieceOfNews.postText == "" {
      self.postText.frame = CGRect(x: self.postText.frame.minX, y: self.postText.frame.minY, width: 0, height: 0)
      self.postText.setNeedsLayout()
    } else {
      self.postText.text = pieceOfNews.postText
      self.postText.sizeToFit()
      if self.postText.frame.height > 100 {
        self.postText.frame = CGRect(x: self.postText.frame.minX, y: self.postText.frame.minY, width: self.frame.width - 24, height: 100)
        self.postText.isScrollEnabled = true
        self.postText.flashScrollIndicators()
      } else {
        self.postText.frame = CGRect(x: self.postText.frame.minX, y: self.postText.frame.minY, width: self.frame.width - 24, height: self.postText.frame.height)
      }
      self.postText.setNeedsLayout()
      self.postText.layoutIfNeeded()
    }
    self.postText.backgroundColor = .clear
    self.photos = pieceOfNews.photos
    if let photo = self.photos?[0] {
//      self.postPhoto.translatesAutoresizingMaskIntoConstraints = false
      self.postPhoto.kf.setImage(with: URL(string: photo.photoURL)) { _ in
        completion()
      }
//      self.postPhoto.frame = CGRect(x: self.postPhoto.frame.minX, y: self.postPhoto.frame.minY, width: self.frame.width - 20, height: (self.frame.width - 20) * CGFloat(photo.height/photo.width))
//      self.postPhoto.transform = CGAffineTransform(scaleX: 0, y: CGFloat(photo.height/photo.width))
    } else {
      self.postPhoto.frame = CGRect(x: self.postPhoto.frame.minX, y: self.postPhoto.frame.minY, width: 0, height: 0)
      self.postPhoto.setNeedsLayout()
    }
    self.newsLikes.numberOfLikes = pieceOfNews.numberOfLikes
    self.commentsNumber.text = String(pieceOfNews.commentsNumber)
    self.sharesNumber.text = String(pieceOfNews.sharesNumber)
    self.newsLikes.isLiked = pieceOfNews.isLiked
    self.newsLikes.setupView()
    self.newsViews.text = String(pieceOfNews.numberOfViews)
    self.layoutSubviews()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    sourceName.text = nil
    sourcePhoto.image = nil
    postTime.text = nil
    postText.text = nil
    postText.frame = CGRect(x: self.postText.frame.minX, y: self.postText.frame.minY, width: self.frame.width - 24, height: 1)
    postText.setNeedsLayout()
    postText.isScrollEnabled = false
    photos = nil
    self.postPhoto.image = nil
    self.postPhoto.frame = CGRect(x: self.postPhoto.frame.minX, y: self.postPhoto.frame.minY, width: self.frame.width - 20, height: 1)
    self.postPhoto.setNeedsLayout()
    newsLikes.numberOfLikes = 0
    commentsNumber.text = nil
    sharesNumber.text = nil
    newsViews.text = nil
    newsLikes.isLiked = false
    newsLikes.likeButton.setNeedsDisplay()
  }
  
  func getTimePassed(from time: Double) -> String {
    let date = Date(timeIntervalSince1970: time)
    let timeInterval = Date().timeIntervalSince(date)
    let strDate: String
    if timeInterval >= 2592000 {
      strDate = "\(Int(round(timeInterval/2592000))) months ago"
    } else if timeInterval >= 86400 {
      strDate = "\(Int(round(timeInterval/86400))) days ago"
    } else if timeInterval >= 3600 {
      strDate = "\(Int(round(timeInterval/3600))) hours ago"
    } else if timeInterval >= 60 {
      strDate = "\(Int(round(timeInterval/60))) minutes ago"
    } else {
      strDate = "\(Int(round(timeInterval))) seconds ago"
    }
    return strDate
  }
}
