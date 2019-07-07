//
//  OnClickCategoryHeaderCollectionReusableView.swift
//  Playz
//
//  Created by LangsemWork on 05.06.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit

class OnClickCategoryHeaderCollectionReusableView: UICollectionReusableView {
    
    //Outlet
    @IBOutlet weak var onclickCategoryHeaderLabel: UILabel!
    
    @IBOutlet weak var onClickCategoryHeaderBackBtn: UIButton!
    
    //var categorie: PostModel? {
    var categorie: String? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        self.onclickCategoryHeaderLabel.text = categorie
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateCategory() {
        //Fetch the category from search to display it on top
        self.onclickCategoryHeaderLabel.text = ""
        
    }
}
