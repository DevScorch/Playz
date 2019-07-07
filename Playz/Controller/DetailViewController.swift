//
//  DetailViewController.swift
//  Playz
//
//  Created by LangsemWork on 06.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit

//We may not need this its only to display the feed with updates after being into discovery,hashtag profile pages etc
class DetailViewController: UIViewController {
    
    var postId: String = "" {
        didSet {
            loadPost()
        }
    }
    
    var post = PostModel()
    var user = UserModel()
    
    //Dynamic cell heigh constraint
    struct StoryboardHomeFeed {
        static let FeedCell = "FeedCell"
        static let FeedHeaderCell = "FeedHeaderCell"
        static let FeedHeaderHeight: CGFloat = 57.0
        static let FeedHeight: CGFloat = 310.0
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = StoryboardHomeFeed.FeedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func loadPost() {
        PostObserver().observePost(withId: postId) { [weak self] (post) in
            guard let postUid = post.uid else {
                return
            }
            self?.fetchUser(uid: postUid, completed: { [weak self] in
                self?.post = post
                self?.tableView.reloadData()
            })
        }
    }
    
    func fetchUser(uid: String, completed:  @escaping () -> Void ) {
        UserObserver().observeUser(withId: uid, completion: { [weak self] user in
            self?.user = user
            completed()
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail_CommentVC" {
            guard let commentVC = segue.destination as? CommentViewController, let postId = sender as? String else {
                return
            }
            commentVC.postId = postId
        }
        
        if segue.identifier == "Detail_HashTagSegue" {
            guard let hashTagVC = segue.destination as? HashTagViewController, let tag = sender as? String else {
                return
            }
            hashTagVC.tag = tag
        }
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardHomeFeed.FeedCell, for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.post = post
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardHomeFeed.FeedHeaderCell) as? FeedHeaderCell else {
            return nil
        }
       
        cell.user = user
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return StoryboardHomeFeed.FeedHeaderHeight
    }
}

//Segues for hashtag and comment
extension DetailViewController: FeedCellDelegate, FeedHeaderCellDelegate {
    func playTappedVideo(with: URL) {
        // Do nothing
    }
    
    func goToVisitUserVC(user: UserModel) {
        performSegue(withIdentifier: "Detail_VisitUserSegue", sender: user)

    }
    
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "Detail_CommentVC", sender: postId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Detail_HashTagSegue", sender: tag)
    }
}
