//
//  NewsfeedViewController.swift
//  Network
//
//  Created by Anastasia Romanova on 21/11/2018.
//  Copyright © 2018 Anastasia Romanova. All rights reserved.
//

import UIKit

let cityImage = UIImage(named: "City")
let carImage = UIImage(named: "Ferrari")
let lakeImage = UIImage(named: "Lake")
let londonImage = UIImage(named: "London")
let islandImage = UIImage(named: "Maldives")
let mountainsImage = UIImage(named: "Mountains")
let tigerImage = UIImage(named: "Tiger")

var news = [
  NewsfeedItem(sourceName: "City", sourcePhoto: cityImage!, postTime: Date.init(timeIntervalSinceNow: 0), postText: "Big city lights\nBig city life\nMe try fi get by\nPreasure nah ease up no matta how hard me try\nBig city life\nHear my heart have no base\nAnd right now babylon de pon me case\nBig city life, try fi get by preasure nah ease up no matta how hard me try Big city life My heart have no base And right now babylon de pon me case People in show, all lined in a row We just push on by, its funny How hard we try Take a moment to relax Before you do anything rash Don't you wanna know me Be a friend of mine I'll share some wisdom with you Dont you ever get lonely From time to time Dont let the system get you down Big city life Me try fi get by Preasure nah ease up no matta how hard me try Big city life Hear my heart have no base And right now babylon de pon me case Big city life, try fi get by preasure nah ease up no matta how hard me try Big city life My heart have no base And right now babylon de pon me case Soon our work is done All of us one by one Still we live our lives As if all this stuff survives Don't you wanna know me Be a friend of mine I'll share some wisdom with you Dont you ever get lonely From time to time Dont let the system get you down The linguist accross the seas and the oceans A Permanent itinerant is what ive chosen I find myself in big city prison Arisen from the vision on mankind, designed To keep me, discreetly, neatly in the corner Youll find me with the flora and the fauna And the hardship, Back a yard is where my heart is, still I find it hard to depart this Big city life Big city life Me try fi get by Preasure nah ease up no matta how hard me try Big city life Hear my heart have no base And right now babylon de pon me case Big city life, try fi get by preasure nah ease up no matta how hard me try Big city life My heart have no base And right now babylon de pon me case Big city life Me try fi get by Preasure nah ease up no matta how hard me try Big city life Hear my heart have no base And right now babylon de pon me case Big city life, try fi get by preasure nah ease up no matta how hard me try Big city life My heart have no base And right now babylon de pon me case", numberOfViews: 467, numberOfLikes: 34, commentsNumber: 15, sharesNumber: 56, isLiked: true),
  NewsfeedItem(sourceName: "Ferrari", sourcePhoto: carImage!, postTime: Date.init(timeIntervalSinceNow: 0), postText: "Cool Ferrari to your feed", numberOfViews: 45, numberOfLikes: 8, commentsNumber: 67, sharesNumber: 104, isLiked: false)
//  NewsfeedItem(header: "Let's go rest!", image: lakeImage!, numberOfViews: 90, numberOfLikes: 21, isLiked: false),
//  NewsfeedItem(header: "Big Ben", image: londonImage!, numberOfViews: 1079, numberOfLikes: 995, isLiked: false),
//  NewsfeedItem(header: "The happiness in paradise", image: islandImage!, numberOfViews: 523, numberOfLikes: 350, isLiked: false),
//  NewsfeedItem(header: "Breathtaking routes for your winter journey", image: mountainsImage!, numberOfViews: 89, numberOfLikes: 70, isLiked: true),
//  NewsfeedItem(header: "WWF", image: tigerImage!, numberOfViews: 3, numberOfLikes: 1, isLiked: true)
]

class NewsfeedViewController: UITableViewController {
  
    var tapGestureRecognizer = UITapGestureRecognizer()
    var longPressRecognizer = UILongPressGestureRecognizer()
  
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.estimatedRowHeight = 470
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return news.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsfeedPostCell", for: indexPath) as! NewsfeedPostCell
        let pieceOfNews = news[indexPath.row]
        cell.configure(sourceName: pieceOfNews.sourceName, sourcePhoto: pieceOfNews.sourcePhoto, postTime: pieceOfNews.postTime, postText: pieceOfNews.postText, numberOfLikes: pieceOfNews.numberOfLikes, commentsNumber: pieceOfNews.commentsNumber, sharesNumber: pieceOfNews.sharesNumber, numberOfViews: pieceOfNews.numberOfViews, isLiked: pieceOfNews.isLiked)
//        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(animatePhotoWithTap(_:)))
//        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(animatePhotoWithPress(_:)))
//        cell.newsPhoto.addGestureRecognizer(tapGestureRecognizer)
//        cell.newsPhoto.addGestureRecognizer(longPressRecognizer)
        return cell
    }
  
  @objc func animatePhotoWithTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
    guard let view = tapGestureRecognizer.view else {return}
    switch tapGestureRecognizer.state {
    case .ended:
      let animationIn = CABasicAnimation(keyPath: "transform.scale")
      animationIn.fromValue = 1
      animationIn.toValue = 0.8
      animationIn.duration = 0.2
      animationIn.beginTime = CACurrentMediaTime()
      view.layer.add(animationIn, forKey: nil)
      animationOut(view: view)
    default: return
    }
  }
  
  @objc func animatePhotoWithPress(_ longPressRecognizer: UILongPressGestureRecognizer) {
    guard let view = longPressRecognizer.view else {return}
    let animationIn = CABasicAnimation(keyPath: "transform.scale")
    switch longPressRecognizer.state {
    case .began:
      animationIn.fromValue = 1
      animationIn.toValue = 0.8
      animationIn.duration = 0.2
      animationIn.beginTime = CACurrentMediaTime()
      view.layer.add(animationIn, forKey: nil)
      let scale = CATransform3DScale(CATransform3DIdentity, 0.8, 0.8, 0)
      view.transform = CATransform3DGetAffineTransform(scale)
    case .ended:
      animationOut(view: view)
      view.transform = .identity
    default: return
    }
  }
  
  private func animationOut(view: UIView) {
    let animationOut = CASpringAnimation(keyPath: "transform.scale")
    animationOut.fromValue = 0.8
    animationOut.toValue = 1
    animationOut.duration = 2
    animationOut.stiffness = 200
    animationOut.mass = 1.5
    animationOut.damping = 9
    animationOut.beginTime = CACurrentMediaTime()
    view.layer.add(animationOut, forKey: nil)
  }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
