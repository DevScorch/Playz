//
//  MyPostFetcher.swift
//  Playz
//
//  Created by LangsemWork on 06.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import FirebaseDatabase

// DEVSCORCH: Variables

class MyPostFetcher {
    var REF_MYPOSTS = DatabaseReferences.ds.REF_MY_POSTS
    
    func fetchMyPosts(userId: String, completion: @escaping (String) -> Void) {
        REF_MYPOSTS.child(userId).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    
    func fetchCountMyPosts(userId: String, completion: @escaping (Int) -> Void) {
        REF_MYPOSTS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
