//
//  NewsfeedCompatible.swift
//  Network
//
//  Created by Anastasia Romanova on 12/02/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol NewsfeedCompatible: class {
  var sourceId: Int {get set}
  var postDate: Double {get set}
  var photos: [Photo]? {get set}
  static func parseJSON(json: JSON) -> Self
}
