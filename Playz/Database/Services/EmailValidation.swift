//
//  EmailValidation.swift
//  Playz
//
//  Created by Johan on 01-05-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation

class EmailValidation {
    
    class func validateEmail(emailAddress: String) -> Bool {
        let REGEX: String
        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        
        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: emailAddress)
    }
}
