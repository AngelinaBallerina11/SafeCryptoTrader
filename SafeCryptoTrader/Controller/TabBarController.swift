//
//  TabBarController.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
