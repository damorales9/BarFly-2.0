//
//  CreateVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/1/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit

class CreateVC: UIViewController {
    
    //VARS
    
    
    
    //UI
    @IBOutlet weak var create: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    
    override func viewDidLoad() {
        create.layer.cornerRadius = 10;
        email.layer.cornerRadius = 15;
        password.layer.cornerRadius = 15;
        name.layer.cornerRadius = 15;

        
        name.addTarget(self, action: #selector(nameChange), for: UIControl.Event.editingChanged)
        
        email.addTarget(self, action: #selector(emailChange), for: UIControl.Event.editingChanged)
        
        password.addTarget(self, action: #selector(passwordChange), for: UIControl.Event.editingChanged)
        
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @objc func emailChange() {
        
        //animate email lbl
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
    
    @objc func passwordChange() {
        
        //animate email lbl
        if(self.password.text!.count > 0 && passwordLbl.alpha == 0) {
            UIView.animate(withDuration: 1) {
                self.passwordLbl.alpha += 1
            }
        }
        else if(self.password.text!.count == 0 && passwordLbl.alpha == 1) {
            
            UIView.animate(withDuration: 1) {
                self.passwordLbl.alpha -= 1
            }
        }
    
    }
    
    @objc func nameChange() {
        
        //animate email lbl
        if(self.name.text!.count > 0 && nameLbl.alpha == 0) {
            UIView.animate(withDuration: 1) {
                self.nameLbl.alpha += 1
            }
        }
        else if(self.name.text!.count == 0 && nameLbl.alpha == 1) {
            
            UIView.animate(withDuration: 1) {
                self.nameLbl.alpha -= 1
            }
        }
    
    }
}
