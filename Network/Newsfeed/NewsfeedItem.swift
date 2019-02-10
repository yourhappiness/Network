//
//  NewsfeedItem.swift
//  Network
//
//  Created by Anastasia Romanova on 21/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class NewsfeedItem {
  var sourceName: String
  var sourcePhoto: UIImage
  var postTime: Date
  var postText: String
  var numberOfViews: Int
  var numberOfLikes: Int
  var commentsNumber: Int
  var sharesNumber: Int
  var isLiked: Bool
  
  init(sourceName: String, sourcePhoto: UIImage, postTime: Date, postText: String, numberOfViews: Int, numberOfLikes: Int, commentsNumber: Int, sharesNumber: Int, isLiked: Bool) {
    self.sourceName = sourceName
    self.sourcePhoto = sourcePhoto
    self.postTime = postTime
    self.postText = postText
    self.numberOfLikes = numberOfLikes
    self.numberOfViews = numberOfViews
    self.commentsNumber = commentsNumber
    self.sharesNumber = sharesNumber
    self.isLiked = isLiked
  }
}
