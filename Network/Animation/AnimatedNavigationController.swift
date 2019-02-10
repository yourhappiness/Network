//
//  AnimatedNavigationController.swift
//  Network
//
//  Created by Anastasia Romanova on 02/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class AnimatedNavigationController: UINavigationController, UINavigationControllerDelegate {
  
    let interactiveTransition = InteractiveTransition()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        // Do any additional setup after loading the view.
    }
  
  func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransition.hasStarted ? interactiveTransition : nil
  }
  
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if operation == .push {
      self.interactiveTransition.viewController = toVC
      return PushAnimator()
    } else if operation == .pop {
      self.interactiveTransition.viewController = toVC
      return PopAnimator()
    }
    return nil
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
