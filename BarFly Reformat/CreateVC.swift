//
//  CreateVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/1/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

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
    @IBOutlet weak var errorLbl: UILabel!
    
    override func viewDidLoad() {
        create.layer.cornerRadius = 10;
        email.layer.cornerRadius = 15;
        password.layer.cornerRadius = 15;
        name.layer.cornerRadius = 15;

        
        name.addTarget(self, action: #selector(nameChange), for: UIControl.Event.editingChanged)
        
        email.addTarget(self, action: #selector(emailChange), for: UIControl.Event.editingChanged)
        
        password.addTarget(self, action: #selector(passwordChange), for: UIControl.Event.editingChanged)
        
        create.isEnabled = false
        errorLbl.isHidden = true
        
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func enableDisableLogin() {
        if(email.text!.contains("@") && email.text!.contains(".") && password.text!.count >= 6 && name.text!.count > 0) {
                   print("enabled button")
                   create.isEnabled = true
               } else {
                   print("disabled button")
                   create.isEnabled = false
               }
           
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
        
        enableDisableLogin()
    
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
        
        enableDisableLogin()
    
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
    
    @IBAction func createClicked(_ sender: Any) {
        if let email = email.text, let password = password.text {
                   
                   Auth.auth().createUser(withEmail: email, password: password, completion: { user, error in
                       
                       if error != nil {
                            self.errorLbl.text = error?.localizedDescription
                       } else {
                           
                        UserDefaults.standard.set(self.email.text, forKey: "email")
                        UserDefaults.standard.set(self.password.text, forKey:  "password")
                           
                           var uid = Auth.auth().currentUser!.uid
                           let firestore = Firestore.firestore()
                           var userRef = firestore.collection(LoginVC.USER_DATABASE)
                           var docRef = userRef.document("\(uid)")
                           docRef.getDocument { (document, error) in
                               let name = LoginVC.NO_NAME
                               let bar = LoginVC.NO_BAR
                               let admin = LoginVC.NO_ADMIN
                               var friends = [String]()
                                var requests = 
                               friends.append(LoginVC.FIRST_FRIEND)
                            AppDelegate.user = User(uid:uid,name:name, bar:bar, admin:admin, friends:friends, requests: )
                           }
                           
                       
                           self.updateUIDatabase()
                       }
                       
                   })
               }
    }
}
