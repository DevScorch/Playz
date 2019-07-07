//
//  CommentModel.swift
//  Playz
//
//  Created by Johan on 28-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation

class CommentModel {
    
    // Private variables
    private var _commentUID: String?
    private var _commentText: String?
    private var _uid: String?
    
    // Initializers
    
    var commentText: String? {
        get {
            return _commentText
        } set {
            _commentText = commentText
        }
    }
    
    var uid: String? {
        get {
            return _uid
        } set {
            _uid = uid
        }
    }
    
    var commentUID: String? {
        get {
            return _commentUID
        }
        set {
            _commentUID = commentUID
        }
    }
    
    init() {}
    
}

extension CommentModel {
    
    static func transformComment(dict: [String: Any], key: String) -> CommentModel {
        let comment = CommentModel()
        comment._commentText = dict["comment_text"] as? String
        comment._uid = dict["uid"] as? String
        comment._commentUID = key
        return comment
    }
}
