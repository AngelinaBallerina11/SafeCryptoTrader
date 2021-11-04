//
//  HomeViewController.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit

class HomeViewController : UIViewController {
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func onLogoutTapped(_ sender: Any) {
        UserRepository.logout { error in
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                self.navigateToStartupScreen()
            }
        }
    }
    
    fileprivate func navigateToStartupScreen() {
        navigationController?.popViewController(animated: true)
    }
}
