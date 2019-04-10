//
//  NewsTextTableViewCell.swift
//  Network
//
//  Created by Anastasia Romanova on 29/03/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

class NewsTextTableViewCell: UITableViewCell {

  static let reuseId = "NewsTextTableViewCell"
  static let yOffsetFromCellEdge: CGFloat = 15
  static let xOffsetFromCellEdge: CGFloat = 12
  
  //MARK: - Subviews
  private var postTextView = UITextView()
  
  //MARK: - Privates
  private let xOffsetFromCellEdge: CGFloat = NewsTextTableViewCell.xOffsetFromCellEdge
  private let yOffsetFromCellEdge: CGFloat = NewsTextTableViewCell.yOffsetFromCellEdge
  private var textHeight: CGFloat = 0
  private var screenWidth: CGFloat = 0
  
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
    postTextView.font = UIFont.systemFont(ofSize: 12)
    postTextView.isScrollEnabled = false
    postTextView.isEditable = false
    postTextView.textAlignment = .justified
    postTextView.dataDetectorTypes = .all
    self.contentView.addSubview(postTextView)
  }
  
  func configure(with attributedString: NSAttributedString, for screenWidth: CGFloat, textHeight: CGFloat) {
    self.screenWidth = screenWidth
    self.textHeight = textHeight
    postTextView.attributedText = attributedString
  
    self.layoutIfNeeded()
  }
  
  //MARK: - Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    
    postTextView.backgroundColor = self.backgroundColor
    setPostTextFrame()
  }
  
  private func setPostTextFrame() {
    let postTextSize = CGSize(width: screenWidth - xOffsetFromCellEdge * 2, height: textHeight)
    if textHeight == 100 {
      postTextView.isScrollEnabled = true
    }
    let postTextX = xOffsetFromCellEdge
    let postTextY = yOffsetFromCellEdge
    let postTextOrigin = CGPoint(x: postTextX, y: postTextY)
    
    postTextView.frame = CGRect(origin: postTextOrigin, size: postTextSize)
  }
  
  override func prepareForReuse() {
    postTextView.text = nil
  }
  
}
