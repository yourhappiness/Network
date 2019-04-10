//
//  NewsPhotosTableViewCell.swift
//  Network
//
//  Created by Anastasia Romanova on 29/03/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

class NewsPhotosTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  static let reuseId = "NewsPhotosTableViewCell"
  static let xOffsetForPostPhotos: CGFloat = 10
  static let yOffsetFromCellEdge: CGFloat = 15
  
  //MARK: - Subviews
  private var postPhotosCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  
  //MARK: - Privates
  private var photoUrls: [URL]?
  private var photos: [Photo]?
  private let yOffsetFromCellEdge: CGFloat = NewsPhotosTableViewCell.yOffsetFromCellEdge
  private let xOffsetForPostPhotos: CGFloat = NewsPhotosTableViewCell.xOffsetForPostPhotos
  private var photoHeight: CGFloat = 0
  private var screenWidth: CGFloat = 0
  private var cellHeights: [IndexPath : CGFloat] = [:]
  
  override func awakeFromNib() {
      super.awakeFromNib()
      setupViews()
  }
  
  //MARK: - Inits
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }

  private func setupViews() {
    let collectionViewVerticalLayout = UICollectionViewFlowLayout()
    collectionViewVerticalLayout.scrollDirection = .horizontal
    collectionViewVerticalLayout.minimumInteritemSpacing = 1
    collectionViewVerticalLayout.minimumLineSpacing = 1
    postPhotosCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewVerticalLayout)
    self.contentView.addSubview(postPhotosCollectionView)
    self.postPhotosCollectionView.delegate = self
    self.postPhotosCollectionView.dataSource = self
    self.postPhotosCollectionView.isScrollEnabled = false
    self.postPhotosCollectionView.register(PostPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PostPhotoCell")
  }
  
  func configure(using urls: [URL]?, with photos: [Photo], for screenWidth: CGFloat, photoHeight: CGFloat) {
    self.screenWidth = screenWidth
    self.photoUrls = urls
    self.photoHeight = photoHeight
    self.photos = photos
    
    self.layoutIfNeeded()
  }
  
  //MARK: - Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.setPostPhotosCollectionViewFrame()
  }
    
  
  private func setPostPhotosCollectionViewFrame() {
    let postPhotosOriginPoint = CGPoint(x: xOffsetForPostPhotos, y: yOffsetFromCellEdge)
    let postPhotoSize = CGSize(width: screenWidth - xOffsetForPostPhotos * 2, height: self.photoHeight)
    self.postPhotosCollectionView.frame =  CGRect(origin: postPhotosOriginPoint, size: postPhotoSize)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.photoUrls = nil
    self.postPhotosCollectionView.reloadData()
  }
  
  //MARK: - CollectionView
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let numberOfPhotos = photoUrls?.count else {return 0}
    if numberOfPhotos > 5 {
      return 5
    } else {
      return numberOfPhotos
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostPhotoCell", for: indexPath) as! PostPhotoCollectionViewCell
    guard let photoUrls = self.photoUrls, let photos = self.photos else {return UICollectionViewCell()}
    cell.configure(with: photoUrls[indexPath.item], photoWidth: CGFloat(photos[indexPath.item].width), photoHeight: CGFloat(photos[indexPath.item].height), for: cellHeights[indexPath] ?? 0)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //substract spacing between items and lines
    let collectionHeight = self.photoHeight - 2
    let collectionWidth = self.screenWidth - xOffsetForPostPhotos * 2
    
    //arrays of heights based on image count
    let arrayHeightOf5: [CGFloat] = [collectionHeight/2, collectionHeight/2, collectionHeight/3, collectionHeight/3, collectionHeight/3]
    let arrayHeightOf4: [CGFloat] = [collectionHeight/2, collectionHeight/2, collectionHeight/2, collectionHeight/2]
    let arrayHeightOf3: [CGFloat] = [collectionHeight, collectionHeight/2, collectionHeight/2]
    
    var cellHeight: CGFloat
    var index = indexPath.item
    guard let numberOfPhotos = photoUrls?.count else {return CGSize.zero}
    if numberOfPhotos >= 5 {
      if index > 4 {
        index = 4
      }
      cellHeight = arrayHeightOf5[index].rounded(.down)
      cellHeights[indexPath] = cellHeight
      return CGSize(width: collectionWidth/2, height: cellHeight)
    }
    switch numberOfPhotos {
    case 2:
      cellHeights[indexPath] = collectionHeight
      return CGSize(width: collectionWidth/2, height: collectionHeight)
    case 3:
      cellHeight = arrayHeightOf3[index]
      cellHeights[indexPath] = cellHeight
      return CGSize(width: collectionWidth/2, height: cellHeight)
    case 4:
      cellHeight = arrayHeightOf4[index]
      cellHeights[indexPath] = cellHeight
      return CGSize(width: collectionWidth/2, height: cellHeight)
    default:
      cellHeights[indexPath] = collectionHeight
      return CGSize(width: collectionWidth, height: collectionHeight)
    }
  }
  
}
