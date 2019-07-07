//
//  GameCategoriesCollectionCell.swift
//  Playz
//
//  Created by M. Arshad Mehmood on 13/06/2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit

protocol GameCategoriesCollectionCellDelegae: class {
    func selectedGameCategory(category: String, shouldAdd: Bool)
}

class GameCategoriesCollectionCell: UICollectionViewCell {
    
    weak var delegate: GameCategoriesCollectionCellDelegae?
    
    lazy var categoryBtn: UIButton = {
        let button = UIButton(type: .system)
        button.frame = frame
        button.setTitle("button", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(selectedCategory), for: .touchUpInside)
        return button
    }()
    
    var category: String? {
        didSet {
            categoryBtn.setTitle(category, for: .normal)
            categoryBtn.setTitle(category, for: .selected)
            categoryBtn.isSelected = false
        }
    }
    
    override func awakeFromNib() {
        addSubview(categoryBtn)
        layer.cornerRadius = 5
        clipsToBounds = true
    }
    
    @objc func selectedCategory() {
        delegate?.selectedGameCategory(category: category!, shouldAdd: categoryBtn.isSelected)
        categoryBtn.isSelected = !categoryBtn.isSelected
    }
}
