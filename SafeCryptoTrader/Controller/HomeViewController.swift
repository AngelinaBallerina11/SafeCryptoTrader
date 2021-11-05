//
//  HomeViewController.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit


class HomeViewController : UIViewController {
    
   
    @IBOutlet weak var btcDailyChange: UILabel!
    @IBOutlet weak var btcPrice: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBitcoinPrice()
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
   
    @objc func fireTimer() {
        print("Timer fired!")
        fetchBitcoinPrice()
    }

    
    fileprivate func formatBtcDailyChange(_ btc: BitcoinPrice) {
        let prefix: String
        if btc.dailyChange >= 0 {
            self.btcDailyChange.textColor = #colorLiteral(red: 0.3662651119, green: 0.7484217172, blue: 0.2749513667, alpha: 1)
            prefix = "+"
        } else {
            self.btcDailyChange.textColor = .red
            prefix = "-"
        }
        self.btcDailyChange.text = prefix + String(format: "%.2f", btc.dailyChange)
    }
    
    fileprivate func fetchBitcoinPrice() {
        CryptoService.getBtcPrice { price, error in
            if let error = error {
                print("BTC price error \(error.localizedDescription)")
                return
            }
            if let btc = price {
                self.btcPrice.text = String(format: "%.2f", btc.usd)
                self.formatBtcDailyChange(btc)
            }
        }
    }
    
   
}
