//
//  DataReloadable.swift
//  Network
//
//  Created by Anastasia Romanova on 07/03/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

protocol DataReloadable {
  func reloadRow(at indexPath: IndexPath)
}

extension UICollectionView: DataReloadable {
  func reloadRow(at indexPath: IndexPath) {
    self.reloadItems(at: [indexPath])
  }
}

extension UITableView: DataReloadable {
  func reloadRow(at indexPath: IndexPath) {
    self.reloadRows(at: [indexPath], with: .automatic)
  }
}
