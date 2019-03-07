//
//  FriendsCell.swift
//  Network
//
//  Created by Anastasia Romanova on 10/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import Kingfisher

class FriendsCell: UITableViewCell {
  
  @IBOutlet weak var friendPhoto: PhotoView!
  @IBOutlet weak var friendName: UILabel!

  
  public func configure(with user: User, by indexPath: IndexPath, service: PhotoService?) {
    friendPhoto.containerView.image = service?.photo(atIndexpath: indexPath, byURL: user.photoURL)
    friendName.text = "\(user.firstName) \(user.lastName)"
  }

}
