//
//  GroupsCell.swift
//  Network
//
//  Created by Anastasia Romanova on 10/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class GroupsCell: UITableViewCell {

  @IBOutlet weak var groupImage: UIImageView!
  @IBOutlet weak var groupName: UILabel!
  
  public func configure(with group: Group) {
    groupImage.kf.indicatorType = .activity
    groupImage.kf.setImage(with: URL(string: group.photoURL))
    groupName.text = group.name
  }

}
