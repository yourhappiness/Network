//
//  NewsfeedViewController.swift
//  Network
//
//  Created by Anastasia Romanova on 21/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class NewsfeedViewController: UITableViewController {
  
//    var tapGestureRecognizer = UITapGestureRecognizer()
//    var longPressRecognizer = UILongPressGestureRecognizer()
  
    private let vkService = VKService()
    private var postNews: [NewsfeedCompatible]?
    private var imageUrlStrings: [[String]?]?
    private var imageUrls: [[URL]?]? = []
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      //запрос новостей
      vkService.getNews() { [weak self] (news: [NewsfeedCompatible]?, users: [User]?, groups: [Group]?, error: Error?) in
        if let error = error {
          self?.showAlert(error: error)
          return
        }
        guard let news = news, let users = users, let groups = groups, let self = self else {return}
        self.postNews = news
        self.imageUrlStrings = self.postNews?.map{$0.photos?.map{$0.photoURL}}
        self.imageUrlStrings?.forEach{
          let imageUrl = $0?.map{URL(string: $0)!}
          self.imageUrls?.append(imageUrl)
        }
        self.imageUrls?.forEach{
          guard let url = $0 else {return}
          let prefetcher = ImagePrefetcher(urls: url)
          prefetcher.start()
        }
        DispatchQueue.main.async {
          do {
            let realm = try Realm()
            try realm.write {
              realm.add(users, update: true)
              realm.add(groups, update: true)
            }
          } catch {
            self.showAlert(error: error)
          }
          self.tableView.reloadData()
        }
      }
      
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postNews?.count ?? 0
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let news = postNews, let urls = self.imageUrls else {return UITableViewCell()}
        if let element = news[indexPath.row] as? NewsfeedPost {
          let cell = tableView.dequeueReusableCell(withIdentifier: "NewsfeedPostCell", for: indexPath) as! NewsfeedPostCell
          cell.configure(with: element, using: urls[indexPath.row]) { [weak self] in
            guard let self = self else { return }
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
          }
          return cell
        } else if let element = news[indexPath.row] as? NewsfeedPhoto {
          let cell = tableView.dequeueReusableCell(withIdentifier: "NewsfeedPhotoCell", for: indexPath) as! NewsfeedPhotoCell
          cell.configure(with: element, using: urls[indexPath.row])
          return cell
        } else {
          return UITableViewCell()
        }
//        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(animatePhotoWithTap(_:)))
//        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(animatePhotoWithPress(_:)))
//        cell.newsPhoto.addGestureRecognizer(tapGestureRecognizer)
//        cell.newsPhoto.addGestureRecognizer(longPressRecognizer)
    }
  
  @objc func animatePhotoWithTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
    guard let view = tapGestureRecognizer.view else {return}
    switch tapGestureRecognizer.state {
    case .ended:
      let animationIn = CABasicAnimation(keyPath: "transform.scale")
      animationIn.fromValue = 1
      animationIn.toValue = 0.8
      animationIn.duration = 0.2
      animationIn.beginTime = CACurrentMediaTime()
      view.layer.add(animationIn, forKey: nil)
      animationOut(view: view)
    default: return
    }
  }
  
  @objc func animatePhotoWithPress(_ longPressRecognizer: UILongPressGestureRecognizer) {
    guard let view = longPressRecognizer.view else {return}
    let animationIn = CABasicAnimation(keyPath: "transform.scale")
    switch longPressRecognizer.state {
    case .began:
      animationIn.fromValue = 1
      animationIn.toValue = 0.8
      animationIn.duration = 0.2
      animationIn.beginTime = CACurrentMediaTime()
      view.layer.add(animationIn, forKey: nil)
      let scale = CATransform3DScale(CATransform3DIdentity, 0.8, 0.8, 0)
      view.transform = CATransform3DGetAffineTransform(scale)
    case .ended:
      animationOut(view: view)
      view.transform = .identity
    default: return
    }
  }
  
  private func animationOut(view: UIView) {
    let animationOut = CASpringAnimation(keyPath: "transform.scale")
    animationOut.fromValue = 0.8
    animationOut.toValue = 1
    animationOut.duration = 2
    animationOut.stiffness = 200
    animationOut.mass = 1.5
    animationOut.damping = 9
    animationOut.beginTime = CACurrentMediaTime()
    view.layer.add(animationOut, forKey: nil)
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

