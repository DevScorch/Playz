//
//  ViewsModel.swift
//  Playz
//
//  Created by LangsemWork on 10.06.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation

class ViewsModel {
    
    private var _uid: String?
    private var _viewsCount: Int?
    
    var uid: String? {
        get {
            return _uid
        }set {
            _uid = uid
        }
    }
    
    var viewsCount: Int? {
        get {
            return _viewsCount
            
        }set {
            _viewsCount = viewsCount
        }
    }
    
    init() {}
}

extension ViewsModel {
    static func countViews(dict: [String: Any]) -> ViewsModel {
        let views = ViewsModel()
        views.viewsCount = dict["views_ount"] as? Int
        views.uid = dict["uid"] as? String
        return views
    }
}
