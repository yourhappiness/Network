//
//  UnwindAnimatedPhotoSegue.swift
//  Network
//
//  Created by Anastasia Romanova on 04/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class UnwindAnimatedPhotoSegue: UIStoryboardSegue {
  
  override func perform() {
    let fromVC = source as! DetailedPhotoViewController
    let toVC = destination as! FriendPhotoViewController
    let indexPath = fromVC.indexOfCurrentPhoto
    var cellFrame: CGRect
    if indexPath <= toVC.cellsFrames.count - 1 {
      cellFrame = toVC.cellsFrames[indexPath]
    } else {
      cellFrame = toVC.cellsFrames[toVC.cellsFrames.count - 1]
    }
    guard let containerView = toVC.collectionView else {return}
    fromVC.view.addSubview(containerView)
    let screenSize: CGRect = containerView.bounds
    let screenWidth = screenSize.width
    let screenHeight = screenSize.height
    let topEdge = toVC.collectionView.contentOffset.y
    let imageView = PhotoView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
    imageView.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2 + topEdge)
    let imageViewTargetFrame = CGRect(x: cellFrame.minX + 10, y: cellFrame.minY + 10, width: cellFrame.width - 20, height: cellFrame.height - 20)
    imageView.containerView.kf.setImage(with: URL(string: fromVC.friendPhotos[indexPath].photoURL))
    imageView.containerView.backgroundColor = .black
    containerView.addSubview(imageView)
    let shadowAnimation = CABasicAnimation(keyPath: "shadowPath")
    shadowAnimation.duration = 0.6
    shadowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    shadowAnimation.fromValue = imageView.shadowView.layer.shadowPath
    UIView.animate(withDuration: 0.6,
                   delay: 0,
                   options: .curveEaseInOut,
                   animations: {
                    imageView.frame = imageViewTargetFrame
                    imageView.shadowView.frame = imageView.bounds
                    shadowAnimation.toValue = UIBezierPath(ovalIn: imageView.shadowView.bounds).cgPath
                    imageView.shadowView.layer.add(shadowAnimation, forKey: "shadowPath")
                    imageView.shadowView.layer.shadowPath = UIBezierPath(ovalIn: imageView.shadowView.bounds).cgPath
                    imageView.setup()
              }) { finished in
                self.destination.navigationItem.hidesBackButton = false
                self.destination.tabBarController?.tabBar.isHidden = false
                self.source.dismiss(animated: false, completion: nil)
                imageView.removeFromSuperview()
                self.destination.definesPresentationContext = false
              }
  }
}
