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
    
    @IBOutlet weak var emailLbl: UILabel!
    
    
    override func viewDidLoad() {
        email.layer.cornerRadius = 15;
        password.layer.cornerRadius = 15;
        login.layer.cornerRadius = 10;
        create.layer.cornerRadius = 10;
        
        emailLbl.isOpaque = true
        emailLbl.alpha = 0
        
        email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

        
        self.hideKeyboardWhenTappedAround()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if(self.email.text!.count > 0 && emailLbl.alpha == 0) {
            UIView.animate(withDuration: 1) {
                self.emailLbl.alpha += 1
            }
        }
        else if(self.email.text!.count == 0 && emailLbl.alpha == 1) {
            UIView.animate(withDuration: 1) {
                self.emailLbl.alpha -= 1
            }
        }
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
