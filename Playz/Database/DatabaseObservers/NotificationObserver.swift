//
//  NotificationObserver.swift
//  Playz
//
//  Created by Johan on 27-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import Firebase

// DEVSCORCH: Variables

class NotificationObserver {
    
    var REF_NOTIFICATION = DatabaseReferences.ds.REF_NOTIFICATIONS
    
    func  observeNotification(withId  id: String, completion: @escaping (NotificationModel?) -> Void) {
        REF_NOTIFICATION.child(id).observe(.value, with: {
            snapshot in
            completion(nil)
            if let dict = snapshot.value as? [String: [String: Any]] {
                for (key, value) in dict {
                    let newNoti = NotificationModel.transformNotification(dict: value, key: key)
                    completion(newNoti)
                }
            }
        })
    }
}
