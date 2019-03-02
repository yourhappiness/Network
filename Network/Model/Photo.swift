//
//  Photo.swift
//  Network
//
//  Created by Anastasia Romanova on 26/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Alamofire

final class Photo: Object, HasParameters {
  static func parseJSON(json: JSON) -> Photo {
    let photo = Photo(json: json)
    return photo
  }
  
  @objc dynamic var uniqueId: String = ""
  @objc dynamic var id: Int = 0
  @objc dynamic var userId: Int = 0
  @objc dynamic var photoURL: String = ""
  @objc dynamic var numberOfLikes: Int = 0
  @objc dynamic var isLiked: Bool = false
  @objc dynamic var date: Double = 0.0
  @objc dynamic var width: Double = 0.0
  @objc dynamic var height: Double = 0.0
  var user = LinkingObjects(fromType: User.self, property: "photos")
  
  static var path: String = "/photos.get"
  
  static var parameters: Parameters = [
    "owner_id": Session.instance.userId,
    "album_id": "profile",
    "rev": "1",
    "extended": "1",
    "access_token": Session.instance.token,
    "v": "5.92"
  ]
  
  convenience init (json: JSON) {
    self.init()
    self.id = json["id"].intValue
    self.userId = json["owner_id"].intValue
    guard let result = json["sizes"].arrayValue.first(where: {$0["type"].stringValue == "x"}) else { return}
    self.photoURL = result["url"].stringValue
    self.width = result["width"].doubleValue
    self.height = result["height"].doubleValue
    self.numberOfLikes = json["likes"]["count"].intValue
    self.isLiked = json["likes"]["user_likes"].boolValue
    self.date = json["date"].doubleValue
    
    self.uniqueId = String(self.id) + String(self.userId)
  }
  
  override static func primaryKey() -> String? {
    return "uniqueId"
  }
  
}
