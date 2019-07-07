//
//  DateExtention.swift
//  Playz
//
//  Created by Joriah Lasater on 7/14/18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
extension Date {
    func formateDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
}
