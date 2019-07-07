//
//  HashTagCell.swift
//  Playz
//
//  Created by Johan on 13-06-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit

protocol VisitHashTagTableViewDelegate: class {
    func goToHashTagViewController(hashtag: String)
}

class HashTagCell: UITableViewCell {

    // DEVSCORCH: Variables
    
    // DEVSCORCH: IBOutlets
    var hashtag: HashtagModel? {
        didSet {
            updateView()
        }
    }
    
    weak var delegate: VisitHashTagTableViewDelegate?
    
    @IBOutlet weak var hashTagImage: UIImageView!
    @IBOutlet weak var hashTagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hashTagLabel_TouchUpInside))
        hashTagLabel.addGestureRecognizer(tapGesture)
        hashTagLabel.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateView() {
        if let title = hashtag?.title {
            hashTagLabel.text = "#\(title)"
        }
        
        // Jaaster: TODO: set hashTagImage to thumbnail of hashtag
    }
    
    @objc func hashTagLabel_TouchUpInside() {
        if let hashtag = hashtag?.title {
            delegate?.goToHashTagViewController(hashtag: hashtag)
        }
    }
}
