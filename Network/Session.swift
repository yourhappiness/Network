//
//  Session.swift
//  Network
//
//  Created by Anastasia Romanova on 16/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class Session {
  
  static let instance = Session()
  
  private init() {}
  
  var token: String = ""
  var userId: Int = 0
  
  //for newsfeed update
  var nextFrom: String?
}
