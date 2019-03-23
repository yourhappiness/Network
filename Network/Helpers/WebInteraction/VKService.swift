//
//  VKService.swift
//  Network
//
//  Created by Anastasia Romanova on 22/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class VKService {
  //версия
  let vkV = "5.92"
  //базовый URL
  let baseURL = "https://api.vk.com/method"
  //токен
  let access_token = Session.instance.token
  
  func get <Class: Object> (userId: Int? = nil, completionHandler: @escaping ([Class]?, Error?) -> Void) where Class: HasParameters {
    //путь для метода
    let path = Class.path
    //параметры
    var parameters = Class.parameters
    if userId != nil, Class.self is Photo.Type {
      parameters = [
                "owner_id": userId ?? Session.instance.userId,
                "album_id": "profile",
                "rev": "1",
                "extended": "1",
                "access_token": access_token,
                "v": vkV
              ]
    }
    
    //составление URL
    let url = baseURL + path
    //запрос
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON(queue: DispatchQueue.global()) {response in
      switch response.result {
      case .failure(let error):
        completionHandler(nil, error)
      case .success(let value):
        let json = JSON(value)
        let data = json["response"]["items"].arrayValue.map { Class.parseJSON(json: $0)}
        completionHandler(data, nil)
      }
    }
  }

  //Получение групп по поисковому запросу
  func searchGroups(query: String, completionHandler: @escaping ([Group]?, Error?) -> Void) {
    //путь для метода
    let path = "/groups.search"
    //параметры
    let parameters: Parameters = [
      "q": query,
      "sort": "0",
      "access_token": access_token,
      "v": vkV
    ]
    //составление URL
    let url = baseURL + path
    //запрос
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON (queue: DispatchQueue.global()) {response in
      switch response.result {
      case .failure(let error):
        completionHandler(nil, error)
      case .success(let value):
        let json = JSON(value)
        let searchedGroups = json["response"]["items"].arrayValue.map { Group(json: $0)}
        
        completionHandler(searchedGroups, nil)
      }
    }
  }
  
  //Вступление/выход в/из группу/ы
  func joinOrLeaveGroup(id: Int, toJoin: Bool, completionHandler: @escaping (Bool?, Error?) -> Void) {
    //путь для метода
    var path = ""
    if toJoin {
      path = "/groups.join"
    } else {
      path = "/groups.leave"
    }
    //параметры
    let parameters: Parameters = [
      "group_id": id,
      "access_token": access_token,
      "v": vkV
    ]
    //составление URL
    let url = baseURL + path
    //запрос
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON (queue: DispatchQueue.global()) {response in
      switch response.result {
      case .failure(let error):
        completionHandler(nil, error)
      case .success(let value):
        let json = JSON(value)
        let response = json["response"].intValue
        if response == 1 {
          completionHandler(true, nil)
        } else {
          completionHandler(false, nil)
        }
      }
    }
  }
  
  //Отметка "Мне нравится"
  func likeDislike(toLike: Bool, objectToLike type: String = "photo", ownerId: Int, itemId id: Int, completionHandler: @escaping (Int?, Error?) -> Void) {
    //путь для метода
    var path = ""
    if toLike {
      path = "/likes.add"
    } else {
      path = "/likes.delete"
    }
    //параметры
    let parameters: Parameters = [
      "type": type,
      "owner_id": ownerId,
      "item_id": id,
      "access_token": access_token,
      "v": vkV
    ]
    //составление URL
    let url = baseURL + path
    //запрос
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON(queue: DispatchQueue.global()) {response in
      switch response.result {
      case .failure(let error):
        completionHandler(nil, error)
      case .success(let value):
        let json = JSON(value)
        let response = json["response"]["likes"].intValue
        completionHandler(response, nil)
      }
    }
  }
  
  //Получение новостей
  func getNews (nextFrom: String? = nil, completionHandler: @escaping ([NewsfeedCompatible]?, [User]?, [Group]?, Error?, String?) -> Void) {
    //путь для метода
    let path = "/newsfeed.get"
    //параметры
    var parameters: Parameters
    
    if nextFrom == nil {
      parameters = [
        "filters": "post,photo",
        "max_photos": "10",
        "count": "20",
        "access_token": Session.instance.token,
        "v": "5.92"
      ]
    } else {
      parameters = [
        "filters": "post,photo",
        "max_photos": "10",
        "start_from": nextFrom!,
        "count": "20",
        "access_token": Session.instance.token,
        "v": "5.92"
      ]
    }
    
    //составление URL
    let url = baseURL + path
    //запрос
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON(queue: DispatchQueue.global(qos: .userInteractive)) {response in
      switch response.result {
      case .failure(let error):
        completionHandler(nil, nil, nil, error, nil)
      case .success(let value):
        let json = JSON(value)
        let items: [NewsfeedCompatible] = json["response"]["items"].arrayValue.map {
          var item: NewsfeedCompatible
          if $0["type"].stringValue == "post" {
            item = NewsfeedPost.parseJSON(json: $0)
          } else {
            item = NewsfeedPhoto.parseJSON(json: $0)
          }
          return item
        }
        let users = json["response"]["profiles"].arrayValue.map { User.parseJSON(json: $0)}
        let groups = json["response"]["groups"].arrayValue.map { Group.parseJSON(json: $0)}
        let startFrom = json["response"]["next_from"].stringValue
        completionHandler(items, users, groups, nil, startFrom)
      }
    }
  }
}
