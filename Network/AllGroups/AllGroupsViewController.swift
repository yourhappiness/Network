//
//  AllGroupsViewController.swift
//  Network
//
//  Created by Anastasia Romanova on 10/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import RealmSwift

class AllGroupsViewController: UITableViewController, UISearchBarDelegate {
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  public var filteredGroups = [Group]()
  public var selectedGroup = Group()
  private let vkService = VKService()
  
  private let queue: DispatchQueue = DispatchQueue.global(qos: .background)
  private var search: DispatchWorkItem = DispatchWorkItem(block: {})
  
  override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.rowHeight = 48
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      guard !isFiltering() else {return filteredGroups.count}
      return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllGroupsCell", for: indexPath) as! AllGroupsCell
        let groupProp: Group
        if isFiltering() {
          groupProp = filteredGroups[indexPath.row]
        } else {
          return cell
        }
        cell.configure(with: groupProp)
        return cell
    }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if isFiltering() {
        self.selectedGroup = self.filteredGroups[indexPath.row]
        vkService.joinOrLeaveGroup(id: filteredGroups[indexPath.row].id, toJoin: true) { [weak self] (result: Bool?, error: Error?) in
          if let error = error {
            self?.showAlert(error: error)
          }
          guard let result = result, let self = self else {return}
          DispatchQueue.main.async {
            if result {
              let alert = UIAlertController(title: "Оповещение", message: "Вы вступили в группу", preferredStyle: .alert)
              let action = UIAlertAction(title: "ОК", style: .cancel, handler: nil)
              alert.addAction(action)
              do {
                try DatabaseService.saveVKData([self.filteredGroups[indexPath.row]])
              } catch {
                self.showAlert(error: error)
              }
              self.present(alert, animated: true, completion: nil)
              self.performSegue(withIdentifier: "addGroup", sender: self)
            } else {
              //создаем контроллер
              let alert = UIAlertController(title: "Ошибка", message: "Не получается вступить в эту группу", preferredStyle: .alert)
              //Создаем кнопку
              let action = UIAlertAction(title: "ОК", style: .cancel, handler: nil)
              //Добавляем кнопку на контроллер
              alert.addAction(action)
              //Показываем контроллер
              self.parent?.present(alert, animated: true, completion: nil)
              tableView.deselectRow(at: indexPath, animated: false)
            }
          }
        }
      }
      tableView.deselectRow(at: indexPath, animated: false)
    }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    filteredGroups.removeAll()
    search.cancel()
    search = DispatchWorkItem() {
        self.vkService.searchGroups(query: searchText) {[weak self] searchedGroups, error in
        if let error = error {
          print(error.localizedDescription)
        }
        guard let searchedGroups = searchedGroups, let self = self else {return}
        self.filteredGroups = searchedGroups
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
    }
    queue.asyncAfter(wallDeadline: .now() + 0.5, execute: search)
  }

  func isFiltering() -> Bool {
    return !(searchBar.text?.isEmpty ?? true)
  }

}
