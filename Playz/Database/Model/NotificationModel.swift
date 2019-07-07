//
//  NotificationModel.swift
//  Playz
//
//  Created by LangsemWork on 06.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import FirebaseAuth

class NotificationModel {
    
    // Private Variables
    private var _from: String?
    private var _objectId: String?
    private var _type: String?
    private var _timeStamp: Int?
    private var _id: String?
    var fromUser: UserModel?
    // Initialisers
    
    var from: String? {
        get { return _from
        } set {
            _from = newValue
        }
    }
    
    var objectId: String? {
        get { return _objectId
        } set {
            _objectId = newValue
        }
    }
    
    var type: String? {
        get {  return _type
        } set {
            _type = newValue
        }
    }
    
    var timeStamp: Int? {
        get { return _timeStamp
        } set {
            _timeStamp = newValue
        }
    }
    
    var id: String? {
        get { return _id
        } set {
            _id = newValue
        }
    }
    
}

extension NotificationModel {
    static func transformNotification(dict: [String: Any], key: String) -> NotificationModel {
        let notification = NotificationModel()
        notification._id = key
        notification._objectId = dict["object_id"] as? String
        notification._type = dict["type"] as? String
        notification._timeStamp = dict["time_stamp"] as? Int
        notification._from = dict["from"] as? String
        return notification
    }
    
}
