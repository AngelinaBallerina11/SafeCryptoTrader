//
//  DateFormatter.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 05.11.2021.
//

import Foundation

extension Date {
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: self)
    }
}
