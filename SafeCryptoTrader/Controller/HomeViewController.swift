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
    @IBOutlet weak var totalToppedUpAmount: UILabel!
    @IBOutlet weak var totalAccountBalance: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var persistentContainer: NSPersistentContainer!
    var account: Account? = nil
    var toppedUpAmountEntity: ToppedUpAmount? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPersistence()
        fetchBitcoinPrice()
        startTimer()
        balanceGroup.addBackground(color: .gray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAccount()
        fetchToppedUpAmount()
        OrientationHelper.lockOrientation(UIInterfaceOrientationMask.portrait)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        OrientationHelper.lockOrientation(UIInterfaceOrientationMask.all)
    }
    
    @objc func fireTimer() {
        print("Timer fired!")
        fetchBitcoinPrice()
    }
    
    @IBAction func onTopUpTapped(_ sender: Any) {
        let defaultTopUp = 100.0
        if let account = account {
            account.usd += defaultTopUp
            toppedUpAmountEntity?.value += defaultTopUp
        }
        try? persistentContainer.viewContext.save()
        fetchAccount()
        fetchToppedUpAmount()
        if let btcPriceText = btcPrice.text {
            if let btcPriceDouble = Double(btcPriceText) {
                calculateTotalAccountBalance(btcPriceDouble)
            }
        } else {
            fetchBitcoinPrice()
        }
    }
    
    @IBAction func onReloadTapped(_ sender: Any) {
        fetchBitcoinPrice()
    }
    
    fileprivate func startTimer() {
        Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
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
                usdAmount.text = account.usd.to2dp()
                btcAmount.text = account.btc.to8dp()
                self.account = account
            }
        } catch {
            print("Failed")
        }
    }
    
    fileprivate func getTotalAccountBalance(usd: Double, btc: Double, btcPrice: Double) -> String {
        return (usd + btc * btcPrice).to2dp()
    }
    
    fileprivate func fetchToppedUpAmount() {
        let request = ToppedUpAmount.fetchRequest()
        request.fetchLimit = 1
        do {
            let result = try persistentContainer.viewContext.fetch(request)
            if result.isEmpty {
                toppedUpAmountEntity = ToppedUpAmount(context: persistentContainer.viewContext)
                toppedUpAmountEntity!.value = 0.0
                try? persistentContainer.viewContext.save()
            }
            if let toppedUp = result.first {
                toppedUpAmountEntity = toppedUp
                totalToppedUpAmount.text = toppedUp.value.to2dp()
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
        self.btcDailyChange.text = prefix + btc.dailyChange.to2dp()
    }
    
    fileprivate func calculateTotalAccountBalance(_ btcPrice: Double) {
        if let usd = self.usdAmount.text, let btc = self.btcAmount.text {
            if let usdDouble = Double(usd), let btcDouble = Double(btc) {
                self.totalAccountBalance.text = self.getTotalAccountBalance(usd: usdDouble, btc: btcDouble, btcPrice: btcPrice)
            }
        }
    }
    
    fileprivate func fetchBitcoinPrice() {
        loadingIndicator.startAnimating()
        CryptoService.getBtcPrice { price, error in
            self.loadingIndicator.stopAnimating()
            if let error = error {
                print("BTC price error \(error.localizedDescription)")
                self.showErrorAlert(message: error.localizedDescription)
                return
            }
            if let btcPrice = price {
                self.btcPrice.text = btcPrice.usd.to2dp()
                self.formatBtcDailyChange(btcPrice)
                self.calculateTotalAccountBalance(btcPrice.usd)
            }
        }
    }
}
