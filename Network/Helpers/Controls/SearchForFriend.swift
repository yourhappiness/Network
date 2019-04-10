//
//  SearchForFriend.swift
//  Network
//
//  Created by Anastasia Romanova on 15/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import RealmSwift

var firstLetters = [Character]()

@IBDesignable class SearchForFriend: UIControl {
  
  var panGestureRecognizer = PanGestureRecognizer()
  
  var selectedLetter: Character? = nil {
    didSet {
      self.updateSelectedLetter()
      self.sendActions(for: .valueChanged)
    }
  }
  
  var buttons: [UIButton] = []
  var stackView: UIStackView!
  
  func getFirstSurnameLetters(for friends: Results<User>) -> [Character] {
    var firstLetters = [Character]()
    for friend in friends {
      guard let firstLetter = friend.lastName.first else {continue}
      firstLetters.append(firstLetter)
    }
    return Array(Set(firstLetters)).sorted(by: {$0 < $1})
  }
  
  
  public func setupView(with friends: Results<User>) {
    self.buttons.removeAll()
    if stackView != nil {
      self.stackView.removeFromSuperview()
    }
    self.removeGestureRecognizer(panGestureRecognizer)
    for letter in firstLetters {
      let button = UIButton(type: .system)
      button.setTitle(String(letter), for: .normal)
      button.setTitleColor(.black, for: .normal)
      button.setTitleColor(.white, for: .selected)
      button.addTarget(self, action: #selector(selectLetter(_:)), for: .touchUpInside)
      self.buttons.append(button)
    }
    
    stackView = UIStackView(arrangedSubviews: self.buttons)
    
    self.addSubview(stackView)
    
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    //получить нижнюю границу экрана
    stackView.frame = CGRect(x: bounds.minX, y: bounds.minY + 70, width: bounds.width, height: firstLetters.count * 15 > Int(bounds.height - 70) ? bounds.height - 70 : CGFloat(firstLetters.count * 15))
    self.addGestureRecognizer(panGestureRecognizer)
  }
  
  private func updateSelectedLetter() {
    for (index, button) in self.buttons.enumerated() {
      let letter = firstLetters[index]
      button.isSelected = letter == self.selectedLetter
    }
  }

  @objc private func selectLetter(_ sender: UIButton) {
    guard let index = self.buttons.index(of: sender) else {return}
    let letter = firstLetters[index]
    self.selectedLetter = letter
  }
}
