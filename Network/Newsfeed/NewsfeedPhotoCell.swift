//
//  NewsfeedPhotoCell.swift
//  Network
//
//  Created by Anastasia Romanova on 24/02/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit
import RealmSwift

class NewsfeedPhotoCell: UITableViewCell {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var sourcePhoto: UIImageView!
  @IBOutlet weak var sourceName: UILabel!
  @IBOutlet weak var postTime: UILabel!
  @IBOutlet weak var photoCollectionView: UICollectionView!
  
  var sourceUser: Results<User>?
  var sourceGroup: Results<Group>?
  
  func configure(with pieceOfNews: NewsfeedPost) {
    if pieceOfNews.sourceId > 0 {
      self.sourceUser = try? Realm().objects(User.self).filter("id = %@", pieceOfNews.sourceId)
      guard let sourceUser = self.sourceUser else {return}
      let source = Array(sourceUser)[0]
      self.sourceName.text = source.firstName + source.lastName
      self.sourcePhoto.kf.setImage(with: URL(string: source.photoURL))
    } else if pieceOfNews.sourceId < 0 {
      self.sourceGroup = try? Realm().objects(Group.self).filter("id = %@", -pieceOfNews.sourceId)
      guard let sourceGroup = self.sourceGroup else {return}
      let source = Array(sourceGroup)[0]
      self.sourceName.text = source.name
      self.sourcePhoto.kf.setImage(with: URL(string: source.photoURL))
    }
    self.postTime.text = self.getTimePassed(from: pieceOfNews.postDate)
   

  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    sourceName.text = nil
    sourcePhoto.image = nil
    postTime.text = nil
    
  }
  
  func getTimePassed(from time: Double) -> String {
    let date = Date(timeIntervalSince1970: time)
    let timeInterval = Date().timeIntervalSince(date)
    let strDate: String
    if timeInterval >= 2592000 {
      strDate = "\(Int(round(timeInterval/2592000))) months ago"
    } else if timeInterval >= 86400 {
      strDate = "\(Int(round(timeInterval/86400))) days ago"
    } else if timeInterval >= 3600 {
      strDate = "\(Int(round(timeInterval/3600))) hours ago"
    } else if timeInterval >= 60 {
      strDate = "\(Int(round(timeInterval/60))) minutes ago"
    } else {
      strDate = "\(Int(round(timeInterval))) seconds ago"
    }
    return strDate
  }
  
}

extension NewsfeedPhotoCell: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return UICollectionViewCell()
  }
  
}
