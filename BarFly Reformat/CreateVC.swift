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
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    
    override func viewDidLoad() {
        create.layer.cornerRadius = 10
        email.layer.cornerRadius = 15
        password.layer.cornerRadius = 15
        name.layer.cornerRadius = 15
        username.layer.cornerRadius = 15

        
        name.addTarget(self, action: #selector(nameChange), for: UIControl.Event.editingChanged)
        
        email.addTarget(self, action: #selector(emailChange), for: UIControl.Event.editingChanged)
        
        password.addTarget(self, action: #selector(passwordChange), for: UIControl.Event.editingChanged)
        
        username.addTarget(self, action: #selector(usernameChange), for: UIControl.Event.editingChanged)
        
        create.isEnabled = false
        errorLbl.isHidden = true
        
        emailChange()
        passwordChange()
        nameChange()
        usernameChange()
        
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func enableDisableLogin() {
        if(email.text!.contains("@") && email.text!.contains(".") && password.text!.count >= 6 && name.text!.count > 0  && username.text!.count > 0 && !username.text!.contains(" ")) {
                   create.isEnabled = true
               } else {
                   create.isEnabled = false
               }
           
    }
    
    @objc func usernameChange() {
        //animate email lbl
        if(self.username.text!.count > 0 && usernameLbl.alpha == 0) {
            UIView.animate(withDuration: 1) {
                self.usernameLbl.alpha += 1
            }
        }
        else if(self.username.text!.count == 0 && usernameLbl.alpha == 1) {
            
            UIView.animate(withDuration: 1) {
                self.usernameLbl.alpha -= 1
            }
        }
        
        errorLbl.isHidden = true
        enableDisableLogin()
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
        
        errorLbl.isHidden = true
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
        
        errorLbl.isHidden = true
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
                                     
                                    AppDelegate.user = User(uid: Auth.auth().currentUser!.uid,name: name, username: username, bar: bar, admin: admin, email: email, friends: friends, requests: requests, profileURL: "")
                                    }
                                    
                                
                                    self.updateUIDatabase()
                                
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
