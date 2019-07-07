//
//  FeedObserver.swift
//  Playz
//
//  Created by Johan on 27-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FeedObserver {
    
    var REF_FEED = DatabaseReferences.ds.REF_FEED
    
    func observeFeed(withId id: String, completion: @escaping (PostModel) -> Void) {
        REF_FEED.child(id).queryOrdered(byChild: "time_stamp").observe(.childAdded, with: {
            snapshot in
            let key = snapshot.key
            PostObserver().observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    func getRecentFeed(withId id: String, start timestamp: Int? = nil, limit: UInt, completionHandler: @escaping ([(PostModel, UserModel)]?) -> Void) {
        completionHandler(nil)
        var feedQuery = REF_FEED.child(id).queryOrdered(byChild: "time_stamp")
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            feedQuery = feedQuery.queryStarting(atValue: latestPostTimestamp + 1, childKey: "time_stamp").queryLimited(toLast: limit)
        } else {
            feedQuery = feedQuery.queryLimited(toLast: limit)
        }
        
        // Call Firebase API to retrieve the latest records
        feedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            let items = snapshot.children.allObjects
            let myGroup = DispatchGroup()
            var results: [(post: PostModel, user: UserModel)] = []
            
            for item in items {
                if let item = item as? DataSnapshot {
                    myGroup.enter()
                    PostObserver().observePost(withId: item.key, completion: { (post) in
                        UserObserver().observeUser(withId: post.uid!, completion: { (user) in
                            if post.uid == user.id {
                                results.removeAll()
                                results.append((post, user))
                                completionHandler(results)
                            }
                            myGroup.leave()
                        })
                    })
                }
            }
            
            //parse following feeds
            myGroup.notify(queue: .main) {
                //results.sort(by: {$0.0.timeStamp! > $1.0.timeStamp! }) //commented by @CRAZY-DEV
                completionHandler(results)
            }
        })
        
    }
    
    func getOldFeed(withId id: String, start timestamp: Int, limit: UInt, completionHandler: @escaping ([(PostModel, UserModel)]) -> Void) {
        
        let feedOrderQuery = REF_FEED.child(id).queryOrdered(byChild: "time_stamp")
        let feedLimitedQuery = feedOrderQuery.queryEnding(atValue: timestamp - 1, childKey: "time_stamp").queryLimited(toLast: limit)
        
        feedLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            if let items = snapshot.children.allObjects as? [DataSnapshot] {
                
                let myGroup = DispatchGroup()
                
                var results: [(post: PostModel, user: UserModel)] = []
                
                for item in items {
                    print(item)
                    
                    myGroup.enter()
                    PostObserver().observePost(withId: item.key, completion: { (post) in
                        UserObserver().observeUser(withId: post.uid!, completion: { (user) in
                            if post.uid == user.id {
                                results.append((post, user))
                            }
                            myGroup.leave()
                        })
                    })
                }
                
                myGroup.notify(queue: DispatchQueue.main, execute: {
                    results.sort(by: {$0.0.timeStamp! > $1.0.timeStamp! })
                    completionHandler(results)
                })
            }
        })
    }
    
    func observeFeedRemoved(withId id: String, completion: @escaping (PostModel) -> Void) {
        REF_FEED.child(id).observe(.childRemoved, with: {
            snapshot in
            let key = snapshot.key
            PostObserver().observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }

}
