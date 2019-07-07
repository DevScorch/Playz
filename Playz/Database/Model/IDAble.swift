//
//  IDAble.swift
//  Playz
//
//  Created by Joriah Lasater on 8/11/18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation

protocol IDAble {
    var id: String? {get set}
}

extension Array where Element: IDAble {
    func alreadyExists(model: IDAble) -> Bool {
        for element in self where element.id == model.id {
            return true
        }
        return false
    }
}
