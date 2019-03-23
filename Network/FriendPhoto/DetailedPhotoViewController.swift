//
//  DetailedPhotoViewController.swift
//  Network
//
//  Created by Anastasia Romanova on 26/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import RealmSwift

class DetailedPhotoViewController: UIViewController {
  
  public var friendPhotos = [Photo]()
  public var photoToShowFirst: Photo?
  public var indexOfFirstPhoto = Int()
  private var leftSwipeRecognizer = UISwipeGestureRecognizer()
  private var rightSwipeRecognizer = UISwipeGestureRecognizer()
  public var indexOfCurrentPhoto = Int()
  private var vkService = VKService()
  
  @IBOutlet weak var imageView: PhotoView!
  @IBOutlet weak var likeControl: LikeControl!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.imageView.backgroundColor = .clear

        guard let photoToShow = photoToShowFirst else {return}
        imageView.containerView.kf.setImage(with: URL(string: photoToShow.photoURL))
        imageView.containerView.backgroundColor = .black
        imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.layoutSubviews()
        imageView.sizeChanged()
      
        likeControl.numberOfLikes = photoToShow.numberOfLikes
        likeControl.isLiked = photoToShow.isLiked
        likeControl.updateView()
        likeControl.likeButton.addTarget(self, action: #selector(likeButtonPressed(_:)), for: .touchUpInside)
      
        leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe(_:)))
        leftSwipeRecognizer.direction = .left
        imageView.addGestureRecognizer(leftSwipeRecognizer)
        rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe(_:)))
        rightSwipeRecognizer.direction = .right
        imageView.addGestureRecognizer(rightSwipeRecognizer)
        indexOfCurrentPhoto = indexOfFirstPhoto
    }
  
  @objc func likeButtonPressed(_ sender: UIButton) {
    let currentPhoto = friendPhotos[indexOfCurrentPhoto]
    if currentPhoto.isLiked {
      vkService.likeDislike(toLike: false, ownerId: currentPhoto.userId, itemId: currentPhoto.id) { [weak self] response, error in
        if let error = error {
          self?.showAlert(error: error)
          return
        }
        guard let numberOfLikes = response, let self = self else {return}
        self.likeControl.numberOfLikes = numberOfLikes
        DispatchQueue.main.async {
          self.likeControl.updateLikes()
          do {
            let realm = try Realm()
            try realm.write {
              currentPhoto.isLiked = false
              currentPhoto.numberOfLikes = numberOfLikes
            }
          } catch {
            self.showAlert(error: error)
          }
        }
      }
    } else if !currentPhoto.isLiked {
      vkService.likeDislike(toLike: true, ownerId: currentPhoto.userId, itemId: currentPhoto.id) { [weak self] response, error in
        if let error = error {
          self?.showAlert(error: error)
          return
        }
        guard let numberOfLikes = response, let self = self else {return}
        self.likeControl.numberOfLikes = numberOfLikes
        DispatchQueue.main.async {
          self.likeControl.updateLikes()
          do {
            let realm = try Realm()
            try realm.write {
              currentPhoto.isLiked = true
              currentPhoto.numberOfLikes = numberOfLikes
            }
          } catch {
            self.showAlert(error: error)
          }
        }
      }
    }
  }
  
  
  @objc func onSwipe(_ swipeGestureRecognizer: UISwipeGestureRecognizer) {
    let screenSize: CGRect = self.view.bounds
    let screenWidth = screenSize.width
    let currentImageView = swipeGestureRecognizer.view as! PhotoView
    currentImageView.translatesAutoresizingMaskIntoConstraints = false
    let nextImageView = PhotoView(frame: currentImageView.frame)
    nextImageView.containerView.backgroundColor = .black
    nextImageView.center = currentImageView.center
    switch swipeGestureRecognizer {
    case leftSwipeRecognizer:
      guard indexOfCurrentPhoto != friendPhotos.count - 1 else {return}
      let nextPhoto = self.friendPhotos[self.indexOfCurrentPhoto + 1]
      nextImageView.containerView.kf.setImage(with: URL(string: nextPhoto.photoURL))
      nextImageView.transform = CGAffineTransform(translationX: screenWidth, y: 0)
      self.view.addSubview(nextImageView)
      likeControl.isHidden = true
      UIView.animate(withDuration: 1, animations: {
        currentImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      }) { _ in
        UIView.animate(withDuration: 1, animations: {
          nextImageView.transform = .identity
        }, completion: { _ in
          currentImageView.containerView.image = nextImageView.containerView.image
          currentImageView.transform = .identity
          currentImageView.center = nextImageView.center
          currentImageView.sizeChanged()
          nextImageView.removeFromSuperview()
          self.likeControl.numberOfLikes = nextPhoto.numberOfLikes
          self.likeControl.isLiked = nextPhoto.isLiked
          self.likeControl.updateView()
          self.likeControl.isHidden = false
        })
      }
      indexOfCurrentPhoto += 1
    case rightSwipeRecognizer:
      guard indexOfCurrentPhoto != 0 else {return}
      let nextPhoto = self.friendPhotos[self.indexOfCurrentPhoto - 1]
      nextImageView.containerView.kf.setImage(with: URL(string: nextPhoto.photoURL))
      nextImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
      self.view.addSubview(nextImageView)
      self.view.bringSubviewToFront(currentImageView)
      likeControl.isHidden = true
      UIView.animate(withDuration: 1, animations: {
        currentImageView.transform = CGAffineTransform(translationX: screenWidth, y: 0)
      }) { _ in
        UIView.animate(withDuration: 1, animations: {
          nextImageView.transform = .identity
        }, completion: { _ in
          currentImageView.containerView.image = nextImageView.containerView.image
          currentImageView.transform = .identity
          currentImageView.center = nextImageView.center
          nextImageView.removeFromSuperview()
          self.likeControl.numberOfLikes = nextPhoto.numberOfLikes
          self.likeControl.isLiked = nextPhoto.isLiked
          self.likeControl.updateView()
          self.likeControl.isHidden = false
        })
      }
      indexOfCurrentPhoto -= 1
    default: return
    }
  }
}
