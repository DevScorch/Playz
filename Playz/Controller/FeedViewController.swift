//
//  FeedViewController.swift
//  Playz
//
//  Created by Johan on 28-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AVKit
import FBAudienceNetwork

class FeedViewController: UIViewController {

    @IBOutlet weak var Activity: UIActivityIndicatorView!
    // JAASTER: Variables
    private var hasSpecificPost: Bool {
        return postID != nil
    }
    // JAASTER: Ad variables
    private var adIndex = 9
    var adsManager: FBNativeAdsManager!
    
    lazy var adsCellProvider: FBNativeAdTableViewCellProvider = {
        let attributes = FBNativeAdViewAttributes.defaultAttributes(for: .genericHeight400)
        let rgb: CGFloat = 39/255
        attributes.backgroundColor = UIColor(red: rgb, green: rgb, blue: rgb, alpha: 1)
        attributes.titleColor = .white
        
        let provider = FBNativeAdTableViewCellProvider(manager: adsManager, for: .genericHeight400, for: attributes)
        provider.delegate = self
        return provider
    }()
    
    var postID: String?
    var posts = [PostModel]()
    var sortedPosts: [PostModel] {
        return posts.sorted(by: { (post1, post2) -> Bool in
            return post1.timeStamp! > post2.timeStamp!
        })
    }
    
    fileprivate var isLoadingPost = false
    let refreshControl = UIRefreshControl()
    
    // JAASTER: Outlets
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableViewFeed: UITableView!
    
    //Dynamic cell heigh constraint
    struct StoryboardHomeFeed {
        static let FeedCell = "FeedCell"
        static let FeedHeaderCell = "FeedHeaderCell"
        static let FeedHeaderHeight: CGFloat = 57.0
        static let FeedHeight: CGFloat = 330.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //Dynamic cell
        tableViewFeed.estimatedRowHeight = StoryboardHomeFeed.FeedHeight
        tableViewFeed.rowHeight = UITableViewAutomaticDimension
        
        tableViewFeed.dataSource = self
        tableViewFeed.delegate = self
        tableViewFeed.layoutMargins = .zero
        tableViewFeed.separatorInset = .zero
        
        //refresh controller
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableViewFeed.refreshControl = refreshControl
        refresh()
    }
    
    func configureAdManagerAndLoadAds() {
        adsManager = FBNativeAdsManager(placementID: "461031261020532_551496455307345", forNumAdsRequested: UInt(adIndex))
        adsManager.delegate = self
        adsManager.loadAds()
    }
    
    @objc func gestureForNewsNotif() {
        performSegue(withIdentifier: "newsNotifSegue", sender: nil)
    }

    func alert(title: String, msg: String) {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func loadPost(postID: String?, completionHandler: @escaping () -> Void) {
//        let spinnerVC = UIViewController.displaySpinner(onView: self.view)
        // add activity
        self.view.addSubview(self.Activity)
        Activity.startAnimating()
        Activity.hidesWhenStopped = true
        PostObserver().observePost(withId: postID!) { [weak self] (post) in
            if let newSelf = self {
                newSelf.isLoadingPost = true
                self?.refreshControl.beginRefreshing()
                UserObserver().observeUser(withId: post.uid!, completion: { (user) in
                    if !newSelf.posts.alreadyExists(model: post) {
                        post.user = user
                        newSelf.posts.append(post)
                        completionHandler()
                        self!.Activity.stopAnimating()
//                        UIViewController.removeSpinner(spinner: spinnerVC)
                    }
                })
            } else {
                self!.Activity.stopAnimating()
//                UIViewController.removeSpinner(spinner: spinnerVC)
            }
        }
    }
    
    //Fetch posts
    func loadPosts() {
        // when showing cell at index path, we are also loading posts which causes an index out of range because posts is still empy
        self.view.addSubview(self.Activity)
        Activity.startAnimating()
        Activity.hidesWhenStopped = true
//        let spinnerVC = UIViewController.displaySpinner(onView: self.view)
        FeedObserver().getRecentFeed(withId: UserObserver().CURRENT_USER!.uid, start: posts.first?.timeStamp, limit: 10) { [weak self] (results) in
            if let results = results {
                self?.refreshControl.beginRefreshing()
                if results.count > 0 {
                    results.forEach({ [weak self] (result) in
                        print(result)
                        result.0.user = result.1
                        self?.posts.append(result.0)
                    })
                }
                self?.isLoadingPost = false
                self?.refreshControl.endRefreshing()
                self?.tableViewFeed.reloadData()
            }

        }

        FollowObserver().fetchCountFollowing(userId: UserObserver().CURRENT_USER!.uid) { (counter) in
            print ("total following \(counter)")
            self.Activity.stopAnimating()
            //UIViewController.removeSpinner(spinner: spinnerVC)

        }
        configureAdManagerAndLoadAds()
        
    }
    
    //Refreshes the feed when scrolling down
    @objc func refresh() {
        posts.removeAll()
        isLoadingPost = true
        
        if hasSpecificPost {
            backButton.isHidden = false
            
            loadPost(postID: postID, completionHandler: {
                self.isLoadingPost = false
                self.refreshControl.endRefreshing()
                self.tableViewFeed.reloadData()
            })
        } else {
            //backButton.isHidden = true
            loadPosts()
        }
}
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func displayNewPosts(newPosts posts: [PostModel]) {
        guard posts.count > 0 else {
            return
        }
        var indexPaths: [IndexPath] = []
        self.tableViewFeed.beginUpdates()
        for post in 0...posts.count - 1 {
            let indexPath = IndexPath(row: post, section: 0)
            indexPaths.append(indexPath)
            print(indexPath)
        }
        self.tableViewFeed.insertRows(at: indexPaths, with: .none)
        self.tableViewFeed.endUpdates()
    }
   
    //Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            guard let commentVC = segue.destination as? CommentViewController, let post = sender as? String else {
                return
            }
        
            commentVC.postId = post
        }
        if segue.identifier == "profileViewControllerSegue" {
            guard let profileVC = segue.destination as? ProfileViewController, let user = sender as? UserModel else {
                return
            }
            profileVC.user = user
        }
        
        if segue.identifier == "Home_HashTagSegue" {
            guard let hashTagVC = segue.destination as? HashTagViewController, let tag = sender as? String else {
                return
            }
            hashTagVC.tag = tag
        }
    }

}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.isEmpty {
            if Activity.isHidden {
                tableView.setEmptyMessage("Oops... Nothing to see here yet. Why dont you search for people to follow?")
            }
        } else {
            tableView.restore()
        }
        let count = posts.count * 2
        return count + numberOfAds(index: count)
    }
    
    func arrayIndex(from locationIndex: Int) -> Int {
        return locationIndex/2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var index = indexPath.row
        if adsManager != nil {
            if adsCellProvider.isAdCell(at: indexPath, forStride: UInt(adIndex)) {
                // Cell must be an ad
                return adsCellProvider.tableView(tableView, cellForRowAt: indexPath)
            }
        }
        
        if index >= adIndex {
            index -= numberOfAds(index: index)
        }
        
        if isFeedCeel(index: index) {
            guard let cell = tableViewFeed.dequeueReusableCell(withIdentifier: StoryboardHomeFeed.FeedCell, for: indexPath) as? FeedCell, !refreshControl.isRefreshing else {
                    return UITableViewCell()
                }
                index = arrayIndex(from: index)

                cell.selectionStyle = .none
                if !(sortedPosts.count > index) {
                    return UITableViewCell()
                }
                let post = sortedPosts[index]
                //Look into this to find what we shall share
                cell.shareBtnOutlet.tag = index
                cell.shareBtnOutlet.addTarget(self, action: #selector(shareFeed(sender: )), for: .touchUpInside)
                
                cell.post = post
                cell.delegate = self
                cell.layoutMargins = .zero
                return cell
            
        } else {
            // Is an ad
            guard let cell = tableViewFeed.dequeueReusableCell(withIdentifier: StoryboardHomeFeed.FeedHeaderCell) as? FeedHeaderCell, !refreshControl.isRefreshing else {
                return UITableViewCell()
            }
            index = arrayIndex(from: index)

            guard let user = sortedPosts[index].user else {
                return UITableViewCell()
            }

            // Is same user
            if user.id == UserObserver().CURRENT_USER?.uid {
                // Repositioning followBtn so that white line in header cell connects the right side of the view insead of leaving a blank space where the button should be
                cell.followbtnOutlet.leadingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 20).isActive = true
                cell.followbtnOutlet.isHidden = true
            }
            cell.user = user
            
            cell.backgroundColor = UIColor.white
            cell.delegate = self
            updateFollowButton(user: user, button: cell.followbtnOutlet)
            cell.layoutMargins = UIEdgeInsets.zero

            return cell
        }
    }
    
    func presentVideo(url: URL) {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = AVPlayer(url: url)
        
        present(playerViewController, animated: true, completion: {
            playerViewController.player?.play()
        })
    }
    
    func updateFollowButton(user: UserModel, button: UIButton) {
        button.setTitle("Following", for: .normal)
        
        FollowObserver().isFollowing(userId: user.id!) { (isFollowing) in
            if !isFollowing {
                button.setTitle("Follow", for: .normal)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if adsManager != nil {
            if adsCellProvider.isAdCell(at: indexPath, forStride: UInt(adIndex)) {
                return adsCellProvider.tableView(tableView, heightForRowAt: indexPath)
            }
        }
        var index = indexPath.row
        
        if index >= adIndex {
            index -= numberOfAds(index: index)
        }
        
        if isFeedCeel(index: index) {
            return StoryboardHomeFeed.FeedHeight
        } else {
            return StoryboardHomeFeed.FeedHeaderHeight
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            
            guard !isLoadingPost else {
                return
            }
            isLoadingPost = true
            
            guard let lastPostTimestamp = self.sortedPosts.last?.timeStamp else {
                isLoadingPost = false
                return
            }
            FeedObserver().getOldFeed(withId: UserObserver().CURRENT_USER!.uid, start: lastPostTimestamp, limit: 5) { [weak self] (results) in
                if results.count == 0 {
                    return
                }
                for result in results {
                    result.0.user = result.1
                    self?.posts.append(result.0)
                }
                
                self?.isLoadingPost = false
            }
            
        }
    }
    
    @objc func shareFeed(sender: UIButton) {
        
        let post = sortedPosts[sender.tag]
        
        var objectsToshare = [Any]()
        
        let shareMessage = "Hey check out this Playz! "
        objectsToshare.append(shareMessage)
        
        /*
        if let shareImageObj = post.thumbnailUrl {
            objectsToshare.append(shareImageObj)
        }
        
        if let shareVideoObj = post.videoUrl {
            objectsToshare.append(shareVideoObj)
        }
         */
        if let shareVideoId = post.id {
            let urlBeginning = "https://www.playz.io/watch?v="
            objectsToshare.append( urlBeginning + shareVideoId)
        }else{
            if let shareVideoObj = post.videoUrl {
                objectsToshare.append(shareVideoObj)
            }else{
                print("Error : Nothing to share !")
            }
        }
        
        let activityViewController = UIActivityViewController(activityItems: objectsToshare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        present(activityViewController, animated: true, completion: nil)
        
    }
    
    func isFeedCeel(index: Int) -> Bool {
        return index % 2 != 0
    }
    
    func numberOfAds(index: Int) -> Int {
        let numberOfAds = index/adIndex
        return numberOfAds
    }
}

    //Segues for hashtag and comment
extension FeedViewController: FeedCellDelegate, FeedHeaderCellDelegate {
   
    func goToVisitUserVC(user: UserModel) {
        performSegue(withIdentifier: "profileViewControllerSegue", sender: user)
    }
    
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Home_HashTagSegue", sender: tag)
    }
    
    func playTappedVideo(with url: URL) {
        self.presentVideo(url: url)
    }
    
}

extension FeedViewController: FBNativeAdsManagerDelegate {
    func nativeAdsLoaded() {
        tableViewFeed.reloadData()
    }
    
    func nativeAdsFailedToLoadWithError(_ error: Error) {
        print(error)
    }
}

extension FeedViewController: FBNativeAdDelegate {
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        print("clicked ad!")
    }
}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Helvetica Neu", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none

    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
