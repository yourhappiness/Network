//
//  PostPhotoCollectionViewCell.swift
//  Network
//
//  Created by Anastasia Romanova on 28/02/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

class PostPhotoCollectionViewCell: UICollectionViewCell {
  var postPhoto: UIImageView?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    postPhoto = UIImageView(frame: self.bounds)
    self.addSubview(postPhoto!)
    postPhoto?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    postPhoto?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    postPhoto?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    postPhoto?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    postPhoto?.contentMode = .scaleAspectFill
  }
  
  func configure(with photo: Photo) {
    awakeFromNib()
    postPhoto?.kf.setImage(with: URL(string: photo.photoURL))
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.postPhoto?.image = nil
  }
  
}
