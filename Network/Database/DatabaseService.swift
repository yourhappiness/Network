//
//  DatabaseService.swift
//  Network
//
//  Created by Anastasia Romanova on 13/01/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class DatabaseService {

  @discardableResult
  static func saveVKData <Class: Object> (_ data: [Class], config: Realm.Configuration = Realm.Configuration.defaultConfiguration, update: Bool = true) throws -> Realm? {
    let realm = try Realm(configuration: config)
    print(realm.configuration.fileURL as Any)
    try realm.write {
      realm.add(data, update: update)
    }
    return realm
  }
  
  static func loadVKData <Class: Object> (type: Class.Type, userId: Int? = nil, config: Realm.Configuration = Realm.Configuration.defaultConfiguration) -> Results<Class>? {
    let realm = try? Realm(configuration: config)
    print(realm?.configuration.fileURL as Any)
    if userId != nil {
      return realm?.objects(type).filter("userId == %@", userId as Any)
    } else {
      return realm?.objects(type)
    }
  }
  
  @discardableResult
  static func deleteVKData <Class: Object>(_ data: [Class], config: Realm.Configuration = Realm.Configuration.defaultConfiguration) throws -> Realm {
    let realm = try Realm(configuration: config)
    
    try realm.write {
      realm.delete(data)
    }
    return realm
  }
  
}
