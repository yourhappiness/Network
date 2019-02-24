//
//  NewsfeedPhoto.swift
//  Network
//
//  Created by Anastasia Romanova on 24/02/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift
import Kingfisher

final class NewsfeedPhoto: NewsfeedParameters {
  
  static func parseJSON(json: JSON) -> NewsfeedPhoto {
    let item = NewsfeedPhoto(json: json)
    return item
  }
  
  var sourceId: Int
  var postDate: Double
  var numberOfPhotos: Int

  static var nextFrom: String?
  
  static var path: String = "/newsfeed.get"
  
  static func getParameters() -> Parameters {
    var parameters: Parameters
    guard self.nextFrom != nil else {
      parameters = [
        "filters": "photo",
        "access_token": Session.instance.token,
        "v": "5.92"
      ]
      return parameters
    }
    parameters = [
      "filters": "photo",
      "start_from": nextFrom as Any,
      "access_token": Session.instance.token,
      "v": "5.92"
    ]
    return parameters
  }
  
  init (json: JSON) {
    self.sourceId = json["source_id"].intValue
    self.postDate = json["date"].doubleValue
    self.numberOfPhotos = json["photos"]["count"].intValue

  }
  
}
