//
//  EditProfileVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/15/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveButtonView: UIView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        
        saveButton.layer.cornerRadius = 5
        saveButtonView.layer.cornerRadius = 5
        saveButton.layer.borderColor = UIColor.black.cgColor
        saveButton.layer.borderWidth = 2
        
        name.layer.cornerRadius = 2
        name.layer.borderWidth = 1
        name.layer.borderColor = UIColor.barflyblue.cgColor
        
        username.layer.cornerRadius = 2
        username.layer.borderWidth = 1
        username.layer.borderColor = UIColor.barflyblue.cgColor
        
        email.layer.cornerRadius = 2
        email.layer.borderWidth = 1
        email.layer.borderColor = UIColor.barflyblue.cgColor
        
        password.layer.cornerRadius = 2
        password.layer.borderWidth = 1
        password.layer.borderColor = UIColor.barflyblue.cgColor
        
    }
        
    override func viewDidAppear(_ animated: Bool) {
        User.getUser(uid: AppDelegate.user!.uid!) { (user: User?) in
            
            AppDelegate.user = user!
            
            self.name.text =  AppDelegate.user?.name
            self.username.text = AppDelegate.user?.username
            self.email.text =  AppDelegate.user?.email
            self.password.text = UserDefaults.standard.string(forKey: "password")
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
    }
    
    func saveProfile() {
        
        User.getUser(uid: AppDelegate.user!.uid!) { (user: User?) in
            AppDelegate.user = user!
            
            
            if let username = self.username.text, let password = self.password.text , let email = self.email.text{
                Firestore.firestore().collection(LoginVC.USER_DATABASE).whereField("username", isEqualTo: self.username.text!)
                .getDocuments() { (querySnapshot, err) in
                    if(querySnapshot?.documents.count == 0) {
                        
                        if(password.count >= 6) {
                            
                            if(email.isValidEmail()) {
                                
                                AppDelegate.user?.username = username
                                AppDelegate.user?.name = self.name.text
                                AppDelegate.user?.email = email
                                
                                Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                                    if(error == nil) {
                                        UserDefaults.standard.set(password, forKey: "password")
                                    } else {
                                        self.password.text = UserDefaults.standard.string(forKey: "password")
                                    }
                                }
                                Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
                                    if(error == nil) {
                                        UserDefaults.standard.set(email, forKey: "email")
                                    } else {
                                        self.email.text = UserDefaults.standard.string(forKey: "email")
                                    }
                                })
                                
                                User.updateUser(user: AppDelegate.user!)
                                self.dismiss(animated: true)
                            } else {
                                self.errorLabel.text = "This email is not valid"
                            }
                
                        } else {
                            self.errorLabel.text = "This password is not long enough"
                        }
                    
                    } else {
                        self.errorLabel.text =  "This username is taken"
                    }
                    
                    
                }
            }
            
            
            
        }
    }
}
