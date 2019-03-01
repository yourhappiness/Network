//
//  NewsfeedParameters.swift
//  Network
//
//  Created by Anastasia Romanova on 12/02/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol NewsfeedParameters: class {
  static func getParameters() -> Parameters
  
  static func parseJSON(json: JSON) -> Self
}
