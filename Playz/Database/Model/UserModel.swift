//
//  UserModel.swift
//  Playz
//
//  Created by LangsemWork on 06.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation

class UserModel: IDAble {
    var email: String?
    var profilePictureUrl: String?
    var backgroundImageUrl: String?
    var username: String?
    var displayname: String?
    var id: String?
    var isFollowing: Bool?
}

extension UserModel {
    static func transformUser(dict: [String: Any], key: String) -> UserModel {
        let user = UserModel()
        user.email = dict["email"] as? String
        user.profilePictureUrl = dict["profile_image_url"] as? String
        user.backgroundImageUrl = dict["background_image_url"] as? String
        user.username = dict["user_name"] as? String
        user.id = key
        user.displayname = dict["display_name"] as? String
        return user
    }
}
