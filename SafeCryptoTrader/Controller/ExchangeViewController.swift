//
//  ExchangeViewController.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit
import CoreData

class ExchangeViewController : UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var fromCurrency: UILabel!
    @IBOutlet weak var fromAmount: UITextField!
    @IBOutlet weak var toCurrency: UILabel!
    @IBOutlet weak var toAmount: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var exchangeButton: UIButton!
    @IBOutlet weak var transactionsTableView: UITableView!
    
    var persistentContainer: NSPersistentContainer!
    var transactionFetchedResultsController: NSFetchedResultsController<Transaction>!
    
    var state: State!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        state = State.getDefault()
        renderState(state)
        setUpPersistence()
        fetchBitcoinPrice()
        setUpTextFields()
        startTimer()
        transactionsTableView.dataSource = self
        transactionsTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
        fetchAccount()
        OrientationHelper.lockOrientation(UIInterfaceOrientationMask.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionFetchedResultsController = nil
        OrientationHelper.lockOrientation(UIInterfaceOrientationMask.all)
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
    
    @IBAction func onExchnageTapped(_ sender: Any) {
        if let account = state.account {
            let newTransaction = Transaction(context: persistentContainer.viewContext)
            newTransaction.date = Date()
            if state.fromCurrency is Dollar {
                account.usd -= state.fromCurrency.amount
                account.btc += state.toCurrency.amount
                newTransaction.btcBuy = true
                newTransaction.usdAmount = state.fromCurrency.amount
                newTransaction.btcAmount = state.toCurrency.amount
            } else {
                account.btc -= state.fromCurrency.amount
                account.usd += state.toCurrency.amount
                newTransaction.btcBuy = false
                newTransaction.usdAmount = state.toCurrency.amount
                newTransaction.btcAmount = state.fromCurrency.amount
            }
            try? persistentContainer.viewContext.save()
            resetState()
            showSuccessAlert()
        } else {
            showErrorAlert(message: "Failed to load the account data")
        }
    }
    
    fileprivate func resetState() {
        fromAmount.text = nil
        toAmount.text = nil
        state = state.resetAmounts()
        renderState(state)
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
        if toAmount.text != state.toCurrency.format() {
            toAmount.text = state.toCurrency.format()
        }
        exchangeButton.isEnabled = state.error == nil && state.fromCurrency.amount > 0.0
    }
    
    fileprivate func setUpPersistence() {
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            persistentContainer = sd.persistentContainer
        }
    }
    
    fileprivate func setUpFetchedResultsController() {
        let request = Transaction.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        transactionFetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
        transactionFetchedResultsController.delegate = self
        do {
            try transactionFetchedResultsController.performFetch()
        } catch {
            fatalError("Fetch could not be performed: \(error.localizedDescription)")
        }
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
                fromCurrency: Dollar(),
                toCurrency: Bitcoin(),
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
                error: checkError(self.toCurrency),
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
        
        func checkError(_ currency: Currency) -> String? {
            if let account = self.account {
                if currency is Dollar && account.usd < currency.amount ||
                    currency is Bitcoin && account.btc < currency.amount {
                    return "Insufficient balance"
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        
        func updateFromAmount(_ amount: Double) -> State {
            let newFromCurrency = self.fromCurrency.updateAmount(amount)
            return State(
                fromCurrency: newFromCurrency,
                toCurrency: self.toCurrency.exchange(amount: amount, btcPrice: currentBtcPrice),
                account: self.account,
                currentBtcPrice: self.currentBtcPrice,
                error: checkError(newFromCurrency),
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
        
        func resetAmounts() -> State {
            return State(
                fromCurrency: self.fromCurrency.updateAmount(0.0),
                toCurrency: self.toCurrency.updateAmount(0.0),
                account: self.account,
                currentBtcPrice: self.currentBtcPrice,
                error: nil,
                fromUserAction: false
            )
        }
    }
}

extension ExchangeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionFetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionFetchedResultsController.sections?[0].numberOfObjects ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.cellId, for: indexPath) as! TransactionTableViewCell
        let transaction = transactionFetchedResultsController.object(at: indexPath)
        cell.dateLabel.text = transaction.date?.formatDate()
        let btcPrefix: String
        let usdPrefix: String
        if transaction.btcBuy {
            cell.transactionTypeLabel.text = "Buy BTC"
            btcPrefix = "+"
            usdPrefix = "-"
        } else {
            cell.transactionTypeLabel.text = "Sell BTC"
            btcPrefix = "-"
            usdPrefix = "+"
        }
        cell.btcAmountLabel.text = btcPrefix + transaction.btcAmount.to8dp() + " " + Constants.Currencies.BTC
        cell.usdAmountLabel.text = usdPrefix + transaction.usdAmount.to2dp() + " " + Constants.Currencies.USD
        return cell
    }
}

extension ExchangeViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            transactionsTableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            break
        case .move:
            break
        case .update:
            guard let indexPath = indexPath else { return }
            transactionsTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
