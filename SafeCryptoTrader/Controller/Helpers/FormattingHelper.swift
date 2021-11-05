//
//  FormattingHelper.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 05.11.2021.
//

import Foundation

extension Double {
    
    func to2dp() -> String {
        return String(format: "%.2f", self)
    }
    
    func to8dp() -> String {
        return String(format: "%.8f", self)
    }
}
