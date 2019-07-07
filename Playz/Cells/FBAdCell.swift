//
//  FBAdCell.swift
//  Playz
//
//  Created by Joriah Lasater on 9/5/18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import FBAudienceNetwork
class FBAdCell: UITableViewCell {
    
    var ad: FBNativeAd?
    
    lazy var fbView: FBNativeAdView = {
        guard let ad = ad else {
            return FBNativeAdView()
        }
        
        let view = FBNativeAdView(nativeAd: ad, with: FBNativeAdViewType.init(rawValue: Int(self.frame.height/5))!)
        return view
    }()
    
    func setupView() {
        addSubview(fbView)
    }
}
