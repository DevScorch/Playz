//
//  HashTagModel.swift
//  Playz
//
//  Created by Johan on 13-06-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import Firebase

class HashtagModel: IDAble {
    
    // DEVSCORCH: Private Variables
    
    private var _title: String?
    private var _hashTagThumbnail: UIImageView?
    
    // DEVSCORCH: Initialisers
    
    var id: String? {
        get {
            return _title
        }
        set { }
    }
    
    var title: String {
        get {
            return _title!
        } set {
            _title = title
        }
    }
    
    var hashTagThumbnail: UIImageView {
        get {
            return _hashTagThumbnail!
        } set {
            _hashTagThumbnail = hashTagThumbnail
        }
    }
}

extension HashtagModel {
    static func transformHashTag(title: String, dict: [String: Any]) -> HashtagModel {
        let hashTag = HashtagModel()
        hashTag._title = title
//        hashTag._hashTagThumbnail = dict["hash_tag_thumbnail"] as? UIImageView
        return hashTag
    }
}
