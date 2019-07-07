//
//  ViewsofVideoObserver.swift
//  Playz
//
//  Created by LangsemWork on 10.06.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ViewsofVideoObserver {
    
    var REF_VIEWS_COUNT = DatabaseReferences.ds.REF_VIEWS
    
    func observeViews(withPostId id: String, completion: @escaping (ViewsModel) -> Void) {
        //Make function so the user can only count 1 views per userid on watched video
    }
}
