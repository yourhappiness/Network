//
//  AnimatedPhotoSegue.swift
//  Network
//
//  Created by Anastasia Romanova on 03/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class AnimatedPhotoSegue: UIStoryboardSegue {
  
  override func perform() {
    let fromVC = source as! FriendPhotoViewController
    let toVC = destination as! DetailedPhotoViewController
    let indexPath = toVC.indexOfFirstPhoto
    let containerView = UIView(frame: CGRect(origin: .zero, size: fromVC.collectionView.contentSize))
    fromVC.collectionView.addSubview(containerView)
    let topEdge = fromVC.collectionView.contentOffset.y
    guard let screenSize: CGSize = fromVC.collectionView?.visibleSize else {return}
    let screenWidth = screenSize.width
    let screenHeight = screenSize.height
    let cell = fromVC.collectionView.cellForItem(at: IndexPath(row: indexPath, section: 0)) as! FriendPhotoCell
    let imageView = PhotoView(frame: CGRect(x: cell.frame.minX + 10, y: cell.frame.minY + 10, width: cell.frame.width - 20, height: cell.frame.height - 20))
    guard let photoToShowFirst = toVC.photoToShowFirst else {return}
    imageView.containerView.kf.setImage(with: URL(string: photoToShowFirst.photoURL))
    imageView.containerView.backgroundColor = .black
    let imageViewTargetFrame = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth)
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
                    imageView.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2 + topEdge)
                    imageView.shadowView.frame = imageView.bounds
                    shadowAnimation.toValue = UIBezierPath(ovalIn: imageView.shadowView.bounds).cgPath
                    imageView.shadowView.layer.add(shadowAnimation, forKey: "shadowPath")
                    imageView.shadowView.layer.shadowPath = UIBezierPath(ovalIn: imageView.shadowView.bounds).cgPath
                    imageView.setup()
                    containerView.backgroundColor = .clear
              }) { finished in
                self.source.definesPresentationContext = true
                self.source.navigationItem.hidesBackButton = true
                self.source.tabBarController?.tabBar.isHidden = true
                self.source.present(self.destination, animated: false, completion: nil)
                containerView.removeFromSuperview()
              }
  }
}
