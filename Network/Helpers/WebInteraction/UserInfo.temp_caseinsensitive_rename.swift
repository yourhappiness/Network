//
//  userInfo.swift
//  Network
//
//  Created by Anastasia Romanova on 22/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import Foundation
import Alamofire

struct UserInfo <T: HasParameters> {
  //версия
  let vkV = "5.92"
  //базовый URL
  let baseURL = "https://api.vk.com/method"
  //токен
  let access_token = Session.instance.token
  
  let instance: T
  var parameters: Parameters
  
  mutating func get(userId: Int?) {
    //путь для метода
    let path = "/\(instance.type).get"
    //параметры
    if T.self == UserFriends.self {
      parameters = [
        "userId": userId ?? Session.instance.userId,
        "order": "hints",
        "fields": instance.fields,
        "access_token": access_token,
        "v": vkV
      ]
    } else if T.self == UserGroups.self {
      parameters = [
        "userId": userId ?? Session.instance.userId,
        "extended": "1",
        "fields": instance.fields,
        "access_token": access_token,
        "v": vkV
      ]
    }
    
    //составление URL
    let url = baseURL + path
    //запрос
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON {response in
      print(response.value as Any)
    }
  }
}

protocol HasParameters {
  var type: String {get set}
  var fields: [String] {get set}
}

