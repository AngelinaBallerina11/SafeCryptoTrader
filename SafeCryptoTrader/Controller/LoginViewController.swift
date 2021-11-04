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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearError()
        UIHelper.styleTextField(emailTextField)
        UIHelper.styleTextField(passwordTextField)
        UIHelper.styleFilledButton(signInButton)
    }
    
    @IBAction func onSignInTapped(_ sender: Any) {
        clearError()
        if let error = validateFields() {
            showError(error)
            return
        }
        showLoading(true)
        UserRepository.signIn(
            email: emailTextField.text!.trim(),
            password: passwordTextField.text!.trim()) { success, error in
                self.showLoading(false)
                if let error = error {
                    self.showError(error.localizedDescription)
                    return
                }
                if success {
                    self.transitionToHomeScreen()
                }
            }
    }
    
    fileprivate func validateFields() -> String? {
        if emailTextField.text?.isBlank() == true ||
            passwordTextField.text?.isBlank() == true {
            return "Please, fill in all fields."
        }
        
        if !emailTextField.text!.isValidEmail() {
            return "Please, enter a valid email."
        }
        
        if !passwordTextField.text!.isValidPassword() {
            return "Please, make sure the password has at least 8 characters and contains a special character and a number."
        }
        
        return nil
    }
    
    fileprivate func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    fileprivate func clearError() {
        errorLabel.text = ""
        errorLabel.alpha = 0
    }
    
    fileprivate func showLoading(_ loading: Bool) {
        loadingIndicator.isHidden = !loading
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    fileprivate func transitionToHomeScreen() {
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
}
