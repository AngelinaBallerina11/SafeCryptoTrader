//
//  StartupViewController.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit
import Firebase

class StartupViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!

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
        UiHelper.styleFilledButton(signUpButton)
        UiHelper.styleHollowButton(signInButton)
    }
}
