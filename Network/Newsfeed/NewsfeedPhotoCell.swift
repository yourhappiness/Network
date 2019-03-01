//
//  NewsfeedPhotoCell.swift
//  Network
//
//  Created by Anastasia Romanova on 24/02/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit
import RealmSwift

class NewsfeedPhotoCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var sourcePhoto: UIImageView!
  @IBOutlet weak var sourceName: UILabel!
  @IBOutlet weak var postTime: UILabel!
  @IBOutlet weak var photoCollectionView: UICollectionView!
  
  var sourceUser: Results<User>?
  var sourceGroup: Results<Group>?
  var photos: [Photo]?
  
  //MARK: - CollectionView
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let numberOfPhotos = photos?.count else {return 0}
    if numberOfPhotos > 5 {
      return 5
    } else {
      return numberOfPhotos
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostPhotoCell", for: indexPath) as! PostPhotoCollectionViewCell
    guard let photos = self.photos else {return UICollectionViewCell()}
    cell.configure(with: photos[indexPath.item])
    return cell
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let collectionHeight = self.photoCollectionView.frame.height
    let collectionWidth = self.photoCollectionView.frame.width

    //arrays of heights based on image count
    let arrayHeightOf5: [CGFloat] = [collectionHeight/2, collectionHeight/2, collectionHeight/3, collectionHeight/3, collectionHeight/3]
    let arrayHeightOf4: [CGFloat] = [collectionHeight, collectionHeight/3, collectionHeight/3, collectionHeight/3]
    let arrayHeightOf3: [CGFloat] = [collectionHeight, collectionHeight/2, collectionHeight/2]

    var cellHeight: CGFloat
    var index = indexPath.item
    guard let numberOfPhotos = photos?.count else {return CGSize.zero}
    if numberOfPhotos >= 5 {
      if index > 4 {
        index = 4
      }
      cellHeight = arrayHeightOf5[index]
      return CGSize(width: collectionWidth/2, height: cellHeight)
    }
    switch numberOfPhotos {
    case 2:
      return CGSize(width: collectionWidth/2, height: collectionHeight)
    case 3:
      cellHeight = arrayHeightOf3[index]
      return CGSize(width: collectionWidth/2, height: cellHeight)
    case 4:
      cellHeight = arrayHeightOf4[index]
      return CGSize(width: collectionWidth/2, height: cellHeight)
    default:
      return CGSize(width: collectionWidth, height: collectionHeight)
    }
  }

  
  
  
  //MARK: - Cell configuration
  override func awakeFromNib() {
    self.photoCollectionView.delegate = self
    self.photoCollectionView.dataSource = self
    self.photoCollectionView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
  }
  
  func configure(with pieceOfNews: NewsfeedPhoto) {
    if pieceOfNews.sourceId > 0 {
      self.sourceUser = try? Realm().objects(User.self).filter("id = %@", pieceOfNews.sourceId)
      guard let sourceUser = self.sourceUser else {return}
      let source = Array(sourceUser)[0]
      self.sourceName.text = source.firstName + " " + source.lastName
      self.sourcePhoto.kf.setImage(with: URL(string: source.photoURL))
    } else if pieceOfNews.sourceId < 0 {
      self.sourceGroup = try? Realm().objects(Group.self).filter("id = %@", -pieceOfNews.sourceId)
      guard let sourceGroup = self.sourceGroup else {return}
      let source = Array(sourceGroup)[0]
      self.sourceName.text = source.name
      self.sourcePhoto.kf.setImage(with: URL(string: source.photoURL))
    }
    self.postTime.text = self.getTimePassed(from: pieceOfNews.postDate)
    self.photos = pieceOfNews.photos
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    sourceName.text = nil
    sourcePhoto.image = nil
    postTime.text = nil
    photos = nil
    photoCollectionView.reloadData()
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
