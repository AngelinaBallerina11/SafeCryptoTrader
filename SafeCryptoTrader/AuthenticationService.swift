//
//  AuthenticationService.swift
//  SafeCryptoTrader
//
//  Created by bogdan razvan on 09.11.2021.
//

import Foundation
import UIKit
import FirebaseAuth

class AuthenticationService {

    func selectFirstScreen() {
        guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else { return }
        let vc: UIViewController?
        if Auth.auth().currentUser != nil {
            vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.tabBarViewController) as? TabBarController
        } else {
            vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.startupViewController) as? UINavigationController
        }
        window.rootViewController = vc
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }

}
