//
//  LoginFormController.swift
//  Weather
//
//  Created by Anastasia Romanova on 04/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

class LoginFormController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var loginInput: UITextField!
  @IBOutlet weak var passwordInput: UITextField!
  
  //Когда клавиатура появляется
  @objc func keyboardWasShown(notification: Notification) {
    //Получаем размер клавиатуры
    let info = notification.userInfo! as NSDictionary
    let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
    let contentInsets = UIEdgeInsets(top: 0.0,left: 0.0,bottom: kbSize.height,right: 0.0)
    //Добавляем отступ внизу UIScrollview, равный размеру клавиатуры
    scrollView.contentInset = contentInsets
    scrollView.scrollIndicatorInsets = contentInsets
  }
  //Когда клавиатура исчезает
  @objc func keyboardWillBeHidden (notification: Notification) {
    //Устанавливаем отступ внизу UIScrollview, равный 0
    let contentInsets = UIEdgeInsets.zero
    scrollView.contentInset = contentInsets
    scrollView.scrollIndicatorInsets = contentInsets
  }
  
  @objc func hideKeyboard() {
    scrollView.endEditing(true)
  }
  
  override func viewDidLoad() {
        super.viewDidLoad()
        //жест нажатия
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        //присваиваем его UIScrollview
        scrollView.addGestureRecognizer(hideKeyboardGesture)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    //подписываемся на два уведомления: одно приходит при появлении клавиатуры
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
    //Второе - когда она пропадает
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  
    // MARK: - Navigation
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    //Проверяем данные
    let checkResult = checkUserData()
    //Если данные неверны, покажем ошибку
    if !checkResult {
      showLoginError()
    }
    //Вернем результат
    return checkResult
  }
  
  @IBAction func didEndEditing(_ sender: UITextField) {
    guard checkUserData() else {
      showLoginError()
      return
    }
//    [sender .becomeFirstResponder()]
//    [sender .resignFirstResponder()]
    performSegue(withIdentifier: "Login", sender: self)
  }
  
  func checkUserData() -> Bool {
    //получаем текст логина
    let login = loginInput.text!
    //получаем текст пароля
    let password = passwordInput.text!
    //Проверяем верны ли они
    if login == "admin" && password == "123456" {
      return true
    } else {
      return false
    }
  }
 
  func showLoginError() {
    //создаем контроллер
    let alert = UIAlertController(title: "Ошибка", message: "Введены неверные данные пользователя", preferredStyle: .alert)
    //Создаем кнопку
    let action = UIAlertAction(title: "ОК", style: .cancel, handler: nil)
    //Добавляем кнопку на контроллер
    alert.addAction(action)
    //Показываем контроллер
    present(alert, animated: true, completion: nil)
  }
}
