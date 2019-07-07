//
//  HeadProfileCollectionReusableView.swift
//  Playz
//
//  Created by LangsemWork on 06.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit

//Segue protocol
protocol UserProfileHeaderDelegate: class {
    func updateFollowButton(forUser user: UserModel)
}

protocol UserProfileHeaderEditProfileDelegate: class {
    func goToSettingVC()
}

class UserProfileHeaderCell: UICollectionReusableView {
    
    //Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    //Add this counter ??
    @IBOutlet weak var PlayzCountLbl: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    weak var delegate: UserProfileHeaderDelegate? 
    var delegate2: UserProfileHeaderEditProfileDelegate?
    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
    }
    
    func updateView() {
        self.nameLabel.text = user!.username
        
        //Url for the profileimage
        if let photoUrlString = user!.profilePictureUrl {
            let photoUrl = URL(string: photoUrlString)
            self.profileImage.sd_setImage(with: photoUrl)
        }
        
        MyPostFetcher.fetchCountMyPosts(userId: user!.id!) { (count) in
            self.PlayzCountLbl.text = "\(count)"
        }
        
        FollowObserver.fetchCountFollowing(userId: user!.id!) { (count) in
            self.followingCountLabel.text = "\(count)"
        }
        
        FollowObserver.fetchCountFollowers(userId: user!.id!) { (count) in
            self.followersCountLabel.text = "\(count)"
        }
        
        if user?.id == UserObserver.CURRENT_USER?.uid {
            followButton.setTitle("Edit Profile", for: UIControlState.normal)
            followButton.addTarget(self, action: #selector(self.goToSettingVC), for: UIControlEvents.touchUpInside)
            
        } else {
            updateStateFollowButton()
        }
    }
    
    func clear() {
        self.nameLabel.text = ""
        self.PlayzCountLbl.text = ""
        self.followingCountLabel.text = ""
        self.followersCountLabel.text = ""
    }
    
    @objc func goToSettingVC() {
        delegate2?.goToSettingVC()
    }
    
    func updateStateFollowButton() {
        if user!.isFollowing! {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }
    }
    
    func configureFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followButton.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        followButton.setTitle("Follow", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    
    func configureUnFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        followButton.backgroundColor = UIColor.clear
        followButton.setTitle("Following", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    @objc func followAction() {
        if user!.isFollowing! == false {
            FollowObserver.followAction(withUser: user!.id!)
            configureUnFollowButton()
            user!.isFollowing! = true
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    @objc func unFollowAction() {
        if user!.isFollowing! == true {
            FollowObserver.unFollowAction(withUser: user!.id!)
            configureFollowButton()
            user!.isFollowing! = false
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
}
