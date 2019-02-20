//
//  VKLoginViewController.swift
//  Network
//
//  Created by Anastasia Romanova on 21/12/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit
import WebKit

class VKLoginViewController: UIViewController {

  //MARK: - Outlets
  @IBOutlet weak var vkWebView: WKWebView! {
    didSet {
      vkWebView.navigationDelegate = self
    }
  }
  
  
    override func viewDidLoad() {
      super.viewDidLoad()
    
      var urlComponents = URLComponents()
      urlComponents.scheme = "https"
      urlComponents.host = "oauth.vk.com"
      urlComponents.path = "/authorize"
      urlComponents.queryItems = [
        URLQueryItem(name: "client_id", value: "6789195"),
        URLQueryItem(name: "display", value: "mobile"),
        URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
        URLQueryItem(name: "scope", value: "270342"),
        URLQueryItem(name: "response_type", value: "token"),
        URLQueryItem(name: "v", value: "5.92")
      ]
      let request = URLRequest(url: urlComponents.url!)
      vkWebView.load(request)
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

extension VKLoginViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
    guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment else {
      decisionHandler(.allow)
      return
    }
    let params = fragment
      .components(separatedBy: "&")
      .map {$0.components(separatedBy: "=")}
      .reduce([String : String]()) {result, param in
        var dict = result
        let key = param[0]
        let value = param[1]
        dict[key] = value
        return dict
    }
    guard let token = params["access_token"], let userId = params["user_id"] else {return}
    Session.instance.token = token
    print(token)
    Session.instance.userId = Int(userId)!
    decisionHandler(.cancel)
    performSegue(withIdentifier: "VKLogin", sender: self)
  }
}
