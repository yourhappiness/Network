//
//  FriendPhotoViewController.swift
//  Network
//
//  Created by Anastasia Romanova on 10/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import RealmSwift

class FriendPhotoViewController: UICollectionViewController {
  
  public var cellsFrames = [CGRect]()
  private let vkService = VKService()
  private var notificationToken: NotificationToken?
  private lazy var userPhotos: Results<Photo>? = DatabaseService.loadVKData(type: Photo.self, userId: self.user.id)
  public var user = User()
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      notificationToken = userPhotos?.observe { [weak self] changes in
        guard let self = self else {return}
        switch changes {
        case .initial:
          self.collectionView.reloadData()
        case .update(_, let deletions, let insertions, let modifications):
          guard deletions.count != 0 else {
            self.collectionView.reloadData()
            return
          }
          self.collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: insertions.map({IndexPath(row: $0, section: 0)}))
            self.collectionView.deleteItems(at: deletions.map({IndexPath(row: $0, section: 0)}))
            self.collectionView.reloadItems(at: modifications.map({IndexPath(row: $0, section: 0)}))
          }, completion: nil)
        case .error(let error):
          self.showAlert(error: error)
        }
      }
    }

  override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(true)
    
      //получение фото
      vkService.get(userId: user.id) { [weak self] (userPhotos: [Photo]?, error: Error?) in
        if let error = error {
          self?.showAlert(error: error)
          return
        }
        
        guard let userPhotos = userPhotos, let self = self else {return}
        
        do {
          guard let realm = try? Realm() else {return}
          try realm.write {
            realm.add(userPhotos.sorted(by: {$0.date > $1.date}), update: true)
          }
        } catch {
          self.showAlert(error: error)
        }
      }
    
    }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    self.notificationToken?.invalidate()
  }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return userPhotos?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendPhotoCell", for: indexPath) as! FriendPhotoCell
      guard let userPhotos = self.userPhotos else {return UICollectionViewCell()}
        cell.configure(with: userPhotos[indexPath.row])
        cellsFrames.append(cell.frame)
        return cell
    }
  
  // MARK: - Navigation
 
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "seeDetailedPhotos" else {return}
    // Get the new view controller using segue.destination.
    guard let detailedPhotoViewController = segue.destination as? DetailedPhotoViewController else {return}
    var selectedPhoto: Photo?
    // Pass the selected object to the new view controller.
    guard let indexPath = collectionView.indexPathsForSelectedItems, let userPhotos = self.userPhotos else {return}
    selectedPhoto = userPhotos[indexPath[0].row]
    detailedPhotoViewController.friendPhotos = Array(userPhotos)
    detailedPhotoViewController.photoToShowFirst = selectedPhoto
    detailedPhotoViewController.indexOfFirstPhoto = indexPath[0].row
  }
  
 
  @IBAction func seeAllPhotos(segue: UnwindAnimatedPhotoSegue) {
    }

}
