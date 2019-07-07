//
//  FollowObserver.swift
//  Playz
//
//  Created by Johan on 27-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import Firebase

// DEVSCORCH: Variables

class FollowObserver {
    
    var REF_FOLLOWERS = DatabaseReferences.ds.REF_FOLLOWERS
    var REF_FOLLOWING = DatabaseReferences.ds.REF_FOLLOW
    
    func followAction(withUser id: String) {
        MyPostFetcher().REF_MYPOSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    if let value = dict[key] as? [String: Any] {
                        if let timestampPost = value["time_stamp"] as? Int {
                        DatabaseReferences.ds.REF_FEED.child(UserObserver().CURRENT_USER!.uid).child(key).setValue(["time_stamp": timestampPost])
                        }
                    }
                }
            }
        })
        REF_FOLLOWERS.child(id).child(UserObserver().CURRENT_USER!.uid).setValue(true)
        REF_FOLLOWING.child(UserObserver().CURRENT_USER!.uid).child(id).setValue(true)
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        let newNotificationReference = NotificationObserver().REF_NOTIFICATION.child(id).child(UserObserver().CURRENT_USER!.uid)
        
        newNotificationReference.setValue(["from": UserObserver().CURRENT_USER!.uid, "object_id": UserObserver().CURRENT_USER!.uid, "type": "follow", "time_stamp": timestamp])
        
    }
    
    func followAction(withCategory category: String) {
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))

        CategoryObserver().fetchPosts(withTag: category) { (postID) in
            DatabaseReferences.ds.REF_FEED.child(UserObserver().CURRENT_USER!.uid).child(postID).setValue(["time_stamp": timestamp])
        }
    }
    
    func unFollowAction(withUser id: String) {
        
        MyPostFetcher().REF_MYPOSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    DatabaseReferences.ds.REF_FEED.child(UserObserver().CURRENT_USER!.uid).child(key).removeValue()
                }
            }
        })
        
        REF_FOLLOWERS.child(id).child(UserObserver().CURRENT_USER!.uid).setValue(NSNull())
        REF_FOLLOWING.child(UserObserver().CURRENT_USER!.uid).child(id).setValue(NSNull())
        
        let newNotificationReference = NotificationObserver().REF_NOTIFICATION.child(id).child(UserObserver().CURRENT_USER!.uid)
        newNotificationReference.setValue(NSNull())
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        REF_FOLLOWERS.child(userId).child(UserObserver().CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            completed(!(snapshot.value is NSNull))
        })
    }
    
    func fetchCountFollowing(userId: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWING.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
        
    }
    
    func fetchCountFollowers(userId: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWERS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
        
    }
}
