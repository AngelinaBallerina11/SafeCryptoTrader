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
    func exchange(amount: Double, btcPrice: Double) -> Currency
}

class Dollar : Currency {
    var name: String = Constants.Currencies.USD
    var amount: Double = 0.0
    
    init() {
        self.name = Constants.Currencies.USD
        self.amount = 0.0
    }
    
    init(name: String, amount: Double) {
        self.name = name
        self.amount = amount
    }
    
    func format() -> String {
        return amount.to2dp()
    }
    
    func updateAmount(_ amount: Double) -> Currency {
        return Dollar(name: self.name, amount: amount)
    }
    
    func exceededAllowedNumOfDecimalPlaces(_ string: String) -> Bool {
        if let decimalIndex = string.firstIndex(of: ".")?.utf16Offset(in: string) {
            return decimalIndex > 0 && (string.count - decimalIndex) > 2
        } else {
            return false
        }
    }
    
    func exchange(amount: Double, btcPrice: Double) -> Currency {
        if btcPrice == 0.0 {
            return Dollar(name: self.name, amount: amount)
        } else {
            return Dollar(name: self.name, amount: amount * btcPrice)
        }
    }
}

class Bitcoin : Currency {
    var name : String = Constants.Currencies.BTC
    var amount: Double = 0.0
    
    init() {
        self.name = Constants.Currencies.BTC
        self.amount = 0.0
    }
    
    init(name: String, amount: Double) {
        self.name = name
        self.amount = amount
    }
    
    func format() -> String {
        return amount.to8dp()
    }
    
    func updateAmount(_ amount: Double) -> Currency {
        return Bitcoin(name: self.name, amount: amount)
    }
    
    func exceededAllowedNumOfDecimalPlaces(_ string: String) -> Bool {
        if let decimalIndex = string.firstIndex(of: ".")?.utf16Offset(in: string) {
            return decimalIndex > 0 && (string.count - decimalIndex) > 8
        } else {
            return false
        }
    }
    
    func exchange(amount: Double, btcPrice: Double) -> Currency {
        if btcPrice == 0.0 {
            return Bitcoin(name: self.name, amount: amount)
        } else {
            return Bitcoin(name: self.name, amount: amount / btcPrice)
        }
    }
}
