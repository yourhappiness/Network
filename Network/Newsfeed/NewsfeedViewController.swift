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

class NewsfeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
  
//    var tapGestureRecognizer = UITapGestureRecognizer()
//    var longPressRecognizer = UILongPressGestureRecognizer()
  
    private let vkService = VKService()
    private var postNews: [NewsfeedCompatible]?
    private var imageUrls: [[URL]?]? = []
    private var newIndexes: [IndexPath] = []
    private var newsIsLoading = false
    //array for cells heights
    private var cellHeights: [IndexPath : CGFloat] = [:]
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(NewsfeedCellCalculatedLayout.self, forCellReuseIdentifier: NewsfeedCellCalculatedLayout.reuseId)
//        self.tableView.prefetchDataSource = self
      //запрос новостей
      vkService.getNews() { [weak self] (news: [NewsfeedCompatible]?, users: [User]?, groups: [Group]?, error: Error?) in
        if let error = error {
          self?.showAlert(error: error)
          return
        }
        guard let news = news, let users = users, let groups = groups, let self = self else {return}
        self.postNews = news
        let imageUrlStrings: [[String]?]? = self.postNews?.map{$0.photos?.map{$0.photoURL}}
        self.imageUrls = self.getUrlsFromStrings(strings: imageUrlStrings)
        self.startDownload(for: self.imageUrls)
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

  
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let news = postNews, let urls = self.imageUrls else {return UITableViewCell()}
//        if let element = news[indexPath.row] as? NewsfeedPost {
//          let cell = tableView.dequeueReusableCell(withIdentifier: "NewsfeedPostCell", for: indexPath) as! NewsfeedPostCell
//          cell.configure(with: element, using: urls[indexPath.row])
//          return cell
//        } else if let element = news[indexPath.row] as? NewsfeedPhoto {
//          let cell = tableView.dequeueReusableCell(withIdentifier: "NewsfeedPhotoCell", for: indexPath) as! NewsfeedPhotoCell
//          cell.configure(with: element, using: urls[indexPath.row])
//          return cell
//        } else {
//          return UITableViewCell()
//        }
//        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(animatePhotoWithTap(_:)))
//        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(animatePhotoWithPress(_:)))
//        cell.newsPhoto.addGestureRecognizer(tapGestureRecognizer)
//        cell.newsPhoto.addGestureRecognizer(longPressRecognizer)
//    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let news = postNews, let urls = self.imageUrls else {return UITableViewCell()}
      let cell = tableView.dequeueReusableCell(withIdentifier: NewsfeedCellCalculatedLayout.reuseId, for: indexPath) as! NewsfeedCellCalculatedLayout
      let postTime: String = getTimePassed(from: news[indexPath.row].postDate)
      cell.configure(with: news[indexPath.row], postTime: postTime, using: urls[indexPath.row], for: self.view.frame.width)
      cell.backgroundColor = tableView.backgroundColor
      if cellHeights[indexPath] == nil {
        cellHeights[indexPath] = cell.cellHeight
      }
      self.tableView.rowHeight = cellHeights[indexPath] ?? UITableView.automaticDimension
      return cell
    }
  
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
      //TODO
    }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: false)
    }
  
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
      guard scrollView.isDragging else {return}
      let currentOffset = scrollView.contentOffset.y
      let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
      let deltaOffset = maximumOffset - currentOffset
      
      if deltaOffset <= 0 {
        loadMore()
      }
    }
  
    func loadMore() {
      guard !newsIsLoading else {return}
        newsIsLoading = true
        vkService.getNews() { [weak self] (news: [NewsfeedCompatible]?, users: [User]?, groups: [Group]?, error: Error?) in
          if let error = error {
            self?.showAlert(error: error)
            return
          }
          guard let news = news, let users = users, let groups = groups, let self = self, let postNews = self.postNews, let imageUrls = self.imageUrls else {return}
          var i: Int = 0
          DispatchQueue.global().sync {
            news.forEach {_ in
              self.newIndexes.append(IndexPath(row: postNews.count + i, section: 0))
              i += 1
            }
          }
          self.postNews = postNews + news
          let newImageUrlStrings = news.map{$0.photos?.map{$0.photoURL}}
          let newImageUrls = self.getUrlsFromStrings(strings: newImageUrlStrings)
          self.startDownload(for: newImageUrls)
          self.imageUrls = imageUrls + newImageUrls
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
            self.tableView.insertRows(at: self.newIndexes, with: .automatic)
            self.tableView.scrollToRow(at: IndexPath(row: postNews.count - 1, section: 0), at: .bottom, animated: false)
            self.newsIsLoading = false
            self.newIndexes.removeAll()
          }
        }
      }
  
    private func getTimePassed(from time: Double) -> String {
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

  private func getUrlsFromStrings(strings: [[String]?]?) -> [[URL]?] {
    var urls: [[URL]?] = []
    strings?.forEach{
      let url = $0?.map{URL(string: $0)!}
      urls.append(url)
    }
    return urls
  }
  
  private func startDownload(for array: [[URL]?]?) {
    guard let array = array else {return}
    array.forEach{
      guard let url = $0 else {return}
      let prefetcher = ImagePrefetcher(urls: url)
      prefetcher.start()
    }
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

