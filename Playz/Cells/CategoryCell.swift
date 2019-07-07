//
//  CategoryCell.swift
//  Playz
//
//  Created by Johan on 13-06-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import Foundation

protocol VisitCategoryTableViewDelegate: class {
    func goToCategoryViewController(category: String)
}

class CategoryCell: UITableViewCell {

    // DEVSCORCH: Variables
    
    weak var delegate: VisitCategoryTableViewDelegate?
    
    var category: CategoryModel? {
        didSet {
            updateView()
        }
    }
    
    // DEVSCORCH: IBOutlets
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryThumbnal: UIImageView!
    @IBOutlet weak var videoAmountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.categoryLabel_TouchUpInside))
        categoryLabel.addGestureRecognizer(tapGesture)
        categoryLabel.isUserInteractionEnabled = true
    }
    
    // DEVSCORCH: Functions
    
    func updateView() {
        categoryLabel.text = category?.title
        if let categoryThumbnailString = category?.thumbnailUrl {
            let thumbnailurl = URL(string: categoryThumbnailString)
            categoryThumbnal.sd_setImage(with: thumbnailurl, placeholderImage: UIImage(named: "placeholderImg"))
        }
        let nbvideos = category?.videos
        if let unwrapped = nbvideos {
            videoAmountLabel.text = String(unwrapped)
        } else {
            videoAmountLabel.text = ""
        }
        
    }
    
    // DEVSCORCH: @Object functions
    
    @objc func categoryLabel_TouchUpInside() {
        if let category = category?.title {
            delegate?.goToCategoryViewController(category: category)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
