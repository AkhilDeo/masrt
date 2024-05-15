//
//  Keyboard.swift
//  ARPersistence
//
//  Created by Akhil Deo on 10/21/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyBoardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func hideKeyBoard() {
        self.view.endEditing(true)
    }
}
