//
//  NewsfeedPost.swift
//  Network
//
//  Created by Anastasia Romanova on 21/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift
import Kingfisher

final class NewsfeedPost: NewsfeedCompatible {

  static func parseJSON(json: JSON) -> NewsfeedPost {
    let item = NewsfeedPost(json: json)
    return item
  }

  var sourceId: Int
  var postDate: Double
  var postText: String?
  var photos: [Photo]?
  var commentsNumber: Int
  var numberOfLikes: Int
  var isLiked: Bool
  var sharesNumber: Int
  var numberOfViews: Int
  
  init (json: JSON) {
    self.sourceId = json["source_id"].intValue
    self.postDate = json["date"].doubleValue
    if json["text"].stringValue != "" {
      self.postText = json["text"].stringValue
    } else {
      self.postText = nil
    }
    self.commentsNumber = json["comments"]["count"].intValue
    self.numberOfLikes = json["likes"]["count"].intValue
    self.isLiked = json["likes"]["user_likes"].boolValue
    self.sharesNumber = json["reposts"]["count"].intValue
    self.numberOfViews = json["views"]["count"].intValue
    let attachs = json["attachments"].arrayValue.map {$0["type"].stringValue}
    if attachs.contains("photo") {
      self.photos = []
      for (index, attach) in attachs.enumerated() {
        if attach == "photo" {
          self.photos?.append(Photo.init(json: json["attachments"].array![index]["photo"]))
        }
      }
    }
  }
  
}
