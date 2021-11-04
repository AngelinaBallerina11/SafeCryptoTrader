//
//  Alerts.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) {(result : UIAlertAction) -> Void in}
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
