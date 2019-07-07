//
//  NewsModel.swift
//  Playz
//
//  Created by Slackmous on 6/2/18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation

class NewsModel {
    
    private var _message: String!
    private var _datetime: Date?
    private var _description: String!
    
    var message: String {
        return _message
    }
    
    var description: String {
        return _description
    }
    
    var datetime: Date {
        return _datetime ?? Date()
    }
    
    init(message: String, datetime: Date) {
        self._message = message
        self._datetime = datetime
    }
    
    init() {
        
    }
}

extension NewsModel {
    static func transformNewsModel(dict: [String: Any]) -> NewsModel {
        let newsModel = NewsModel()
        newsModel._message = dict["object_id"] as? String ?? ""
        newsModel._datetime = DateFormatter().date(from: dict["time_stamp"] as? String ?? "")
        newsModel._description = dict["description"] as? String ?? ""
        return newsModel
    }
}
