//
//  PostsObserver.swift
//  Playz
//
//  Created by Johan on 27-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PostObserver {
    
    var REF_POSTS = DatabaseReferences.ds.REF_POSTS
    
    func observePosts(completion: @escaping (PostModel) -> Void) {
        REF_POSTS.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let newPost = PostModel.transformPostVideo(dict: dict, key: snapshot.key)
                completion(newPost)
            }
        }
    }
    
    func observePost(withId id: String, completion: @escaping (PostModel) -> Void) {
        REF_POSTS.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = PostModel.transformPostVideo(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
    
    func observeLikeCount(withPostId id: String, completion: @escaping (Int, UInt) -> Void) {
        var likeHandler: UInt!
        likeHandler = REF_POSTS.child(id).observe(.childChanged, with: {
            snapshot in
            if let value = snapshot.value as? Int {
                completion(value, likeHandler)
            }
        })
    }
    
    func observeTopPosts(completion: @escaping (PostModel) -> Void) {
        //Arrange top post
        REF_POSTS.queryOrdered(byChild: "like_count").observeSingleEvent(of: .value, with: {
            snapshot in
            if let arraySnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                arraySnapshot.reversed().forEach({ (child) in
                    if let dict = child.value as? [String: Any] {
                        let post = PostModel.transformPostVideo(dict: dict, key: child.key)
                        completion(post)
                    }
                })
            }
            
        })
    }
    
    func removeObserveLikeCount(id: String, likeHandler: UInt) {
        DatabaseReferences.ds.REF_POSTS.child(id).removeObserver(withHandle: likeHandler)
    }
    
    func incrementLikes(postId: String, onSucess: @escaping (PostModel) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = DatabaseReferences.ds.REF_POSTS.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String: Any], let uid = UserObserver().CURRENT_USER?.uid {
                var likes: [String: Bool]
                likes = post["likes"] as? [String: Bool] ?? [:]
                var likeCount = post["like_count"] as? Int ?? 0
                likeCount += 1
                likes[uid] = true
                
                post["like_count"] = likeCount
                post["likes"] = likes 
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, _, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = PostModel.transformPostVideo(dict: dict, key: snapshot!.key)
                onSucess(post)
            }
        }
    }
    
    func decrementLikes(postId: String, onSucess: @escaping (PostModel) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = DatabaseReferences.ds.REF_POSTS.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String: Any], let uid = UserObserver().CURRENT_USER?.uid {
                var likes: [String: Bool]
                likes = post["likes"] as? [String: Bool] ?? [:]
                var likeCount = post["like_count"] as? Int ?? 0
                likeCount -= 1
                likes.removeValue(forKey: uid)
                post["like_count"] = likeCount
                post["likes"] = likes
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
            
        }) { (error, _, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = PostModel.transformPostVideo(dict: dict, key: snapshot!.key)
                onSucess(post)
            }
        }
    }
    
    func incrementViewCount(postId: String, onSucess: @escaping (PostModel) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = DatabaseReferences.ds.REF_POSTS.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String: AnyObject] {
                var viewCount = post["view_count"] as? Int ?? 0
                viewCount += 1
                post["view_count"] = viewCount as AnyObject?
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, _, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = PostModel.transformPostVideo(dict: dict, key: snapshot!.key)
                onSucess(post)
            }
        }
    }
}
