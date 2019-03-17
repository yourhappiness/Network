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

  public func configure(with user: User) {
    friendPhoto.containerView.kf.indicatorType = .activity
    friendPhoto.containerView.kf.setImage(with: URL(string: user.photoURL))
    friendName.text = "\(user.firstName) \(user.lastName)"
  }

}
