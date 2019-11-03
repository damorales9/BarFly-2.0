//
//  LoginVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 10/31/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginVC: UIViewController {
    
    /*
     * ----------------------------------
     * Constants
     * ----------------------------------
     */
    
    public static let NO_BAR = "nil"
    public static let NO_NAME = "nil"
    public static let NO_ADMIN = false
    public static let YES_ADMIN = true
    public static let END_REQUESTS = "end"
    public static let FIRST_FRIEND = "001"
    public static let USER_DATABASE = "User Info"
    
   /*
    * ----------------------------------
    * Non-UI Variables
    * ----------------------------------
    */
    var validEmail = false
    var validPassword = false
    
    /*
     * ----------------------------------
     * UI Variables
     * ----------------------------------
     */
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var create: UIButton!
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var errorLbl: UILabel!
    
    /*
     * ----------------------------------
     * Overriden Component Methods
     * ----------------------------------
     */
    
    override func viewDidLoad() {
        
        email.layer.cornerRadius = 15
        password.layer.cornerRadius = 15
        login.layer.cornerRadius = 10
        create.layer.cornerRadius = 10
        
        login.isEnabled = false

        email.addTarget(self, action: #selector(emailChange), for: UIControl.Event.editingChanged)
        
        password.addTarget(self, action: #selector(passwordChange), for: UIControl.Event.editingChanged)

        
        self.hideKeyboardWhenTappedAround()
        
        emailChange()
        passwordChange()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        if let email = UserDefaults.standard.string(forKey: "email"), let password = UserDefaults.standard.string(forKey: "password") {
            self.email.text = email
            self.password.text = password
            //login(email: email, password: password)
            
            enableDisableLogin()
        }
        
//      performSegue(withIdentifier: "hasLogin", sender: self)
      }
    
    /*
     * ----------------------------------
     * Obj-c Methods
     * ----------------------------------
     */
    
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
        //animate pw lbl
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
    
    func enableDisableLogin() {
        if(email.text!.contains("@") && email.text!.contains(".") && password.text!.count >= 6) {
                   print("enabled button")
                   login.isEnabled = true
               } else {
                   print("disabled button")
                   login.isEnabled = false
               }
           
    }
    
    /*
     * ----------------------------------
     * Outlet Methods
     * ----------------------------------
     */
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if let email =  email.text, let password = password.text {
            login(email: email, password: password)
        }
    }
    
    /*
     * ----------------------------------
     * Private Methods
     * ----------------------------------
     */
    
    func login(email: String, password: String) {
        
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                self.errorLbl.isHidden = false
                self.errorLbl.text = (error?.localizedDescription ?? "Unidentified Error")
                return
            } else {
            
            
                UserDefaults.standard.set(self.email.text, forKey: "email")
                UserDefaults.standard.set(self.password.text, forKey:  "password")
                
                let uid = Auth.auth().currentUser!.uid
                print("UID is \(uid)")
                let firestore = Firestore.firestore()
                let userRef = firestore.collection(LoginVC.USER_DATABASE)
                let docRef = userRef.document("\(uid)")
                docRef.getDocument { (document, error) in
                    
                    if(error != nil) {
                        self.errorLbl.isHidden = false
                        self.errorLbl.text = (error?.localizedDescription ?? "Unidentified Error")
                    } else {
            
                        let name = ((document!.get("name")) as! String)
                        let username = ((document!.get("username")) as! String)
                        let bar = ((document!.get("bar")) as! String)
                        let admin = ((document!.get("admin")) as! Bool)
                        let friends = ((document!.get("friends")) as! [String])
                        let requests = ((document!.get("requests")) as! [String])
                        let profileURL  = ((document!.get("profileURL")) as? String  ?? "")
                        AppDelegate.user = User(uid: uid, name: name, username: username, bar: bar, admin: admin, email: email, friends: friends, requests: requests, profileURL: profileURL)
                        }
                }
                self.performSegue(withIdentifier: "hasLogin", sender: self)
                
            }
            
        })
        

    }
    
}


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
