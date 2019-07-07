//
//  HelperService.swift
//  Playz
//
//  Created by Johan on 01-05-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase

class HelperService {
    
    static func uploadDataToServer(data: Data, videoUrl: URL? = nil, ratio: CGFloat, caption: String, categories: [String], onSuccess: @escaping () -> Void) {
        if let videoUrl = videoUrl {
            self.uploadVideoToFirebaseStorage(videoUrl: videoUrl, onSuccess: { (videoUrl) in
                uploadImageToFirebaseStorage(data: data, onSuccess: { (thumbnailImageUrl) in
                    sendDataToDatabase(photoUrl: thumbnailImageUrl, videoUrl: videoUrl, ratio: ratio, caption: caption, categories: categories, onSuccess: onSuccess)
                })
            })
        } else {
            uploadImageToFirebaseStorage(data: data) { (photoUrl) in
                self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, caption: caption, categories: categories, onSuccess: onSuccess)
            }
        }
    }
    
    static func uploadVideoToFirebaseStorage(videoUrl: URL, onSuccess: @escaping (_ videoUrl: String) -> Void) {
        let videoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: DatabaseReferences.ds.REF_STORAGE_ROOT).child("posts").child(videoIdString)
        storageRef.putFile(from: videoUrl, metadata: nil) { (_, error) in
            if error != nil {
                print(error!)
                return
            }
            storageRef.downloadURL { (url, _) in
                guard let videoUrl = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                onSuccess(videoUrl.absoluteString)
                
            }
        }
    }
    
    static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageUrl: String) -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: DatabaseReferences.ds.REF_STORAGE_ROOT).child("posts").child(photoIdString)
        storageRef.putData(data, metadata: nil) { (_, error) in
            if error != nil {
                print(error!)
                return
            }
            storageRef.downloadURL { (url, _) in
                guard let photoUrl = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                onSuccess(photoUrl.absoluteString)
            }
            
        }
    }
    
    static func sendDataToDatabase(photoUrl: String, videoUrl: String? = nil, ratio: CGFloat, caption: String, categories: [String], onSuccess: @escaping () -> Void) {
        let newPostId = PostObserver().REF_POSTS.childByAutoId().key
        let newPostReference = PostObserver().REF_POSTS.child(newPostId)
        
        guard let currentUser = UserObserver().CURRENT_USER else {
            return
        }
        
        let currentUserId = currentUser.uid
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHashTagRef = HashTagObserver().REF_HASHTAG.child(word.lowercased())
                newHashTagRef.updateChildValues([newPostId: true])
            }
        }
        
        for category in categories {
            CategoryObserver().REF_CATEGORY.child(category.lowercased()).child("posts").child(newPostId).setValue(true)
        }
        
        let timestamp = (Int(Date().timeIntervalSince1970))
        
        var dict = ["uid": currentUserId, "photo_url": photoUrl, "caption": caption, "like_count": 0, "ratio": ratio, "time_stamp": timestamp] as [String: Any]
        if let videoUrl = videoUrl {
            dict["video_url"] = videoUrl
        }
        
        newPostReference.setValue(dict, withCompletionBlock: {
            (error, _) in
            if error != nil {
                print(error!)
                return
            }
            
            FeedObserver().REF_FEED.child(UserObserver().CURRENT_USER!.uid).child(newPostId)
                .setValue(["time_stamp": timestamp])
            FollowObserver().REF_FOLLOWERS.child(UserObserver().CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
                snapshot in
                if let arraySnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    arraySnapshot.forEach({ (child) in
                        print(child.key)
                        FeedObserver().REF_FEED.child(child.key).child(newPostId)
                            .setValue(["time_stamp": timestamp])
                        let newNotificationId = NotificationObserver().REF_NOTIFICATION.child(child.key).childByAutoId().key
                        let newNotificationReference = NotificationObserver().REF_NOTIFICATION.child(child.key).child(newNotificationId)
                        newNotificationReference.setValue(["from": UserObserver().CURRENT_USER!.uid, "type": "feed", "object_id": newPostId, "time_stamp": timestamp])
                    })
                }
            })
            let myPostRef = MyPostFetcher().REF_MYPOSTS.child(currentUserId).child(newPostId)
            myPostRef.setValue(["time_stamp": timestamp], withCompletionBlock: { (error, _) in
                if error != nil {
                    print(error!)
                    return
                }
            })
            
            onSuccess()
        })
    }
}
