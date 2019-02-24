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
  @IBOutlet weak var newsLikes: LikeControl!
  @IBOutlet weak var commentButton: UIButton!
  @IBOutlet weak var commentsNumber: UILabel!
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var sharesNumber: UILabel!
  @IBOutlet weak var newsViews: UILabel!
  
  var sourceUser: Results<User>?
  var sourceGroup: Results<Group>?
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      self.postText.translatesAutoresizingMaskIntoConstraints = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  func configure(with pieceOfNews: NewsfeedPost) {
    if pieceOfNews.sourceId > 0 {
      self.sourceUser = try? Realm().objects(User.self).filter("id = %@", pieceOfNews.sourceId)
      guard let sourceUser = self.sourceUser else {return}
      let source = Array(sourceUser)[0]
      self.sourceName.text = source.firstName + source.lastName
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
//      self.postText.frame = CGRect.zero
      self.postText.frame = CGRect(x: self.postText.frame.minX, y: self.postText.frame.minY, width: self.frame.width, height: 1)
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
    }
    self.postText.backgroundColor = .clear
    self.newsLikes.numberOfLikes = pieceOfNews.numberOfLikes
    self.commentsNumber.text = String(pieceOfNews.commentsNumber)
    self.sharesNumber.text = String(pieceOfNews.sharesNumber)
    self.newsLikes.isLiked = pieceOfNews.isLiked
    self.newsLikes.setupView()
    self.newsViews.text = String(pieceOfNews.numberOfViews)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    sourceName.text = nil
    sourcePhoto.image = nil
    postTime.text = nil
    postText.text = nil
    postText.frame = CGRect(x: self.postText.frame.minX, y: self.postText.frame.minY, width: self.frame.width - 24, height: 1)
    postText.isScrollEnabled = false
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
