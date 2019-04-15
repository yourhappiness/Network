//
//  GroupsViewController.swift
//  Network
//
//  Created by Anastasia Romanova on 10/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import RealmSwift

class GroupsViewController: UITableViewController {
  
  private let vkService = VKService()
  private var photoService: PhotoService?
  private var userGroups: Results<Group>? = try? Realm().objects(Group.self).filter("isUserGroup = %@", true)
  public var notificationToken: NotificationToken?

    override func viewDidLoad() {
      super.viewDidLoad()
      tableView.rowHeight = 48
      photoService = PhotoService(container: self.tableView)
    
      notificationToken = userGroups?.observe { [weak self] changes in
        guard let self = self else {return}
        switch changes {
        case .initial:
          self.tableView.reloadData()
        case .update(_, let deletions, let insertions, let modifications):
          self.tableView.applyChanges(deletions: deletions, insertions: insertions, updates: modifications)
        case .error(let error):
          self.showAlert(error: error)
        }
      }      
    }
  
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(true)
      
      //получение групп
      vkService.get { [weak self] (userGroups: [Group]?, error: Error?) in
        if let error = error {
          self?.showAlert(error: error)
        }
        guard let userGroups = userGroups, let self = self else {return}
        for group in userGroups {
          group.isUserGroup = true
        }
        DispatchQueue.main.async {
          do {
            let realm = try Realm()
            try realm.write {
                realm.add(userGroups, update: true)
            }
          } catch {
            self.showAlert(error: error)
          }
        }
      }

    }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    self.notificationToken?.invalidate()
  }
  

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return userGroups?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsCell", for: indexPath) as! GroupsCell
      guard let userGroups = userGroups else {return UITableViewCell()}
      cell.configure(with: userGroups[indexPath.row], by: indexPath, service: photoService)
      cell.backgroundColor = tableView.backgroundColor
      return cell
    }
  
  @IBAction func addGroup(segue: UIStoryboardSegue) {
//    if segue.identifier == "addGroup" {
//        }
      }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
  
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
          guard let userGroups = userGroups else {return}
          vkService.joinOrLeaveGroup(id: userGroups[indexPath.row].id, toJoin: false) {[weak self] result, error in
            DispatchQueue.main.async {
              if let error = error {
                self?.showAlert(error: error)
              }
              guard let result = result, let self = self else {return}
              if result {
                  let alert = UIAlertController(title: "Оповещение", message: "Вы покинули группу", preferredStyle: .alert)
                  let action = UIAlertAction(title: "ОК", style: .cancel, handler: nil)
                  alert.addAction(action)
                  self.parent?.present(alert, animated: true, completion: nil)
                  do {
                    try DatabaseService.deleteVKData([userGroups[indexPath.row]])
                  } catch {
                    self.showAlert(error: error)
                  }
              } else {
                //создаем контроллер
                let alert = UIAlertController(title: "Ошибка", message: "Не получается покинуть эту группу", preferredStyle: .alert)
                //Создаем кнопку
                let action = UIAlertAction(title: "ОК", style: .cancel, handler: nil)
                //Добавляем кнопку на контроллер
                alert.addAction(action)
                //Показываем контроллер
                self.parent?.present(alert, animated: true, completion: nil)
              }
            }
          }
        } else if editingStyle == .insert {
        }
    }
  
}
