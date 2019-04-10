//
//  User.swift
//  Network
//
//  Created by Anastasia Romanova on 25/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Alamofire

final class User: Object, HasParameters {
  static func parseJSON(json: JSON) -> User {
    let user = User(json: json)
    return user
  }
  
  @objc dynamic var id: Int = 0
  @objc dynamic var firstName: String = ""
  @objc dynamic var lastName: String = ""
  @objc dynamic var photoURL: String = ""
  @objc dynamic var deactivated: Bool = false
  @objc dynamic var isFriend: Bool = false
  var photos = List<Photo>()

  static var path: String = "/friends.get"
  static var parameters: Parameters = [
    "userId": Session.instance.userId,
    "order": "hints",
    "fields": "photo_50",
    "access_token": Session.instance.token,
    "v": "5.92"
  ]
  
  convenience init (json: JSON, photos: [Photo] = []) {
    self.init()
    self.id = json["id"].intValue
    self.firstName = json["first_name"].stringValue
    self.lastName = json["last_name"].stringValue
    self.photoURL = json["photo_50"].stringValue
    if json["deactivated"] != JSON.null {
      self.deactivated = true
    }
    self.photos.append(objectsIn: photos)
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }

}
