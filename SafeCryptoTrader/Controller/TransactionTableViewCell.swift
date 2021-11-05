//
//  TransactionTableViewCell.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 05.11.2021.
//

import Foundation
import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var btcAmountLabel: UILabel!
    @IBOutlet weak var usdAmountLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
}
