//
//  PostModel.swift
//  Playz
//
//  Created by Johan on 28-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import FirebaseAuth

class PostModel: IDAble {
    
    // DEVSCORCH: Private Variables
    
    private var _caption: String?
    private var _thumbnailUrl: String?
    private var _uid: String?
    private var _id: String?
    private var _likeCount: Int?
    private var _likes: [String: Any]?
    private var _isLiked: Bool?
    private var _ratio: CGFloat?
    private var _videoUrl: String?
    private var _timeStamp: Int?
    private var _categories: String?
    private var _commentCount: Int?
    var user: UserModel?
    
      //Newly added dont know if we need this
    private var _viewCount: Int?
    
    // Initializers

    var categories: String? {
        get {
            return _categories
        } set {
            _categories = categories
        }
    }

    var caption: String? {
        get { return _caption
        } set {
            _caption = caption
        }
    }

      //Newly added dont know if we need this
    var viewCount: Int? {
        get {
            return _viewCount
        } set {
            _viewCount = viewCount
        }
    }

    var thumbnailUrl: String? {
        get { return _thumbnailUrl
        } set {
            _thumbnailUrl = thumbnailUrl
        }
    }

    var uid: String? {
        get { return _uid
        } set {
            _uid = uid
        }
    }

    var id: String? {
        get { return _id
        } set {
            _id = id
        }
    }

    var likeCount: Int? {
        get { return _likeCount
        } set {
            _likeCount = likeCount
        }
    }

    var likes: [String: Any]? {
        get { return _likes
        } set {
            _likes = likes
        }
    }

    var isLiked: Bool? {
        if let currentUserId = Auth.auth().currentUser?.uid {
            if let likes = _likes {
                return likes.keys.contains(currentUserId)
            }
        }
        return false
    }

    var videoUrl: String? {
        get { return _videoUrl
        } set {
            _videoUrl = videoUrl
        }
    }

    var timeStamp: Int? {
        get { return _timeStamp
        } set {
            _timeStamp = timeStamp
        }
    }

    var ratio: CGFloat? {
        get {
            return _ratio
        } set {
            _ratio = ratio
        }
    }
    
    var commentCount: Int? {
        return _commentCount
    }
    
    init() {

    }
    
}

extension PostModel {
    static func transformPostVideo(dict: [String: Any], key: String) -> PostModel {
        let post = PostModel()
        post._id = key
        post._caption = dict["caption"] as? String
        post._thumbnailUrl = dict["photo_url"] as? String
        post._videoUrl = dict["video_url"] as? String
        post._uid = dict["uid"] as? String
        post._likeCount = dict["like_count"] as? Int ?? 0
        post._likes = dict["likes"] as? [String: Any]
        post._ratio = dict["ratio"] as? CGFloat
        post._timeStamp = dict["time_stamp"] as? Int
     //Newly added dont know if we need this
        post._viewCount = dict["view_count"] as? Int
        post._categories = dict["categories"] as? String
        post._commentCount = dict["comment_count"] as? Int ?? 0
        
        return post
    }
}
