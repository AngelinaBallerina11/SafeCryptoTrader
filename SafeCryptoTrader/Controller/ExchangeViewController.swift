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
    var persistentContainer: NSPersistentContainer!
    //var btcFetchedResultsController: NSFetchedResultsController<Bitcoin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPersistence()
        fetchBitcoinPrice()
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    
    @objc func fireTimer() {
        print("Timer fired! exchange")
        fetchBitcoinPrice()
    }
    
    fileprivate func setUpPersistence() {
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            persistentContainer = sd.persistentContainer
        }
        setUpBtcFetchResultsController()
    }
    
    fileprivate func setUpBtcFetchResultsController() {
        let request = Bitcoin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sortDescriptor]
//        btcFetchedResultsController = NSFetchedResultsController(
//            fetchRequest: request,
//            managedObjectContext: persistentContainer.viewContext,
//            sectionNameKeyPath: nil, cacheName: nil)
//        btcFetchedResultsController.delegate = self
//        try? btcFetchedResultsController.performFetch()
    }
    
    fileprivate func fetchBitcoinPrice() {
        CryptoService.getBtcPrice { price, error in
            if let error = error {
                print("BTC price error \(error.localizedDescription)")
                return
            }
            
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // btcFetchedResultsController = nil
    }
}
