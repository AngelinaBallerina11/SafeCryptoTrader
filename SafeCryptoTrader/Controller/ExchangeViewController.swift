//
//  ExchangeViewController.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit
import CoreData

class ExchangeViewController : UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var fromCurrency: UILabel!
    @IBOutlet weak var fromAmount: UITextField!
    @IBOutlet weak var toCurrency: UILabel!
    @IBOutlet weak var toAmount: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var persistentContainer: NSPersistentContainer!
    var accountFetchedResultsController: NSFetchedResultsController<Account>!
    
    var state: State!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        state = State.getDefault()
        renderState(state)
        setUpPersistence()
        fetchBitcoinPrice()
        setUpTextFields()
        startTimer()
        
    }
    
    @objc func fireTimer() {
        print("Timer fired! exchange")
        fetchBitcoinPrice()
    }
    
    @IBAction func onSwapCurrencyTapped(_ sender: Any) {
        state = state.swap()
        renderState(state)
    }
    
    fileprivate func setUpTextFields() {
        fromAmount.addTarget(self, action: #selector(fromAmountTextFieldDidChange(_:)), for: .editingChanged)
        fromAmount.addTarget(self, action: #selector(fromAmountTextFieldDidBegin(_:)), for: .editingDidBegin)
        toAmount.addTarget(self, action: #selector(toAmountTextFieldDidChange(_:)), for: .editingChanged)
        toAmount.addTarget(self, action: #selector(toAmountTextFieldDidBegin(_:)), for: .editingDidBegin)
    }
    
    @objc func fromAmountTextFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if let amount = Double(text) {
                state = state.updateFromAmount(amount)
                renderState(state)
            }
        }
    }
    
    @objc func fromAmountTextFieldDidBegin(_ textField: UITextField) {
        if let text = textField.text {
            if state.fromCurrency.exceededAllowedNumOfDecimalPlaces(text) { return }
        }
    }
    
    @objc func toAmountTextFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if let amount = Double(text) {
                state = state.updateToAmount(amount)
                renderState(state)
            }
        }
    }
    
    @objc func toAmountTextFieldDidBegin(_ textField: UITextField) {
        if let text = textField.text {
            if state.toCurrency.exceededAllowedNumOfDecimalPlaces(text) { return }
        }
    }
    
    fileprivate func startTimer() {
        Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    fileprivate func renderState(_ state: State) {
        if fromCurrency.text != state.fromCurrency.name {
            fromCurrency.text = state.fromCurrency.name
        }
        if fromAmount.text != state.fromCurrency.format() && (state.fromCurrency.exceededAllowedNumOfDecimalPlaces(fromAmount.text!) || !state.fromUserAction)  {
            fromAmount.text = state.fromCurrency.format()
        }
        errorLabel.text = state.error
        errorLabel.isHidden = state.error == nil
        if toCurrency.text != state.toCurrency.name {
            toCurrency.text = state.toCurrency.name
        }
        if toAmount.text != state.toCurrency.format() && (state.toCurrency.exceededAllowedNumOfDecimalPlaces(toAmount.text!) || !state.fromUserAction) {
            toAmount.text = state.toCurrency.format()
        }
    }
    
    fileprivate func setUpPersistence() {
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            persistentContainer = sd.persistentContainer
        }
        fetchAccount()
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
                state = state.updateAccount(account)
            }
        } catch {
            print("Failed")
        }
    }
    
    fileprivate func fetchBitcoinPrice() {
        CryptoService.getBtcPrice { price, error in
            if let error = error {
                print("BTC price error \(error.localizedDescription)")
                return
            }
            if let btcPrice = price {
                DispatchQueue.main.async {
                    self.state = self.state.updateBtcPrice(btcPrice.usd)
                }
            }
        }
    }
    
    fileprivate func addEmptyAccount() {
        let account = Account(context: persistentContainer.viewContext)
        account.btc = 0.0
        account.usd = 0.0
        state = state.updateAccount(account)
        try? persistentContainer.viewContext.save()
    }
    
    struct State {
        
        var fromCurrency: Currency
        var toCurrency: Currency
        var account: Account?
        var currentBtcPrice: Double
        var error: String?
        var fromUserAction: Bool
        
        init(
            fromCurrency: Currency,
            toCurrency: Currency,
            account: Account?,
            currentBtcPrice: Double,
            error: String?,
            fromUserAction: Bool
        ) {
            self.fromCurrency = fromCurrency
            self.toCurrency = toCurrency
            self.account = account
            self.currentBtcPrice = currentBtcPrice
            self.error = error
            self.fromUserAction = fromUserAction
        }
        
        static func getDefault() -> State {
            return State(
                fromCurrency: Bitcoin(),
                toCurrency: Dollar(),
                account: nil,
                currentBtcPrice: 0.0,
                error: nil,
                fromUserAction: false
            )
        }
        
        func swap() -> State {
            return State(
                fromCurrency: self.toCurrency,
                toCurrency: self.fromCurrency,
                account: self.account,
                currentBtcPrice: self.currentBtcPrice,
                error: self.error,
                fromUserAction: false
            )
        }
        
        func updateBtcPrice(_ price: Double) -> State {
            return State(
                fromCurrency: self.fromCurrency,
                toCurrency: self.toCurrency,
                account: self.account,
                currentBtcPrice: price,
                error: self.error,
                fromUserAction: false
            )
        }
        
        func updateFromAmount(_ amount: Double) -> State {
            // check balance
            var error = self.error
            if let account = self.account {
                if self.fromCurrency is Dollar && account.usd < amount ||
                    self.fromCurrency is Bitcoin && account.btc < amount {
                    error = "Insufficient balance"
                } else {
                    error = nil
                }
            }
            return State(
                fromCurrency: self.fromCurrency.updateAmount(amount),
                toCurrency: self.toCurrency,
                account: self.account,
                currentBtcPrice: self.currentBtcPrice,
                error: error,
                fromUserAction: true
            )
        }
        
        func updateToAmount(_ amount: Double) -> State {
            return State(
                fromCurrency: self.fromCurrency,
                toCurrency: self.toCurrency.updateAmount(amount),
                account: self.account,
                currentBtcPrice: self.currentBtcPrice,
                error: self.error,
                fromUserAction: true
            )
        }
        
        func updateAccount(_ account: Account) -> State {
            return State(
                fromCurrency: self.fromCurrency,
                toCurrency: self.toCurrency,
                account: account,
                currentBtcPrice: self.currentBtcPrice,
                error: self.error,
                fromUserAction: false
            )
        }
        
        
    }
}
