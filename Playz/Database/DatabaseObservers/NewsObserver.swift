//
//  NewsObserver.swift
//  Playz
//
//  Created by Joriah Lasater on 7/14/18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation

class NewsObserver {
    
    func observerNews(completion: @escaping (NewsModel?) -> Void) {
        completion(nil)
        DatabaseReferences.ds.REF_NEWS.observe(.value, with: { snapshot in
            if let dict = snapshot.value as? [String: [String: Any]] {
                dict.values.forEach {
                    let model = NewsModel.transformNewsModel(dict: $0)
                    completion(model)
                }
            }
        })
    }
}
