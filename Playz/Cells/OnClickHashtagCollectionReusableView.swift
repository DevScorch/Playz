//
//  OnClickHashtagCollectionReusableView.swift
//  Playz
//
//  Created by LangsemWork on 05.06.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit

class OnClickHashtagCollectionReusableView: UICollectionReusableView {
    
    //Outlets
    @IBOutlet weak var onclickBackBtnOutlet: UIButton!
    
    @IBOutlet weak var hashtagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func updateHashtag() {
        //Fetch the hashtag from search to display it on top
    }
}
