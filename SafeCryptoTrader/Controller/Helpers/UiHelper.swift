//
//  UiHelper.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import UIKit

class UiHelper {
    
    static let cornerRadius = 20.0
    static let colorPrimary = #colorLiteral(red: 0, green: 0.5988945365, blue: 0.9966183305, alpha: 1)
    
    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        let underlineHeight = 2.0
        let padding = 20.0
        
        bottomLine.frame = CGRect(
            x: 0,
            y: textfield.frame.size.height - underlineHeight,
            width: textfield.frame.size.width - padding,
            height: underlineHeight
        )
        
        bottomLine.backgroundColor = colorPrimary.cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = colorPrimary
        button.layer.cornerRadius = UiHelper.cornerRadius
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = colorPrimary.cgColor
        button.layer.cornerRadius = UiHelper.cornerRadius
        button.tintColor = colorPrimary
    }
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.frame = CGRect(x: -15.0, y: -15.0, width: subView.frame.width+30.0, height: subView.frame.height + 30.0)
        subView.backgroundColor = #colorLiteral(red: 0.9182365145, green: 0.9180737242, blue: 0.9334556503, alpha: 1)
        subView.layer.cornerRadius = 20.0
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
