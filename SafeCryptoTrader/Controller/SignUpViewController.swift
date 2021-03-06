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
        setUpElements()
    }
    
    func setUpElements() {
        clearError()
        UiHelper.styleTextField(firstNameTextField)
        UiHelper.styleTextField(lastNameTextField)
        UiHelper.styleTextField(emailTextField)
        UiHelper.styleTextField(passwordTextField)
        UiHelper.styleFilledButton(signUp)
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
