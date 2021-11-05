//
//  Currency.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 05.11.2021.
//

import Foundation

protocol Currency {
    var name: String { get set  }
    var amount: Double { get set }
    func format() -> String
    func updateAmount(_ amount: Double) -> Currency
    func exceededAllowedNumOfDecimalPlaces(_ string: String) -> Bool
}

class Dollar : Currency {
    var name: String = Constants.Currencies.USD
    var amount: Double = 0.0
    
    func format() -> String {
        return amount.to2dp()
    }
    
    func updateAmount(_ amount: Double) -> Currency {
        let d = Dollar()
        d.name = self.name
        d.amount = amount
        return d
    }
    
    func exceededAllowedNumOfDecimalPlaces(_ string: String) -> Bool {
        if let decimalIndex = string.firstIndex(of: ".")?.utf16Offset(in: string) {
            return decimalIndex > 0 && (string.count - decimalIndex) > 2
        } else {
            return false
        }
    }
}

class Bitcoin : Currency {
    var name : String = Constants.Currencies.BTC
    var amount: Double = 0.0
    
    func format() -> String {
        return amount.to8dp()
    }
    
    func updateAmount(_ amount: Double) -> Currency {
        let b = Bitcoin()
        b.name = self.name
        b.amount = amount
        return b
    }
    
    func exceededAllowedNumOfDecimalPlaces(_ string: String) -> Bool {
        if let decimalIndex = string.firstIndex(of: ".")?.utf16Offset(in: string) {
            return decimalIndex > 0 && (string.count - decimalIndex) > 8
        } else {
            return false
        }
    }
}
