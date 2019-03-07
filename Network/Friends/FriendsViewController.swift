//
//  FriendsViewController.swift
//  Network
//
//  Created by Anastasia Romanova on 10/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//
import Foundation
import UIKit
import RealmSwift

class FriendsViewController: UIViewController, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var firstLettersControl: SearchForFriend!
  @IBOutlet weak var searchBar: UISearchBar!

  var activityIndicator: ActivityIndicatorView?
  private let vkService = VKService()
  private var photoService: PhotoService?
  
  private var userFriends: Results<User>? = try? Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)).objects(User.self).filter("deactivated = %@", false)
  private var notificationToken: NotificationToken?
  
  private var filteredFriends: Results<User>?
  private var groupedFriends = [Results<User>]()
  
    override func viewDidLoad() {
      super.viewDidLoad()
      setActivityIndicator()
      setTableView()
      view.bringSubviewToFront(firstLettersControl)
      firstLettersControl.layer.isOpaque = false
      firstLettersControl.layer.backgroundColor = UIColor.clear.cgColor
      photoService = PhotoService(container: self.tableView)

      notificationToken = userFriends?.observe { [weak self] changes in
        guard let self = self, let userFriends = self.userFriends else {return}
        switch changes {
        case .initial(_):
          guard !self.isFiltering() else {
            guard let filteredFriends = self.filteredFriends else {return}
            self.activityIndicator?.startAnimation()
            DispatchQueue.global().sync {
              firstLetters = self.firstLettersControl.getFirstSurnameLetters(for: filteredFriends)
              self.groupedFriends = self.getFriendsToGroups(for: filteredFriends, by: firstLetters)
            }
            self.firstLettersControl.setupView(with: filteredFriends)
            self.tableView.reloadData()
            self.activityIndicator?.stopAnimation()
            return
          }
          self.activityIndicator?.startAnimation()
          DispatchQueue.global().sync {
            firstLetters = self.firstLettersControl.getFirstSurnameLetters(for: userFriends)
            self.groupedFriends = self.getFriendsToGroups(for: userFriends, by: firstLetters)
          }
          DispatchQueue.main.async {
            self.firstLettersControl.setupView(with: userFriends)
            self.tableView.reloadData()
            self.activityIndicator?.stopAnimation()
          }
        case .update(_, _, _, _):
          DispatchQueue.global().sync {
            firstLetters = self.firstLettersControl.getFirstSurnameLetters(for: userFriends)
            self.groupedFriends = self.getFriendsToGroups(for: userFriends, by: firstLetters)
          }
          self.firstLettersControl.setupView(with: userFriends)
          self.tableView.reloadData()
        case .error(let error):
          self.showAlert(error: error)
        }
      }
      
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.activityIndicator?.startAnimation()
    vkService.get { [weak self] (users: [User]?, error: Error?) in
      if let error = error {
        self?.showAlert(error: error)
        return
      }
      guard let users = users, let self = self else {return}
      DispatchQueue.main.async {
        do {
          let realm = try Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true))
          try realm.write {
            realm.add(users, update: true)
          }
        } catch {
          self.showAlert(error: error)
        }
          guard let userFriends = self.userFriends else {return}
          self.firstLettersControl.setupView(with: userFriends)
          self.activityIndicator?.stopAnimation()
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    
    //подписываемся на два уведомления: одно приходит при появлении клавиатуры
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
    //Второе - когда она пропадает
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    view.bringSubviewToFront(firstLettersControl)
      self.firstLettersControl.addTarget(self, action: #selector(self.letterWasChoosen(_:)), for: .valueChanged)
      self.firstLettersControl.panGestureRecognizer.addTarget(self, action: #selector(self.panLetter(_:)))
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    for button in firstLettersControl.buttons {
      if button.isSelected == true {
        button.isSelected = false
      }
    }
    self.activityIndicator?.removeFromSuperview()
    self.notificationToken?.invalidate()
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  
  func setActivityIndicator() {
    let indicatorWidth = self.view.bounds.width / 6
    let indicatorHeight = (indicatorWidth - 15) / 3
    activityIndicator = ActivityIndicatorView(frame: CGRect(x: self.view.bounds.midX - indicatorWidth / 2, y: self.view.bounds.midY - indicatorHeight / 2, width: indicatorWidth, height: indicatorHeight))
    activityIndicator?.centerXAnchor.constraint(equalToSystemSpacingAfter: self.view.centerXAnchor, multiplier: 1)
    activityIndicator?.centerYAnchor.constraint(equalToSystemSpacingBelow: self.view.centerYAnchor, multiplier: 1)
    self.view.addSubview(activityIndicator!)
  }
  
  func setTableView() {
    searchBar.delegate = self
    tableView.rowHeight = 66
    searchBar.barTintColor = tableView.backgroundColor
    tableView.tableHeaderView = searchBar
    let nib = UINib(nibName: "FriendsHeader", bundle: nil)
    tableView.register(nib, forHeaderFooterViewReuseIdentifier: "FriendsHeaderView")
  }
  
  @objc func letterWasChoosen(_ sender: SearchForFriend) {
    guard let choosenLetter = sender.selectedLetter else {return}
    guard let index = firstLetters.index(of: choosenLetter) else {return}
    self.tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
  }
  
  @objc func panLetter(_ gestureRecognizer: PanGestureRecognizer) {
    guard firstLettersControl != nil else {return}
    var initialPosition = CGPoint()
    if gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
      initialPosition = gestureRecognizer.initialTouchPoint
      let translation = gestureRecognizer.translation(in: firstLettersControl.stackView)
      let position = CGPoint(x: initialPosition.x + translation.x, y: initialPosition.y + translation.y)
      for button in firstLettersControl.buttons {
        if button.frame.contains(position) {
          guard let index = firstLettersControl.buttons.index(of: button) else {return}
          firstLettersControl.selectedLetter = firstLetters[index]
        }
      }
    }
  }
  
  func getFriendsToGroups(for friends: Results<User>, by letters: [Character]) -> [Results<User>] {
    var friendsInGroups = [Results<User>]()
    for letter in letters {
      friendsInGroups.append(friends.filter("lastName BEGINSWITH[cd] %@", String(letter)))
    }
    return friendsInGroups
  }

  //Когда клавиатура появляется
  @objc func keyboardWasShown(notification: Notification) {
    //Получаем размер клавиатуры
    let info = notification.userInfo! as NSDictionary
    let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
    let contentInsets = UIEdgeInsets(top: 0.0,left: 0.0,bottom: kbSize.height,right: 0.0)
    //Добавляем отступ внизу UIScrollview, равный размеру клавиатуры
    tableView.contentInset = contentInsets
    tableView.scrollIndicatorInsets = contentInsets
  }
  //Когда клавиатура исчезает
  @objc func keyboardWillBeHidden (notification: Notification) {
    //Устанавливаем отступ внизу UIScrollview, равный 0
    let contentInsets = UIEdgeInsets.zero
    tableView.contentInset = contentInsets
    tableView.scrollIndicatorInsets = contentInsets
  }
  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "seeFriendPhoto" else {return}
    // Get the new view controller using segue.destination.
    guard let friendPhotoViewController = segue.destination as? FriendPhotoViewController else {return}
    // Pass the selected object to the new view controller.
    guard let indexPath = tableView.indexPathForSelectedRow else {return}
    var selectedUser = User()
    var groupedFriends = [[User]]()
    self.groupedFriends.forEach { (group) in
      let groupOfFriends = Array(group)
      groupedFriends.append(groupOfFriends)
    }
    selectedUser = groupedFriends[indexPath.section][indexPath.row]
    friendPhotoViewController.user = selectedUser
    self.view.endEditing(true)
  }
  
}


extension FriendsViewController: UITableViewDataSource {
  
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return firstLetters.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return groupedFriends[section].count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsCell
    var friendProp: User
    friendProp = groupedFriends[indexPath.section][indexPath.row]
    cell.configure(with: friendProp, by: indexPath, service: self.photoService)
    cell.backgroundColor = tableView.backgroundColor
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FriendsHeaderView") as! FriendsHeaderView
    header.firstLetter.text = String(firstLetters[section])
    header.contentsView.backgroundColor = tableView.backgroundColor
    header.contentsView.alpha = 0.5
    return header
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

extension FriendsViewController: UISearchBarDelegate {
  
  func isFiltering() -> Bool {
    return !(searchBar.text?.isEmpty ?? true)
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    guard let userFriends = self.userFriends else {return}
    searchBar.showsCancelButton = true
    for button in firstLettersControl.buttons {
      if button.isSelected == true {
        button.isSelected = false
      }
    }
    self.filteredFriends = userFriends.filter("firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", searchText, searchText)
    guard let filteredFriends = self.filteredFriends else {return}
    DispatchQueue.global().sync {
      firstLetters = self.firstLettersControl.getFirstSurnameLetters(for: filteredFriends)
      self.groupedFriends = self.getFriendsToGroups(for: filteredFriends, by: firstLetters)
    }
    firstLettersControl.setupView(with: filteredFriends)
    tableView.reloadData()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    for button in firstLettersControl.buttons {
      if button.isSelected == true {
        button.isSelected = false
      }
    }
    searchBar.showsCancelButton = false
    guard let userFriends = self.userFriends else {return}
    DispatchQueue.global().sync {
      firstLetters = self.firstLettersControl.getFirstSurnameLetters(for: userFriends)
      self.groupedFriends = self.getFriendsToGroups(for: userFriends, by: firstLetters)
    }
    firstLettersControl.setupView(with: userFriends)
    tableView.reloadData()
    self.view.endEditing(true)
  }
  
  
}
