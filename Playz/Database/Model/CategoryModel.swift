//
//  CategorieModel.swift
//  Playz
//
//  Created by Johan on 13-06-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import Firebase

class CategoryModel: IDAble {
    
    // DEVSCORCH: Private variables
    
    private var _title: String?
    private var _categoryThumbnail: UIImageView?
    private var _videos: Int?
    private var _thumbnailURL: String?
    
    // DEVSCORCH: initializers
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
            _title = newValue
        }
    }
    
    var categoryThumbnail: UIImageView {
        get {
            return UIImageView()
            //            return _categoryThumbnail!
        }
        set {
            _categoryThumbnail = newValue
        }
    }
    
    var videos: Int? {
        get {
            return _videos
        } set {
            _videos = newValue
        }
    }
    
    var thumbnailUrl: String {
        get {
            return "thumbnail URL"
            //            return _thumbnailURL!
        } set {
            _thumbnailURL = newValue
        }
    }
}

extension CategoryModel {
    static func transformCategory(title: String, dict: [String: Any]) -> CategoryModel {
        let category = CategoryModel()
        category._videos  = 0
        category._title = title
        category._categoryThumbnail = dict["thumb_nail"] as? UIImageView
        category._videos = dict["videos"] as? Int
        category._thumbnailURL = dict["category_thumb_nail_url"] as? String
        return category
    }
}
