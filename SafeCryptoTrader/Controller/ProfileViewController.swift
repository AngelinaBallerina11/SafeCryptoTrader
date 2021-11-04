//
//  ProfileViewController.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var memberSinceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserRepository.getUserInfo { user, error in
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
                return
            }
            if let user = user {
                self.firstNameLabel.text = user.firstName
                self.lastNameLabel.text = user.lastName
                self.emailLabel.text = user.email
                self.memberSinceLabel.text = self.formatDate(user.memberSince)
            }
        }
    }
    
    fileprivate func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
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
        let vc = storyboard?.instantiateViewController(withIdentifier: "StartupVC") as! StartupViewController
        navigationController?.popToRootViewController(animated: true)
        let newNavController = UINavigationController(rootViewController: vc)
        navigationController?.isNavigationBarHidden = false
        view.window?.rootViewController = newNavController
    }
}
