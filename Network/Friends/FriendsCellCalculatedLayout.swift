//
//  FriendsCellCalculatedLayout.swift
//  Network
//
//  Created by Anastasia Romanova on 10/03/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

class FriendsCellCalculatedLayout: UITableViewCell {

  static let reuseId = "FriendsCellCalculatedLayout"
  
  //MARK: - Subviews
  private let friendPhotoView = PhotoView()
  private let friendName = UILabel()
  
  //MARK: - Privates
  private let leftOffset: CGFloat = 12
  private let verticalOffset: CGFloat = 8
  private let textOffset: CGFloat = 12
  private let spaceBetween: CGFloat = 18
  private let photoWidth: CGFloat = 50
  private let defaultFont = UIFont.systemFont(ofSize: 17)

  
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
    friendName.backgroundColor = .clear
    friendName.font = defaultFont
    friendName.numberOfLines = 0
    contentView.addSubview(friendName)
    contentView.addSubview(friendPhotoView)
  }
  
  public func configure(with user: User, by indexPath: IndexPath, service: PhotoService?) {
    friendPhotoView.containerView.image = service?.photo(atIndexpath: indexPath, byURL: user.photoURL)
    friendName.text = "\(user.firstName) \(user.lastName)"
  }
  
  //MARK: - Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    
    setFriendPhotoFrame()
    setFriendNameFrame()
  }
  
  
  
  private func setFriendPhotoFrame() {
    let photoSize = CGSize(width: photoWidth, height: photoWidth)
    let photoOrigin = CGPoint(x: self.contentView.bounds.minX + leftOffset,
                             y: (self.contentView.bounds.height - photoWidth)/2)
    friendPhotoView.frame = CGRect(origin: photoOrigin, size: photoSize)
  }
  
  private func setFriendNameFrame() {
    guard let friendText = friendName.text else { return }
    let friendNameSize = getLabelSize(text: friendText, font: friendName.font)
    let friendNameX = leftOffset + photoWidth + spaceBetween
    let friendNameY = friendPhotoView.frame.midY - friendName.frame.height/2
    let friendNameOrigin = CGPoint(x: friendNameX, y: friendNameY)
    
    friendName.frame = CGRect(origin: friendNameOrigin, size: friendNameSize)
  }
  
  //MARK: - Helpers
  private func getLabelSize(text: String, font: UIFont) -> CGSize {
    let maxWidth = contentView.bounds.width - 2 * textOffset
    let textblock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
    
    let rect = text.boundingRect(with: textblock,
                                 options: .usesLineFragmentOrigin,
                                 attributes: [NSAttributedString.Key.font : font],
                                 context: nil)
    
    let width = rect.size.width.rounded(.up)
    let height = rect.size.height.rounded(.up)
    
    return CGSize(width: width, height: height)
  }

}
