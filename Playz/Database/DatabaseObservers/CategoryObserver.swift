//
//  CategoryObserver.swift
//  Playz
//
//  Created by LangsemWork on 14.06.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import Firebase
class CategoryObserver {
    
    let REF_CATEGORY = DatabaseReferences().REF_CATEGORIES
    
    // JAASTER: Will be updating all Observer classes with generics after first release
    func fetchPosts(withTag category: String, completion: @escaping (String) -> Void) {
       
        REF_CATEGORY.child(category.lowercased()).child("posts").observe(.value, with: {
            snapshot in
            if let postIds = snapshot.children.allObjects as? [DataSnapshot] {
                for postId in postIds {
                    completion(postId.key)
                }
            }
        })
    }
    
    func fetchCategories(completion: @escaping (CategoryModel) -> Void) {
        REF_CATEGORY.observe(.value) { (snapshot) in
            snapshot.children.forEach {
                if let child = $0 as? DataSnapshot, let dict = child.value as? [String: Any] {
                    let category = CategoryModel.transformCategory(title: child.key, dict: dict)
                    completion(category)
                }
            }
        }
    }
    
    func  fetchCategories(with text: String, completion: @escaping (CategoryModel?) -> Void) {
        REF_CATEGORY.queryOrderedByKey().queryStarting(atValue: text).queryEnding(atValue: text + "\u{f8ff}").observe(.value) { (snapshot) in
            completion(nil)
            snapshot.children.forEach {
                if let child = $0 as? DataSnapshot, let dict = child.value as? [String: Any] {
                    let category = CategoryModel.transformCategory(title: child.key, dict: dict)
                    completion(category)
                }
            }
        }
    }
}
