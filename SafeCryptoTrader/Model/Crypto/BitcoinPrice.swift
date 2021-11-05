//
//  BitcoinPrice.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 05.11.2021.
//

import Foundation

struct BitcoinPrice: Codable {
    let usd: Double
    let dailyChange: Double
    
    enum CodingKeys: String, CodingKey {
        case usd
        case dailyChange = "usd_24h_change"
    }
}
