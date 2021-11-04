//
//  LoginViewController.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func signUp(_ sender: Any) {
        if let email = email.text, let password = password.text {
            if email.isValidEmail() && password.isValidPassword() {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        self.showErrorAlert(message: error.localizedDescription)
                        return
                    }
                    
                }
            }
        }
    }
    
    @IBAction func signIn(_ sender: Any) {
    }
    
}
