//
//  FeedHeaderCell.swift
//  Playz
//
//  Created by LangsemWork on 29.04.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import SDWebImage

//Segue protocol
protocol FeedHeaderCellDelegate: class {
    func goToVisitUserVC(user: UserModel)
}

//A nice header like instagram has, so it follows along as you scroll
class FeedHeaderCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var followbtnOutlet: UIButton!
    
    weak var delegate: FeedHeaderCellDelegate?
    
    weak var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    func setupUserInfo() {
        usernameLbl.text = user?.username
        if let photoUrlString = user?.profilePictureUrl {
            let photoUrl = URL(string: photoUrlString)
            userProfileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "playz-profile-black"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
        let tapGestureForNameLbl = UITapGestureRecognizer(target: self, action: #selector(self.nameLblPressed))
        usernameLbl.addGestureRecognizer(tapGestureForNameLbl)
        usernameLbl.isUserInteractionEnabled = true
        
        let tapGestureForUserImage = UITapGestureRecognizer(target: self, action: #selector(self.userImagePressed))
        userProfileImage.addGestureRecognizer(tapGestureForUserImage)
        userProfileImage.isUserInteractionEnabled = true
        followbtnOutlet.isHidden = true
    }

    func canVisitUser() -> Bool {
        if let user = user {
             return user.id != UserObserver().CURRENT_USER?.uid
        }
        return false
    }
    
    @objc func nameLblPressed() {
        if canVisitUser() {
            delegate?.goToVisitUserVC(user: user!)
        }
    }
    
    @objc func userImagePressed() {
        if canVisitUser() {
            delegate?.goToVisitUserVC(user: user!)
        }
    }
    
    func updateUI () {
        
        usernameLbl.text = ""
        
       //Round circle of userimage
        userProfileImage.layer.cornerRadius = userProfileImage.bounds.width / 2.0
        userProfileImage.layer.masksToBounds = true
         //Nice round border around the follow button
        followbtnOutlet.layer.borderWidth = 1.0
        followbtnOutlet.layer.cornerRadius = 2.0
        followbtnOutlet.layer.borderColor = followbtnOutlet.tintColor.cgColor
        followbtnOutlet.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
