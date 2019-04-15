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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    postPhoto = UIImageView(frame: self.bounds)
    self.addSubview(postPhoto!)
    postPhoto?.translatesAutoresizingMaskIntoConstraints = false
    postPhoto?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    postPhoto?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    postPhoto?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    postPhoto?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    postPhoto?.contentMode = .scaleAspectFit
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    postPhoto = UIImageView(frame: self.bounds)
    self.addSubview(postPhoto!)
    postPhoto?.translatesAutoresizingMaskIntoConstraints = false
    postPhoto?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    postPhoto?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    postPhoto?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    postPhoto?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    postPhoto?.contentMode = .scaleAspectFit
  }
  
  func configure(with url: URL, photoWidth: CGFloat, photoHeight: CGFloat, for height: CGFloat) {
    guard let postPhoto = self.postPhoto else {return}
    postPhoto.kf.setImage(with: url)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.postPhoto?.image = nil
  }
  
}
