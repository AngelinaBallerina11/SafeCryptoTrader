//
//  SignUpViewController.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    func setUpElements() {
        clearError()
        UIHelper.styleTextField(firstNameTextField)
        UIHelper.styleTextField(lastNameTextField)
        UIHelper.styleTextField(emailTextField)
        UIHelper.styleTextField(passwordTextField)
        UIHelper.styleFilledButton(signUp)
    }
    
    @IBAction func onSignUpTapped(_ sender: Any) {
        clearError()
        if let error = validateFields() {
            showError(error)
            return
        }
        showLoading(true)
        UserRepository.createNewUser(
            firstName: firstNameTextField.text!.trim(),
            lastName: lastNameTextField.text!.trim(),
            userName: emailTextField.text!.trim(),
            password: passwordTextField.text!.trim()) { success, error in
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    self.transitionToHomeScreen()
                }
            }
    }
    
    fileprivate func transitionToHomeScreen() {
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    fileprivate func validateFields() -> String? {
        if firstNameTextField.text?.isBlank() == true ||
            lastNameTextField.text?.isBlank() == true ||
            emailTextField.text?.isBlank() == true ||
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
