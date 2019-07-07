//
//  NotificationTableViewCell.swift
//  Playz
//
//  Created by LangsemWork on 06.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import SDWebImage
//Segue protocol
protocol NotificationTableViewCellDelegate: class {
    func goToDetailVC(postId: String)
    func goToProfileVC(user: UserModel)
    func goToCommentVC(postId: String)
}

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    weak var delegate: NotificationTableViewCellDelegate?
    
    var notification: NotificationModel? {
        didSet {
            updateView()
        }
    }
    
    var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    func updateView() {
        switch notification!.type {
        case "like"?:
            descriptionLabel.text = " liked your post"
            
            let objectId = notification!.objectId
            //The same as the comment above
            PostObserver().observePost(withId: objectId!, completion: { [weak self]  (post) in
                if let videoUrlString = post.thumbnailUrl {
                    let videoUrl = URL(string: videoUrlString)
                   // self?.photo.sd_setImage(with: videoUrl)
                }
            })
        case "comment"?:
            descriptionLabel.text = " left a comment on your post"
            
            let objectId = notification!.objectId
            //Same as the comment above only display thumbnail image of the video
            PostObserver().observePost(withId: objectId!, completion: { [weak self]  (post) in
                if let videoUrlString = post.videoUrl {
                    let videoUrl = URL(string: videoUrlString)
                   // self?.photo.sd_setImage(with: videoUrl, placeholderImage: UIImage(named: "placeholderImg"))
                }
            })
            
        case "follow"?:
            descriptionLabel.text = " tarted following you"
            
            let objectId = notification!.objectId
            //Also same as above
            PostObserver().observePost(withId: objectId!, completion: { [weak self] (post) in
                if let videoUrlString = post.videoUrl {
                    let videoUrl = URL(string: videoUrlString)
                   // self?.photo.sd_setImage(with: videoUrl, placeholderImage: UIImage(named: "placeholderImg"))

                }
            })
            
        case "feed"?:
            descriptionLabel.text = " ploaded a new Video"
            
            let objectId = notification!.objectId
            //Same as the comment above only display thumbnail image of the video
            PostObserver().observePost(withId: objectId!, completion: { [weak self]  (post) in
                if let videoUrlString = post.videoUrl {
                    let videoUrl = URL(string: videoUrlString)
                   // self?.photo.sd_setImage(with: videoUrl, placeholderImage: UIImage(named: "placeholderImg"))
                }
            })
            
        default:
            print("t")
        }
        
        if let timestamp = notification?.timeStamp {
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
                timeText = "\(diff.second!)s"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = "\(diff.minute!)m"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = "\(diff.hour!)h"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = "\(diff.day!)d"
            }
            if diff.weekOfMonth! > 0 {
                timeText = "\(diff.weekOfMonth!)w"
            }
            
            timeLabel.text = timeText
        } else {
            timeLabel.text = "N/A"
        }
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.cell_TouchUpInside))
        addGestureRecognizer(tapGestureForPhoto)
        isUserInteractionEnabled = true
    }
    
    @objc func cell_TouchUpInside() {
        if let id = notification?.objectId {
            if notification!.type == "follow" {
                delegate?.goToProfileVC(user: user!)
            } else if notification!.type == "comment" {
                delegate?.goToCommentVC(postId: id)
            } else {
                delegate?.goToDetailVC(postId: id)
            }
            
        }
    }
    
    func setupUserInfo() {
        nameLabel.text = user?.username
        //URl of the user
        if let photoUrlString = user?.profilePictureUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
