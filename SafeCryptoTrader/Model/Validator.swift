//
//  Validator.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation

extension String {
    
    func isValidEmail() -> Bool {
        return !self.isEmpty
    }
    
    func isValidPassword() -> Bool {
        return self.count > 4
    }
}
