//
//  LoginVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 10/31/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit

class LoginVC: UIViewController {
    
    //VAR
    
    
    
    //UI
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var create: UIButton!
    
    override func viewDidLoad() {
        login.layer.cornerRadius = 10;
        create.layer.cornerRadius = 10;
        
        
        self.hideKeyboardWhenTappedAround()
    }
    
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
