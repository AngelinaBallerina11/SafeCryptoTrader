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
    
    func showSuccessAlert() {
        let alertController = UIAlertController(title: "Success!", message: "Your transation has been performed", preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 80, y: 80, width: 100, height: 100))
        imageView.image = UIImage(named: "party-popper")
        alertController.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: alertController.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        let width = NSLayoutConstraint(item: alertController.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        alertController.view.addConstraint(height)
        alertController.view.addConstraint(width)
        let okAction = UIAlertAction(title: "OK", style: .default) {(result : UIAlertAction) -> Void in}
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
