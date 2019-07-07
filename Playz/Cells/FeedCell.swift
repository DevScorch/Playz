//
//  FeedCell.swift
//  Playz
//
//  Created by LangsemWork on 29.04.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import KILabel
import Firebase
import AVKit
//Segue protocol
protocol FeedCellDelegate: class {
    func goToVisitUserVC(user: UserModel)
    func goToCommentVC(postId: String)
    func goToHashTag(tag: String)
    func playTappedVideo(with: URL)
}

class FeedCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var viewsCounter: UILabel!
    @IBOutlet weak var commentImgOutlet: UIImageView!
    @IBOutlet weak var likeImgOutlet: UIImageView!
    @IBOutlet weak var videoContainerImgOutlet: UIImageView!
    @IBOutlet weak var captionLblOutlet: KILabel!
    @IBOutlet weak var shareBtnOutlet: UIButton!
    
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var timeLblOutlet: UILabel!
    @IBOutlet weak var heightConstraintVideo: NSLayoutConstraint!

    var clickCounter = 0
    weak var delegate: FeedCellDelegate?
    var shouldAddViewCount: Bool = true
    
    private weak var player: AVPlayer?
    private weak var playerLayer: AVPlayerLayer?
    
    var post: PostModel? {
        didSet {
            updateView()
        }
    }
   
    private func updateView() {
       captionLblOutlet.text = post?.caption
        if let vCount = post?.viewCount {
            self.viewsCounter.text = "\(vCount) Views"
        } else {
            self.viewsCounter.text = "\(0) Views"
        }
        
        captionLblOutlet.hashtagLinkTapHandler = { [weak self] label, string, range in
            let tag = String(string.dropFirst())
            self?.delegate?.goToHashTag(tag: tag)
        }
        
        captionLblOutlet.userHandleLinkTapHandler = { label, string, range in
            print(string)
            let mention = String(string.dropFirst())
            print(mention)
            UserObserver().observerUserByUsername(username: mention.lowercased(), completion: { [weak self] (user) in
                self?.delegate?.goToVisitUserVC(user: user)
            })
        }

        if let ratio = post?.ratio {
            heightConstraintVideo.constant = UIScreen.main.bounds.width / ratio
            layoutIfNeeded()
        }

            videoContainerImgOutlet.sd_setImage(with: URL(string: post!.thumbnailUrl!))

            self.contentView.tag = self.shareBtnOutlet.tag
            self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoTaped)))
            self.contentView.isUserInteractionEnabled = true
        
        if let timestamp = post?.timeStamp {
            print(timestamp)
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            if diff.second! <= 0 {
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = (diff.second == 1) ? "\(diff.second!) second ago" : "\(diff.second!) seconds ago"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = (diff.minute == 1) ? "\(diff.minute!) minute ago" : "\(diff.minute!) minutes ago"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = (diff.hour == 1) ? "\(diff.hour!) hour ago" : "\(diff.hour!) hours ago"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = (diff.day == 1) ? "\(diff.day!) day ago" : "\(diff.day!) days ago"
            }
            if diff.weekOfMonth! > 0 {
                timeText = (diff.weekOfMonth == 1) ? "\(diff.weekOfMonth!) week ago" : "\(diff.weekOfMonth!) weeks ago"
            }
            
            timeLblOutlet.text = timeText
        }
        if let likeCount = post?.likeCount {
            likesLabel.text = "\(likeCount)"
        }
        
        if let commentCount = post?.commentCount {
            commentsLabel.text = "\(commentCount)"
        }
        
        self.updateLike()
    }
    
    @objc func videoTaped () {
        guard let post = post, let videoPath = post.videoUrl, let videoURL = URL(string: videoPath) else {
            return
        }
        delegate?.playTappedVideo(with: videoURL)

        //add view counter for post
        PostObserver().incrementViewCount(postId: (post.id)!, onSucess: { [weak self] _ in
            //update view
            if let vCount = post.viewCount {
                self?.viewsCounter.text = "\(vCount) Views"
            }
            }, onError: { (error) in
                print ("\(String(describing: error?.debugDescription))")
        })
        
    }

    func updateLike() {
        guard let post = post else {
            return
        }
        
        let imageName = post.isLiked ?? false ? "heart-gold" : "heart-white"
        likeImgOutlet.image = UIImage(named: imageName)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        captionLblOutlet.text = ""
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        commentImgOutlet.addGestureRecognizer(tapGesture)
        commentImgOutlet.isUserInteractionEnabled = true
        
        let tapGestureForLikeImageView = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TouchUpInside))
        likeImgOutlet.addGestureRecognizer(tapGestureForLikeImageView)
        likeImgOutlet.isUserInteractionEnabled = true
    }
    
    @objc func likeImageView_TouchUpInside() {
        let post = self.post!
        
        let userUID = UserObserver().CURRENT_USER!.uid
        let id = post.id!
        let uid = post.uid!
        
        let newNotificationReference = NotificationObserver().REF_NOTIFICATION.child(uid).child("\(String(describing: id))-\(userUID)")
        
        if !post.isLiked! {
            PostObserver().incrementLikes(postId: id, onSucess: { [weak self] newPost in
                let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                newNotificationReference.setValue(["from": userUID, "object_id": id, "type": "like", "time_stamp": timestamp])
                    self?.post = newPost
            }) { (_) in }
        } else {
            PostObserver().decrementLikes(postId: id, onSucess: { [weak self] newPost in
                newNotificationReference.removeValue()
                    self?.post = newPost
            }) { (_) in }
        }
    }
    
    @objc func commentImageView_TouchUpInside() {
        print("commentImageView_TouchUpInside")
        if let id = post?.id {
                delegate?.goToCommentVC(postId: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLblOutlet.text = ""
        player = nil
        playerLayer = nil 
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
