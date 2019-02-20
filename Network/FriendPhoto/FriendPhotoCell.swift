//
//  FriendPhotoViewCell.swift
//  Network
//
//  Created by Anastasia Romanova on 10/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class FriendPhotoCell: UICollectionViewCell {
  @IBOutlet weak var friendImage: PhotoView!
  
  public func configure(with photo: Photo) {
    friendImage.containerView.kf.setImage(with: URL(string: photo.photoURL))
    friendImage.containerView.backgroundColor = .black
  }
  
}
