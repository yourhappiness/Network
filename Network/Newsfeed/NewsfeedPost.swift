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

final class NewsfeedPost: NewsfeedParameters {

  static func parseJSON(json: JSON) -> NewsfeedPost {
    let item = NewsfeedPost(json: json)
    return item
  }

  var sourceId: Int
  var postDate: Double
  var postText: String
  var commentsNumber: Int
  var numberOfLikes: Int
  var isLiked: Bool
  var sharesNumber: Int
  var numberOfViews: Int
  static var nextFrom: String?
  
  static func getParameters() -> Parameters {
    var parameters: Parameters
    guard self.nextFrom != nil else {
      parameters = [
        "filters": "post",
        "access_token": Session.instance.token,
        "v": "5.92"
      ]
      return parameters
    }
      parameters = [
      "filters": "post",
      "start_from": nextFrom as Any,
      "count": "10",
      "access_token": Session.instance.token,
      "v": "5.92"
    ]
    return parameters
  }
  
  init (json: JSON) {
    self.sourceId = json["source_id"].intValue
    self.postDate = json["date"].doubleValue
    self.postText = json["text"].stringValue
    self.commentsNumber = json["comments"]["count"].intValue
    self.numberOfLikes = json["likes"]["count"].intValue
    self.isLiked = json["likes"]["user_likes"].boolValue
    self.sharesNumber = json["reposts"]["count"].intValue
    self.numberOfViews = json["views"]["count"].intValue
  }
  
}
