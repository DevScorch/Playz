//
//  CommentCell.swift
//  Playz
//
//  Created by LangsemWork on 01.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import KILabel

//Segue protocol
protocol CommentCellDelegate: class {
    func goToProfileUserVC(userId: String)
    func goToHashTag(tag: String)
}

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: KILabel!
    
    weak var delegate: CommentCellDelegate?
    
    var comment: CommentModel? {
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
        commentLabel.text = comment?.commentText
    }
    
    @objc func tapHashtagDetected() {
        
    }
    
    func setupUserInfo() {
        nameLabel.text = user?.username
        //Make userbase for the profile image on users
        if let photoUrlString = user?.profilePictureUrl {
            let photoUrl = URL(string: photoUrlString)
            
            self.profileImageView.layer.borderWidth = 1.0
            self.profileImageView.layer.masksToBounds = false
            self.profileImageView.layer.borderColor = UIColor.white.cgColor
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
            self.profileImageView.clipsToBounds = true
        
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = ""
        commentLabel.text = ""
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
    }
    
    @objc func nameLabel_TouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: "placeholderImg")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
