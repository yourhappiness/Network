//
//  PostPhotoCollectionViewCell.swift
//  Network
//
//  Created by Anastasia Romanova on 28/02/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

class PostPhotoCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var postPhoto: UIImageView!
  
  func configure(with photo: Photo) {
    postPhoto.kf.setImage(with: URL(string: photo.photoURL))
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.postPhoto.image = nil
  }
  
}
