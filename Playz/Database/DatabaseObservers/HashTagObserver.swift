//
//  HashTagFetcher.swift
//  Playz
//
//  Created by Johan on 27-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import Firebase

// DEVSCORCH: Variables

class HashTagObserver {
    var REF_HASHTAG = DatabaseReferences.ds.REF_HASHTAG

    func fetchPosts(withTag tag: String, completion: @escaping (String) -> Void) {
        REF_HASHTAG.child(tag.lowercased()).observe(.childAdded, with: {
            completion($0.key)
        })
    }
    
    func fetchHashTags(withTag tag: String, completion: @escaping (HashtagModel?) -> Void) {
        REF_HASHTAG.queryOrderedByKey().queryStarting(atValue: tag).queryEnding(atValue: tag + "\u{f8ff}").observe(.value) { (snapshot) in
            completion(nil)
            snapshot.children.forEach({ child in
                if let child = child as? DataSnapshot, let dict = child.value as? [String: Any] {
                    let hashtag = HashtagModel.transformHashTag(title: child.key, dict: dict)
                    completion(hashtag)
                }
            })
        }
    }
}
