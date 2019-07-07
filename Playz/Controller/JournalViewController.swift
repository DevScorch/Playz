//
//  JournalViewController.swift
//  Playz
//
//  Created by Johan on 29-06-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import FeedKit
import Firebase
class JournalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // DEVSCORCH: Variables
    
    var notifications = [NotificationModel]()
    
    var feedUrl = URL(string: "http://feeds.ign.com/ign/all.rss")!
    lazy var parser = FeedParser(URL: feedUrl)
    lazy var result = parser.parse()
    var rssNewItems = [RSSFeedItem]()
    var firebaseNewsItems = [NewsModel]()
    
    // DEVSCORCH: IBOutlets
    
    @IBOutlet weak var journalSegmentControl: UISegmentedControl!
    @IBOutlet weak var journalTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        journalTableview.delegate = self
        journalTableview.dataSource = self
        loadNotifications()
    }
    
    // DEVSCORCH: Notification Setup
    
    @IBAction func changeTableViewFeed(_ sender: UISegmentedControl) {
        notifications.removeAll()
        rssNewItems.removeAll()
        firebaseNewsItems.removeAll()
        journalTableview.reloadData()
      
        if sender.selectedSegmentIndex == 0 {
            loadNotifications()
        } else {
            parseAsync()
            loadFirebaseNews()
        }
    }
    
    func loadNotifications() {
        guard let currentUser = UserObserver().CURRENT_USER else {
            return
        }
        let spinnerVC = UIViewController.displaySpinner(onView: self.view)
        NotificationObserver().observeNotification(withId: currentUser.uid, completion: {
            notification in
            if let notification = notification {
            if !self.alreadyExists(notification: notification) {
                UserObserver().observeUser(withId: notification.from!, completion: { [weak self] user in
                    notification.fromUser = user
                    self?.notifications.append(notification)
                    self?.notifications.sort(by: { (model1, model2) -> Bool in
                        guard let timeStamp1 = model1.timeStamp else {
                            return false
                        }
                        guard let timeStamp2 = model2.timeStamp else {
                            return false
                        }
                        return timeStamp1 > timeStamp2
                    })
                    self?.journalTableview.reloadData()
                })
            }
            }
            UIViewController.removeSpinner(spinner: spinnerVC)
        })
    }
    
    func loadFirebaseNews() {
        let spinnerVC = UIViewController.displaySpinner(onView: self.view)
        NewsObserver().observerNews { [unowned self] (model) in
            if let model = model {
                if !self.hasNews(title: model.message) {
                    self.firebaseNewsItems.append(model)
                    self.journalTableview.reloadData()
                }
            }
            UIViewController.removeSpinner(spinner: spinnerVC)
        }
    }
    
    func hasNews(title: String) -> Bool {
        for news in firebaseNewsItems where news.message == title {
            return true
        }
        return false
    }

    func alreadyExists(notification: NotificationModel) -> Bool {
        for existingNotification in notifications where notification.objectId == existingNotification.objectId {
            return true
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Notification_FeedSegue" {
            guard let detailVC = segue.destination as? FeedViewController, let postId = sender as? String else {
                return
            }
            detailVC.postID = postId
        } else if segue.identifier == "Notification_VisitUSerProfileSegue" {
            guard let profileVC = segue.destination as? ProfileViewController, let user = sender as? UserModel else {
                return
            }
            profileVC.user = user
        }
        
        if segue.identifier == "Notification_CommentSegue" {
            
            guard let commentVC = segue.destination as? CommentViewController, let postId = sender as? String else {
                return
            }
            commentVC.postId = postId
        }
        
        if segue.identifier == "News_WebSegue" {
            guard let webVC = segue.destination as? WebViewController, let news = sender as? RSSFeedItem else {
                return
            }
            if let link = news.link, let url = URL(string: link) {
                let request = URLRequest(url: url)
                webVC.urlRequest = request
            }
        }
        if segue.identifier == "News_NewsViewControllerSegue" {
            guard let newsVC = segue.destination as? NewsViewController, let news = sender as? NewsModel else {
                return
            }
            newsVC.news = news
        }
    }
    
    // DEVSCORCH: RSS fetch setup
    func parseAsync() {
        let spinnerVC = UIViewController.displaySpinner(onView: self.view)
        parser.parseAsync { [weak self] (result) in
            if let items = result.rssFeed?.items {
                self?.rssNewItems = items
                DispatchQueue.main.async { [weak self] in
                    self?.journalTableview.reloadData()
                }
            }
            UIViewController.removeSpinner(spinner: spinnerVC)
        }
    }
    
    // DEVSCORCH: Tableview Setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch journalSegmentControl.selectedSegmentIndex {
        case 0:
            print("print \(journalSegmentControl.selectedSegmentIndex)")
            return notifications.count
        case 1:
            print("print \(journalSegmentControl.selectedSegmentIndex)")
            let newsCount = rssNewItems.count + firebaseNewsItems.count
            return newsCount
        default:
            print("Nothing to display")
        }
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch journalSegmentControl.selectedSegmentIndex {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as? NotificationTableViewCell else {
                return UITableViewCell()
            }
            let notification = notifications[indexPath.row]
            let user = notification.fromUser
            cell.notification = notification
            cell.user = user
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsTableViewCell
            let index = indexPath.row
            if index >= firebaseNewsItems.count {
                let news = rssNewItems[index - firebaseNewsItems.count]
                cell?.rssNews = news
                cell?.delegate = self
            } else {
                let news = firebaseNewsItems[index]
                cell?.firebaseNews = news
                cell?.delegate = self
            }
            return cell!
            
        default:
            break
        }
        return UITableViewCell()
    }
}

extension JournalViewController: NewsTableViewCellDelegate {
    func presentNews(news: RSSFeedItem) {
        performSegue(withIdentifier: "News_WebSegue", sender: news)
    }
    
    func presentNews(news: NewsModel) {
        performSegue(withIdentifier: "News_NewsViewControllerSegue", sender: news)
    }
}

extension JournalViewController: NotificationTableViewCellDelegate {
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Notification_FeedSegue", sender: postId)
    }
    
    func goToProfileVC(user: UserModel) {
        performSegue(withIdentifier: "Notification_VisitUSerProfileSegue", sender: user)
    }
    
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "Notification_CommentSegue", sender: postId)
    }
}
