//
//  CommentObserver.swift
//  Playz
//
//  Created by Johan on 27-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import FirebaseDatabase

// DEVSCORCH: Variables

class CommentObserver {
 
    var REF_COMMENTS = DatabaseReferences.ds.REF_COMMENTS
    
    func observeComments(withPostId id: String, completion: @escaping (CommentModel) -> Void) {
        REF_COMMENTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                
                let newComment = CommentModel.transformComment(dict: dict, key: snapshot.key)
                completion(newComment)
            }
        })
    }
}
