//
//  Group.swift
//  Network
//
//  Created by Anastasia Romanova on 26/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Alamofire

final class Group: Object, HasParameters {
  static func parseJSON(json: JSON) -> Group {
    let group = Group(json: json)
    return group
  }
  
  @objc dynamic var id: Int = 0
  @objc dynamic var name: String = ""
  @objc dynamic var photoURL: String = ""
  @objc dynamic var isUserGroup: Bool = false
  
  static var path: String = "/groups.get"
  static var parameters: Parameters = [
    "userId": Session.instance.userId,
    "extended": "1",
    "access_token": Session.instance.token,
    "v": "5.92"
  ]
  
 convenience init (json: JSON) {
    self.init()
    self.id = json["id"].intValue
    self.name = json["name"].stringValue
    self.photoURL = json["photo_50"].stringValue
  }

  override static func primaryKey() -> String? {
    return "id"
  }
  
}
