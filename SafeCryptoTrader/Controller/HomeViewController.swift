//
//  HomeViewController.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit
import CoreData

class HomeViewController : UIViewController {
    
    @IBOutlet weak var balanceGroup: UIStackView!
    @IBOutlet weak var btcDailyChange: UILabel!
    @IBOutlet weak var btcPrice: UILabel!
    @IBOutlet weak var usdAmount: UILabel!
    @IBOutlet weak var btcAmount: UILabel!
    
    var persistentContainer: NSPersistentContainer!
    var accountFetchedResultsController: NSFetchedResultsController<Account>!
    var account: Account? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPersistence()
        fetchBitcoinPrice()
        Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        balanceGroup.addBackground(color: .gray)
    }
    
    @objc func fireTimer() {
        print("Timer fired!")
        fetchBitcoinPrice()
    }
    
    @IBAction func onTopUpTapped(_ sender: Any) {
        if let account = account {
            account.usd += 100.0
        }
        try? persistentContainer.viewContext.save()
        fetchAccount()
    }
    
    @IBAction func onReloadTapped(_ sender: Any) {
        fetchBitcoinPrice()
    }
    
    fileprivate func fetchAccount() {
        let request = Account.fetchRequest()
        request.fetchLimit = 1
        do {
            let result = try persistentContainer.viewContext.fetch(request)
            if result.isEmpty {
                addEmptyAccount()
            }
            if let account = result.first {
                usdAmount.text = String(format: "%.2f", account.usd)
                btcPrice.text = String(format: "%.2f", account.btc)
                self.account = account
            }
        } catch {
            print("Failed")
        }
    }
    
    fileprivate func setUpPersistence() {
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            persistentContainer = sd.persistentContainer
        }
        fetchAccount()
    }
    
    fileprivate func addEmptyAccount() {
        account = Account(context: persistentContainer.viewContext)
        account!.btc = 0.0
        account!.usd = 0.0
        try? persistentContainer.viewContext.save()
    }
    
    fileprivate func formatBtcDailyChange(_ btc: BitcoinPrice) {
        var prefix = ""
        if btc.dailyChange >= 0 {
            self.btcDailyChange.textColor = #colorLiteral(red: 0.3662651119, green: 0.7484217172, blue: 0.2749513667, alpha: 1)
            prefix = "+"
        } else {
            self.btcDailyChange.textColor = .red
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

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.frame = CGRect(x: -15.0, y: -15.0, width: subView.frame.width+30.0, height: subView.frame.height + 30.0)
        subView.backgroundColor = #colorLiteral(red: 0.9182365145, green: 0.9180737242, blue: 0.9334556503, alpha: 1)
        subView.layer.cornerRadius = 20.0
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
