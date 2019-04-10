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

enum CellType {
  case Header
  case Text
  case Photo
  case Footer
}

class NewsfeedViewController: UITableViewController, UITableViewDataSourcePrefetching {

    private let vkService = VKService()
    private var postNews: [NewsfeedCompatible]?
    private var screenWidth: CGFloat = 0
    //for newsfeed update
    private var nextFrom: String?
    private var imageUrls: [[URL]?]? = []
    private var newSections = IndexSet()
    private var newsIsLoading = false
    private var numberOfRows: [Int : Int] = [:]
    private var cellTypesForIndexPathes: [IndexPath : CellType] = [:]
    private var sourceNameTexts: [IndexPath : String] = [:]
    private var postTimeTexts: [IndexPath : String] = [:]
    private var sourceNameSizes: [IndexPath : CGSize] = [:]
    private var postTimeSizes: [IndexPath : CGSize] = [:]
    private var postTextAttributedStrings: [IndexPath : NSAttributedString] = [:]
    private var commentsLabelSizes: [IndexPath : CGSize] = [:]
    private var sharesLabelSizes: [IndexPath : CGSize] = [:]
    //array for cells heights
    private var cellHeights: [IndexPath : CGFloat] = [:]
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewSetup()
        self.screenWidth = self.view.frame.width
      //запрос новостей
      vkService.getNews() { [weak self] (news: [NewsfeedCompatible]?, error: Error?, nextFrom: String?) in
        if let error = error {
          self?.showAlert(error: error)
          return
        }
        guard let news = news, let nextFrom = nextFrom, let self = self else {return}
        self.postNews = news
        self.nextFrom = nextFrom
        let imageUrlStrings: [[String]?]? = self.postNews?.map{$0.photos?.map{$0.photoURL}}
        self.imageUrls = self.getUrlsFromStrings(strings: imageUrlStrings)
        self.startDownload(for: self.imageUrls)
        guard let postNews = self.postNews else {return}
        self.getNumberAndTypeOfRows(for: postNews, with: 0)
        DispatchQueue.main.async {
          self.getCellHeights(for: postNews, with: 0)
          self.tableView.reloadData()
        }
      }
      
    }

  private func tableViewSetup() {
    self.tableView.register(NewsHeaderTableViewCell.self, forCellReuseIdentifier: NewsHeaderTableViewCell.reuseId)
    self.tableView.register(NewsTextTableViewCell.self, forCellReuseIdentifier: NewsTextTableViewCell.reuseId)
    self.tableView.register(NewsPhotosTableViewCell.self, forCellReuseIdentifier: NewsPhotosTableViewCell.reuseId)
    self.tableView.register(NewsFooterTableViewCell.self, forCellReuseIdentifier: NewsFooterTableViewCell.reuseId)
    self.tableView.prefetchDataSource = self
    self.tableView.allowsSelection = false
    self.tableView.separatorStyle = .none
    self.tableView.sectionFooterHeight = 2
  }
  
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.postNews?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return numberOfRows[section] ?? 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return cellHeights[indexPath] ?? UITableView.automaticDimension
    }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footerSize = CGSize(width: screenWidth, height: 2)
    let footerView = UITableViewHeaderFooterView(frame: CGRect(origin: .zero, size: footerSize))
    footerView.backgroundView?.backgroundColor = .white
    return footerView
  }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      guard let news = postNews,
            let urls = self.imageUrls,
            let cellHeight = cellHeights[indexPath],
            let cellType = cellTypesForIndexPathes[indexPath]
        else {return UITableViewCell()}
      
      let pieceOfNews = news[indexPath.section]
      
      switch cellType {
      case .Header:
        guard
            let sourceNameText = sourceNameTexts[indexPath],
            let sourceNameSize = sourceNameSizes[indexPath],
            let postTimeText = postTimeTexts[indexPath],
            let postTimeSize = postTimeSizes[indexPath]
          else {return UITableViewCell()}
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsHeaderTableViewCell.reuseId, for: indexPath) as! NewsHeaderTableViewCell
        cell.configure(with: pieceOfNews, sourceName: sourceNameText, postTime: postTimeText, sourceNameSize: sourceNameSize, postTimeSize: postTimeSize)
        cell.backgroundColor = tableView.backgroundColor
        
        return cell
        
      case .Text:
        guard let attrString = self.postTextAttributedStrings[indexPath] else {return UITableViewCell()}
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTextTableViewCell.reuseId, for: indexPath) as! NewsTextTableViewCell
        
        cell.configure(with: attrString, for: screenWidth, textHeight: cellHeight - NewsTextTableViewCell.yOffsetFromCellEdge)
        cell.backgroundColor = tableView.backgroundColor
        
        return cell
        
      case .Photo:
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsPhotosTableViewCell.reuseId, for: indexPath) as! NewsPhotosTableViewCell
        guard let photos = pieceOfNews.photos else {return UITableViewCell()}
        
        cell.configure(using: urls[indexPath.section], with: photos, for: screenWidth, photoHeight: cellHeight - NewsPhotosTableViewCell.yOffsetFromCellEdge)
        cell.backgroundColor = tableView.backgroundColor
        
        return cell
        
      case .Footer:
        guard
            let commentsLabelSize = self.commentsLabelSizes[indexPath],
            let sharesLabelSize = self.sharesLabelSizes[indexPath]
          else {return UITableViewCell()}
        let heightOfResponseView = cellHeight - NewsFooterTableViewCell.yOffsetFromCellEdge
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsFooterTableViewCell.reuseId, for: indexPath) as! NewsFooterTableViewCell
        
        cell.configure(with: pieceOfNews as! NewsfeedPost, for: screenWidth, commentsLabelSize: commentsLabelSize, sharesLabelSize: sharesLabelSize, heightOfNewsResponseView: heightOfResponseView)
        cell.backgroundColor = tableView.backgroundColor
        
        return cell
      }
    }
  
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
      let sections = Set(indexPaths.map { $0.section })
      guard let postNews = self.postNews else {return}
      if sections.contains(postNews.count - 1) {
        loadMore()
      }
    }
  
  //дозагрузка новостей
    func loadMore() {
      guard !newsIsLoading else {return}
        newsIsLoading = true
      vkService.getNews(nextFrom: self.nextFrom) { [weak self] (news: [NewsfeedCompatible]?, error: Error?, nextFrom: String?) in
          if let error = error {
            self?.showAlert(error: error)
            return
          }
          guard let news = news, let nextFrom = nextFrom, let self = self, let postNews = self.postNews, let imageUrls = self.imageUrls else {return}
          var i: Int = 0
          DispatchQueue.global().sync {
            news.forEach {_ in
              self.newSections.insert(postNews.count + i)
              i += 1
            }
          }
          self.postNews = postNews + news
          self.nextFrom = nextFrom
          let newImageUrlStrings = news.map{$0.photos?.map{$0.photoURL}}
          let newImageUrls = self.getUrlsFromStrings(strings: newImageUrlStrings)
          self.startDownload(for: newImageUrls)
          self.imageUrls = imageUrls + newImageUrls
          self.getNumberAndTypeOfRows(for: news, with: postNews.count)
          DispatchQueue.main.async {
            self.getCellHeights(for: news, with: postNews.count)
            self.tableView.insertSections(self.newSections, with: .none)
            self.newsIsLoading = false
            self.newSections.removeAll()
          }
        }
      }
  
  //MARK: - Helpers
    private func getTimePassed(from time: Double) -> String {
      let date = Date(timeIntervalSince1970: time)
      let timeInterval = Date().timeIntervalSince(date)
      let strDate: String
      if timeInterval >= 2592000 {
        if Int(round(timeInterval/2592000)) == 1 {
          strDate = "\(Int(round(timeInterval/2592000))) month ago"
        } else {
          strDate = "\(Int(round(timeInterval/2592000))) months ago"
        }
      } else if timeInterval >= 86400 {
        if Int(round(timeInterval/86400)) == 1 {
          strDate = "\(Int(round(timeInterval/86400))) day ago"
        } else {
          strDate = "\(Int(round(timeInterval/86400))) days ago"
        }
      } else if timeInterval >= 3600 {
        if Int(round(timeInterval/3600)) == 1 {
          strDate = "\(Int(round(timeInterval/3600))) hour ago"
        } else {
          strDate = "\(Int(round(timeInterval/3600))) hours ago"
        }
      } else if timeInterval >= 60 {
        if Int(round(timeInterval/60)) == 1 {
          strDate = "\(Int(round(timeInterval/60))) minute ago"
        } else {
          strDate = "\(Int(round(timeInterval/60))) minutes ago"
        }
      } else {
        strDate = "\(Int(round(timeInterval))) seconds ago"
      }
      return strDate
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
  
  func hasTextAndPhoto(item: NewsfeedPost) -> Bool {
    return item.postText != nil && item.photos != nil
  }
  
  func hasText(item: NewsfeedPost) -> Bool {
    return item.postText != nil
  }
  
  func hasPhoto(item: NewsfeedCompatible) -> Bool {
    return item.photos != nil
  }
  
  private func getNumberAndTypeOfRows(for newsArray: [NewsfeedCompatible], with startIndex: Int) {
    for (index, pieceOfNews) in newsArray.enumerated() {
      let section = index + startIndex
      if let element = pieceOfNews as? NewsfeedPost {
        
        if hasTextAndPhoto(item: element) {
          numberOfRows[section] = 4
          cellTypesForIndexPathes[IndexPath(row: 0, section: section)] = .Header
          cellTypesForIndexPathes[IndexPath(row: 1, section: section)] = .Text
          cellTypesForIndexPathes[IndexPath(row: 2, section: section)] = .Photo
          cellTypesForIndexPathes[IndexPath(row: 3, section: section)] = .Footer
          
        } else if hasText(item: element) {
          numberOfRows[section] = 3
          cellTypesForIndexPathes[IndexPath(row: 0, section: section)] = .Header
          cellTypesForIndexPathes[IndexPath(row: 1, section: section)] = .Text
          cellTypesForIndexPathes[IndexPath(row: 2, section: section)] = .Footer
          
        } else if hasPhoto(item: element) {
          numberOfRows[section] = 3
          cellTypesForIndexPathes[IndexPath(row: 0, section: section)] = .Header
          cellTypesForIndexPathes[IndexPath(row: 1, section: section)] = .Photo
          cellTypesForIndexPathes[IndexPath(row: 2, section: section)] = .Footer
          
        } else {
          numberOfRows[section] = 2
          cellTypesForIndexPathes[IndexPath(row: 0, section: section)] = .Header
          cellTypesForIndexPathes[IndexPath(row: 1, section: section)] = .Footer
        }
      } else if let element = pieceOfNews as? NewsfeedPhoto {
        
        if hasPhoto(item: element) {
          numberOfRows[section] = 2
          cellTypesForIndexPathes[IndexPath(row: 0, section: section)] = .Header
          cellTypesForIndexPathes[IndexPath(row: 1, section: section)] = .Photo
          
        } else {
          numberOfRows[section] = 1
          cellTypesForIndexPathes[IndexPath(row: 0, section: section)] = .Header
        }
      }
    }
  }
  
  
  
  private func getCellHeights(for newsArray: [NewsfeedCompatible], with startIndex: Int) {
    var section = startIndex
    repeat {
      guard let rows = numberOfRows[section] else {return}
      for row in 0..<rows {
        let indexPath = IndexPath(row: row, section: section)
        guard let cellType = cellTypesForIndexPathes[indexPath] else {return}
        switch cellType {
          
        case .Header:
          guard let pieceOfNews = self.postNews?[section] else {return}
          let sourceId = pieceOfNews.sourceId
          var sourceNameText: String = ""
          if sourceId > 0 {
            guard let sourceArray = try? Realm().objects(User.self).filter("id = %@", sourceId) else {return}
            let source = Array(sourceArray)[0]
            sourceNameText = source.firstName + " " + source.lastName
          } else if sourceId < 0 {
            guard let sourceArray = try? Realm().objects(Group.self).filter("id = %@", -sourceId) else {return}
            let source = Array(sourceArray)[0]
            sourceNameText = source.name
          }
          self.sourceNameTexts[indexPath] = sourceNameText
          
          let maxWidth = screenWidth - NewsHeaderTableViewCell.offsetForLabelMaxWidth
          
          let sourceNameSize = getLabelSize(text: sourceNameText, font: NewsHeaderTableViewCell.sourceNameLabelFont, maxWidth: maxWidth)
          self.sourceNameSizes[indexPath] = sourceNameSize
          
          let postTimeText: String = getTimePassed(from: pieceOfNews.postDate)
          self.postTimeTexts[indexPath] = postTimeText
          let postTimeSize = getLabelSize(text: postTimeText, font: NewsHeaderTableViewCell.postTimeLabelFont, maxWidth: maxWidth)
          self.postTimeSizes[indexPath] = postTimeSize
          
          cellHeights[indexPath] = NewsHeaderTableViewCell.yOffsetForSourceName + sourceNameSize.height + postTimeSize.height + NewsHeaderTableViewCell.sourceNameBottomOffset
          
        case .Text:
            let pieceOfNews = self.postNews?[section] as! NewsfeedPost
            guard let data = pieceOfNews.postText?.data(using: .unicode, allowLossyConversion: true) else { fatalError("Couldn't get text data") }
            if let attrStr = try? NSAttributedString(data: data,
                                                     options: [.documentType: NSAttributedString.DocumentType.html],
                                                     documentAttributes: nil) {
              var height = self.heightForString(attrStr)
              if height > 100 {
                height = 100
              }
              self.cellHeights[indexPath] = NewsTextTableViewCell.yOffsetFromCellEdge + height
              self.postTextAttributedStrings[indexPath] = attrStr
            }
          
        case .Photo:
          let pieceOfNews = self.postNews?[section]
          var postPhotosCollectionViewHeight: CGFloat = 0
          if pieceOfNews?.photos?.count == 1 {
            guard let photo = pieceOfNews?.photos?[0] else {return}
            let postPhotoCollectionViewWidth = screenWidth - NewsPhotosTableViewCell.xOffsetForPostPhotos * 2
            postPhotosCollectionViewHeight = postPhotoCollectionViewWidth * CGFloat(photo.height / photo.width)
          } else {
            postPhotosCollectionViewHeight = screenWidth - NewsPhotosTableViewCell.xOffsetForPostPhotos * 2
          }
            cellHeights[indexPath] = NewsPhotosTableViewCell.yOffsetFromCellEdge + postPhotosCollectionViewHeight
          
        case .Footer:
          let pieceOfNews = self.postNews?[section] as! NewsfeedPost
          let newsLikesControl = LikeControl()
          newsLikesControl.numberOfLikes = pieceOfNews.numberOfLikes
          newsLikesControl.updateView()
          
          let newsLikesControlHeight = newsLikesControl.frame.height
          
          let commentsButtonSize = NewsResponseView.commentButtonSize
          
          let commentsLabelSize = getLabelSize(text: String(pieceOfNews.commentsNumber), font: NewsResponseView.commentsAndSharesLabelsFont, maxWidth: screenWidth)
          commentsLabelSizes[indexPath] = commentsLabelSize
 
          let sharesButtonSize = NewsResponseView.shareButtonSize
          
          let sharesLabelSize = getLabelSize(text: String(pieceOfNews.sharesNumber), font: NewsResponseView.commentsAndSharesLabelsFont, maxWidth: screenWidth)
          sharesLabelSizes[indexPath] = sharesLabelSize
          
          let height = max(newsLikesControlHeight, commentsButtonSize.height, commentsLabelSize.height, sharesButtonSize.height, sharesLabelSize.height)
          
          cellHeights[indexPath] = NewsFooterTableViewCell.yOffsetFromCellEdge + height
          
        }
      }
      section = section + 1
    } while section <= numberOfRows.keys.sorted().last!
  }
  
  
  private func heightForString(_ str : NSAttributedString) -> CGFloat {
    var boundsRect = CGSize()
    let maxSize = CGSize(width: self.screenWidth - NewsTextTableViewCell.xOffsetFromCellEdge * 2, height: .greatestFiniteMagnitude)
    
    let textView = UITextView()
    textView.frame = CGRect(origin: .zero, size: maxSize)
    textView.attributedText = str
    boundsRect = textView.sizeThatFits(maxSize)
    return boundsRect.height
  }
  
  private func getLabelSize(text: String, font: UIFont, maxWidth: CGFloat) -> CGSize {
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

