//
//  HasParameters.swift
//  Network
//
//  Created by Anastasia Romanova on 05/01/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol HasParameters: class {
  static var path: String {get}
  static var parameters: Parameters {get}
  
  var photoURL: String {get set}
  
  static func parseJSON(json: JSON) -> Self
}
