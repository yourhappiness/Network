//
//  UIViewController+Ext.swift
//  Network
//
//  Created by Anastasia Romanova on 16/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(error: Error) {
        let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
