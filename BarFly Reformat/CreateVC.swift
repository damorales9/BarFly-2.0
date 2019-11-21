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

class CreateVC: UIViewController, UITextFieldDelegate {
    
    //VARS
    
    
    
    //UI
    @IBOutlet weak var create: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    
   
    var nC: NSLayoutConstraint?
    var uC: NSLayoutConstraint?
    var eC: NSLayoutConstraint?
     var pwC: NSLayoutConstraint?

    
    override func viewDidLoad() {
        create.layer.cornerRadius = 10
        email.layer.cornerRadius = 15
        password.layer.cornerRadius = 15
        name.layer.cornerRadius = 15
        username.layer.cornerRadius = 15
        
        create.layer.borderColor = UIColor.black.cgColor
        create.layer.borderWidth = 3

        
        name.addTarget(self, action: #selector(nameChange), for: UIControl.Event.editingChanged)
        
        email.addTarget(self, action: #selector(emailChange), for: UIControl.Event.editingChanged)
        
        password.addTarget(self, action: #selector(passwordChange), for: UIControl.Event.editingChanged)
        
        username.addTarget(self, action: #selector(usernameChange), for: UIControl.Event.editingChanged)
        
       
        
        username.addTarget(self, action: #selector(uEdit), for: .editingDidBegin)
        username.addTarget(self, action: #selector(uEditOver), for: .editingDidEnd)
        
        name.addTarget(self, action: #selector(nEdit), for: .editingDidBegin)
        name.addTarget(self, action: #selector(nEditOver), for: .editingDidEnd)
        
        email.addTarget(self, action: #selector(eEdit), for: .editingDidBegin)
        email.addTarget(self, action: #selector(eEditOver), for: .editingDidEnd)
        
        password.addTarget(self, action: #selector(pwEdit), for: .editingDidBegin)
               password.addTarget(self, action: #selector(pwEditOver), for: .editingDidEnd)
        
        create.isEnabled = false
        errorLbl.isHidden = true
        
        emailChange()
        passwordChange()
        nameChange()
        usernameChange()
        
        password.delegate = self
        email.delegate  = self
        username.delegate = self
        name.delegate = self
        
        name.tag = 0
        username.tag = 1
        email.tag = 2
        password.tag = 3
        
        pwC = password.bottomAnchor.constraint(equalTo: view.centerYAnchor)
        pwC!.constant = 130
        view.addConstraint(pwC!)
//
        nC = name.bottomAnchor.constraint(equalTo: view.centerYAnchor)
        nC!.constant = -80
        view.addConstraint(nC!)
//
        uC = username.bottomAnchor.constraint(equalTo: view.centerYAnchor)
        uC!.constant = -10
        view.addConstraint(uC!)
//
        eC = email.bottomAnchor.constraint(equalTo: view.centerYAnchor)
        eC!.constant = 60
        view.addConstraint(eC!)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @objc func pwEdit() {
        UIView.animate(withDuration: 0.3) {
            self.pwC?.constant = -50
            self.hideLblAndField(field: self.username, lbl: self.usernameLbl)
            self.hideLblAndField(field: self.email, lbl: self.emailLbl)
            self.hideLblAndField(field: self.name, lbl: self.nameLbl)
            self.view.layoutIfNeeded()
        }
    }
    
    func hideLblAndField(field: UITextField, lbl: UILabel) {
        field.alpha -= 1
        lbl.alpha -= 1
    }
    
    func showLblAndField(field: UITextField, lbl: UILabel) {
        lbl.alpha += 1
        field.alpha += 1
    }
    
    @objc func pwEditOver() {
        UIView.animate(withDuration: 0.3) {
            self.pwC?.constant = 130
            self.showLblAndField(field: self.username, lbl: self.usernameLbl)
            self.showLblAndField(field: self.email, lbl: self.emailLbl)
            self.showLblAndField(field: self.name, lbl: self.nameLbl)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func uEdit() {
        UIView.animate(withDuration: 0.3) {
            self.uC?.constant = -50
            self.hideLblAndField(field: self.password, lbl: self.passwordLbl)
            self.hideLblAndField(field: self.email, lbl: self.emailLbl)
            self.hideLblAndField(field: self.name, lbl: self.nameLbl)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func uEditOver() {
        UIView.animate(withDuration: 0.3) {
            self.uC?.constant = -10
            self.showLblAndField(field: self.password, lbl: self.passwordLbl)
            self.showLblAndField(field: self.email, lbl: self.emailLbl)
            self.showLblAndField(field: self.name, lbl: self.nameLbl)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func nEdit() {
        UIView.animate(withDuration: 0.3) {
            self.nC?.constant = -50
            self.hideLblAndField(field: self.password, lbl: self.passwordLbl)
            self.hideLblAndField(field: self.email, lbl: self.emailLbl)
            self.hideLblAndField(field: self.username, lbl: self.usernameLbl)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func nEditOver() {
        UIView.animate(withDuration: 0.3) {
            self.nC?.constant = -80
            self.showLblAndField(field: self.password, lbl: self.passwordLbl)
            self.showLblAndField(field: self.email, lbl: self.emailLbl)
            self.showLblAndField(field: self.username, lbl: self.usernameLbl)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func eEdit() {
        UIView.animate(withDuration: 0.3) {
            self.eC?.constant = -50
            self.hideLblAndField(field: self.password, lbl: self.passwordLbl)
            self.hideLblAndField(field: self.name, lbl: self.nameLbl)
            self.hideLblAndField(field: self.username, lbl: self.usernameLbl)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func eEditOver() {
        UIView.animate(withDuration: 0.3) {
            self.eC?.constant = 60
            self.showLblAndField(field: self.password, lbl: self.passwordLbl)
            self.showLblAndField(field: self.name, lbl: self.nameLbl)
            self.showLblAndField(field: self.username, lbl: self.usernameLbl)
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
    func enableDisableLogin() {
        if((email.text?.isValidEmail())! && password.text!.count >= 6 && name.text!.count > 0  && username.text!.count > 0 && !username.text!.contains(" ")) {
                   create.isEnabled = true
               } else {
                   create.isEnabled = false
               }
           
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       // Try to find next responder
       if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
       } else {
          // Not found, so remove keyboard.
          textField.resignFirstResponder()
       }
       // Do not add a line break
       return false
    }
    
    @objc func usernameChange() {
        //animate email lbl
        
        errorLbl.isHidden = true
        enableDisableLogin()
    }
    
    @objc func emailChange() {
        
        //animate email lbl
        
        errorLbl.isHidden = true
        enableDisableLogin()
    
    }
    
    @objc func passwordChange() {
        
        //animate email lbl
        
        errorLbl.isHidden = true
        enableDisableLogin()
    
    }
    
    @objc func nameChange() {
        
        //animate email lbl
        
    }
    
    @IBAction func createClicked(_ sender: Any) {
        if let email = email.text, let password = password.text, let name = name.text{
            
            if let username = username.text {
                
                let db = Firestore.firestore()
                db.collection(LoginVC.USER_DATABASE).whereField("username", isEqualTo: username)
                  .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        self.errorLbl.text = "Error getting documents: \(err)"
                        self.errorLbl.isHidden = false
                        return
                    } else {
                        if(querySnapshot?.documents.count == 0) {
                        
                            //once username is verified as valid
                            
                            Auth.auth().createUser(withEmail: email, password: password, completion: { user, error in
                                
                                if error != nil {
                                     self.errorLbl.text = error?.localizedDescription
                                 self.errorLbl.isHidden = false
                                } else {
                                    
                                UserDefaults.standard.set(self.email.text, forKey: "email")
                                UserDefaults.standard.set(self.password.text, forKey:  "password")
                                 
                                let bar = LoginVC.NO_BAR
                                let admin = LoginVC.NO_ADMIN
                                let friends = [String]()
                                let requests = [String]()
                                let favorites = [String]()
                                let followers = [String]()
                                let blocked = [String]()
                                let timestamp = NSNumber(integerLiteral: 0)
                                     
                                    AppDelegate.user = User(uid: Auth.auth().currentUser!.uid,name: name, username: username, bar: bar, timestamp: timestamp, admin: admin, email: email, friends: friends, followers: followers, blocked: blocked, requests: requests, favorites: favorites, profileURL: "")
                                }
                                AppDelegate.loggedIn = true
                                User.updateUser(user: AppDelegate.user)
                                
                                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                                let tabVC = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                                self.navigationController?.pushViewController(tabVC, animated:true)
                                
                            })
                            
                            
                            
                        }  else {
                            self.errorLbl.text = "Username is taken"
                            self.errorLbl.isHidden = false
                            return
                        }
                    }
                }
            }
                   
                   
        }
    }
    
    func updateUIDatabase() {
           
           
        if let user = AppDelegate.user {
               
               //Adding uid to databse if first time login
               
               var beenAdded = false
               let db = Firestore.firestore()
               db.collection(LoginVC.USER_DATABASE).getDocuments { (snapshot, error) in
                   
                   if error != nil {
                        self.errorLbl.text = "Error when getting UID list from firebase"
                        self.errorLbl.isHidden = false
                        return
                   }
                   
                   for document in (snapshot?.documents)!{
                       if user.uid == document.documentID {
                           beenAdded = true
                       }
                   }
                   
                   if !beenAdded {
                       
                    print("It hasnt been added")
                       
                       let docData: [String: Any] = [
                        "uid" : user.uid!,
                           "name": user.name ?? "",
                           "bar" : user.bar ?? "nil",
                           "username" : user.username!,
                           "admin" : user.admin ?? false,
                           "profileURL": user.profileURL ?? "",
                           "email": user.email!,
                           "friends": user.friends,
                           "requests":user.requests
                       ]
                    print(docData)
                       
                       db.collection(LoginVC.USER_DATABASE).document(user.uid!).setData(docData) { err in
                           if let err = err {
                                self.errorLbl.text = "There was a fuqing error with adding the uid to the db \(err)"
                                self.errorLbl.isHidden = false
                                return 
                           }
                       }
                       
                       
                   }
                
                self.performSegue(withIdentifier: "wasCreated", sender: self)
                
               }
           }
       }
}
