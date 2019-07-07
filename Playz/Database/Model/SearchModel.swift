//
//  SearchModel.swift
//  Playz
//
//  Created by Johan on 01-06-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation

class SearchModel {
    
    // DEVSCORCH: Variables
    
    private var _thumbnail: String!
    private var _username: String!
    private var _tag: String!
    
    // DEVSCORCH: Securing
    
    var thumbnail: String {
        return _thumbnail
    }
    
    var username: String {
        return _username
    }
    
    var tag: String {
        return _tag
    }
    
    init(thumbnail: String, username: String, tag: String) {
        self._thumbnail = thumbnail
        self._username = username
        self._tag = tag
    }
    
}
