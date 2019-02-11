//
//  NewsfeedCell.swift
//  Network
//
//  Created by Anastasia Romanova on 21/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

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
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  func configure(sourceName: String, sourcePhoto: UIImage, postTime: Int, postText: String, numberOfLikes: Int, commentsNumber: Int, sharesNumber: Int, numberOfViews: Int, isLiked: Bool) {
    self.sourceName.text = sourceName
    self.sourcePhoto.image = sourcePhoto
    self.postTime.text = String(postTime)
    self.postText.text = postText
    self.postText.translatesAutoresizingMaskIntoConstraints = true
    self.postText.sizeToFit()
    if self.postText.frame.height > 100 {
      self.postText.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
      self.postText.frame = CGRect(x: self.postText.frame.minX, y: self.postText.frame.minY, width: self.postText.frame.width, height: 100)
      self.postText.isScrollEnabled = true
      self.postText.flashScrollIndicators()
    }
    self.postText.backgroundColor = .clear
    self.newsLikes.numberOfLikes = numberOfLikes
    self.commentsNumber.text = String(commentsNumber)
    self.sharesNumber.text = String(sharesNumber)
    self.newsLikes.isLiked = isLiked
    self.newsLikes.setupView()
    self.newsViews.text = String(numberOfViews)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    sourceName.text = nil
    sourcePhoto.image = nil
    postTime.text = nil
    postText.text = nil
    newsLikes.numberOfLikes = 0
    commentsNumber.text = nil
    sharesNumber.text = nil
    newsViews.text = nil
    newsLikes.isLiked = false
    newsLikes.likeButton.setNeedsDisplay()
  }
  
}
