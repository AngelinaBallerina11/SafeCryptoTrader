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
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIHelper.styleTextField(emailTextField)
        UIHelper.styleTextField(passwordTextField)
        UIHelper.styleFilledButton(signInButton)
    }
    
    @IBAction func signIn(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
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

    
}
