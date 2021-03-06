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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationHelper.lockOrientation(.portrait)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        OrientationHelper.lockOrientation(.all)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearError()
        UiHelper.styleTextField(emailTextField)
        UiHelper.styleTextField(passwordTextField)
        UiHelper.styleFilledButton(signInButton)
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
            password: passwordTextField.text!.trim()) { error in
                self.showLoading(false)
                if let error = error {
                    self.showError(error.localizedDescription)
                    return
                }
                AuthenticationService().selectFirstScreen()
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
}
