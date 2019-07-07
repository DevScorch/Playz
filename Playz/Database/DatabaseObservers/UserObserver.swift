//
//  UserObserver.swift
//  Playz
//
//  Created by Johan on 27-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserObserver {
    
    var REF_USERS = DatabaseReferences().REF_USERS
    
    func observerUserByUsername(username: String, completion: @escaping (UserModel) -> Void) {
        REF_USERS.queryOrdered(byChild: "user_name_lowercase").queryEqual(toValue: username).observeSingleEvent(of: .childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    func observeUser(withId uid: String, completion: @escaping (UserModel) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    func observeCurrentUser(completion: @escaping (UserModel) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    func observeUsers(completion: @escaping (UserModel) -> Void) {
        REF_USERS.observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    func queryUsers(withText text: String, completion: @escaping ( UserModel?) -> Void) {
        REF_USERS.queryOrdered(byChild: "user_name_lowercase").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: {
            snapshot in
            completion(nil)
            snapshot.children.forEach({
                if let child = $0 as? DataSnapshot, let dict = child.value as? [String: Any] {
                    let user = UserModel.transformUser(dict: dict, key: child.key)
                    completion(user)
                }
            })
        })
    }
    
    var CURRENT_USER: User? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser
        }
        return nil
    }
        
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return REF_USERS.child(currentUser.uid)
    }
}
