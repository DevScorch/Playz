//
//  UserProfileHeaderCell.swift
//  Playz
//
//  Created by LangsemWork on 06.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import FirebaseAuth
//Segue protocol
protocol UserProfileHeaderDelegate: class {
    func updateFollowButton(forUser user: UserModel)
}

protocol UserProfileHeaderEditProfileDelegate: class {
    func goToSettingVC()
}

protocol UserProfileHeaderImagePickerDelegae: class {
    func loadImagePicker(caller: String)
}

protocol UserProfileHeaderDismissDelegate: class {
    func dismissProfileViewController()
}

class UserProfileHeaderCell: UICollectionReusableView {
    
    //Outlets
    
    @IBOutlet weak var editBackgroundImageOutlet: UIButton!
    @IBOutlet weak var backgroundImageProfile: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var PlayzCountLbl: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var backButtonOutlet: UIButton!
    
    weak var delegate: UserProfileHeaderDelegate?
    weak var delegate2: UserProfileHeaderEditProfileDelegate?
    weak var delegate3: UserProfileHeaderImagePickerDelegae?
    weak var delegate4: UserProfileHeaderDismissDelegate?
   
    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    var isDifferentUser: Bool {
        return user?.id != Auth.auth().currentUser?.uid
    }
    
    var isFollowingUser = false
    
    func updateView() {
        
        self.nameLabel.text = user!.username
        self.userNameLbl.text = user!.displayname
        
        //add tap gesture to update background image
        if isDifferentUser {
            editBackgroundImageOutlet.isHidden = true
        } else {
            self.editBackgroundImageOutlet.addTarget(self, action: #selector(editBackgroundImage), for: .touchUpInside)
            backButtonOutlet.isHidden = true
        }
        
//        //Url for the profileimage and backgroundIMage
//        if backgroundImageProfile == nil {
//            backgroundImageProfile.image = UIImage(named: "playz-profile-black")
//        } else {
            if let backgrounUrlString = user?.backgroundImageUrl {
                let background = URL(string: backgrounUrlString)
                self.backgroundImageProfile.sd_setImage(with: background)
            }
//        }
        
        //
        self.profileImage.layer.borderWidth = 1.0
        self.profileImage.layer.masksToBounds = false
        self.profileImage.layer.borderColor = UIColor.white.cgColor
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.clipsToBounds = true
        
        if let photoUrlString = user?.profilePictureUrl {
            let photoUrl = URL(string: photoUrlString)
            self.profileImage.sd_setImage(with: photoUrl)
        }
        
        //add tap gesture to update profile image
        self.profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageHandler)))
        self.profileImage.isUserInteractionEnabled = true
        
        MyPostFetcher().fetchCountMyPosts(userId: user!.id!) { [weak self] (count) in
            self?.PlayzCountLbl.text = "\(count)"
        }
        
        FollowObserver().fetchCountFollowing(userId: user!.id!) { [weak self] (count) in
            self?.followingCountLabel.text = "\(count)"
        }
        
        FollowObserver().fetchCountFollowers(userId: user!.id!) { [weak self] (count) in
            self?.followersCountLabel.text = "\(count)"
        }
        
        FollowObserver().isFollowing(userId: user!.id!, completed: { [unowned self] (isFollowing) in
            self.isFollowingUser = isFollowing
            if self.isDifferentUser {
                self.updateStateFollowButton()
            } else {
                self.followButton.setTitle("Edit", for: UIControlState.normal)
                self.followButton.addTarget(self, action: #selector(self.goToSettingVC), for: UIControlEvents.touchUpInside)
            }
        })
    }
    
    @objc func profileImageHandler() {
        delegate3?.loadImagePicker(caller: "profileImg")
    }
    
    @objc func goToSettingVC() {
        delegate2?.goToSettingVC()
    }
    
    func updateStateFollowButton() {
        if isFollowingUser {
            configureFollowingButton()
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
        followButton.setTitle("  Follow  ", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    
    func configureFollowingButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.white.cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(.white, for: UIControlState.normal)
        followButton.backgroundColor = .clear
        followButton.setTitle("  Following  ", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    @objc func followAction() {
        guard let user = user else {
            return
        }
        FollowObserver().followAction(withUser: user.id!)
        configureFollowingButton()
        delegate?.updateFollowButton(forUser: user)
    }
    
    @objc func unFollowAction() {
        FollowObserver().unFollowAction(withUser: user!.id!)
        configureFollowButton()
        delegate?.updateFollowButton(forUser: user!)
    }
    
    //@CRAZY-DEV Update Background Image IBAction
    @objc func editBackgroundImage() {
        
        delegate3?.loadImagePicker(caller: "backgroundImg")
    }
    
    func updateBackgroundImage(image: UIImage) {
        self.backgroundImageProfile.image = image
        
        //update server
        let imgData: Data = UIImagePNGRepresentation(image)!
        AuthService.updateUserProfile(type: "Background", imageData: imgData, onSuccess: {
            
        }) { (error) in
            print (error!)
        }
    }
    
    func updateProfileImage(image: UIImage) {
        self.profileImage.image = image
        
        //update server
        let imgData: Data = UIImagePNGRepresentation(image)!
        AuthService.updateUserProfile(type: "Profile", imageData: imgData, onSuccess: { 
            
        }) { (error) in
            print (error!)
        }
        
    }
    
    @IBAction func dismissProfileViewController() {
        delegate4?.dismissProfileViewController()
    }
}
