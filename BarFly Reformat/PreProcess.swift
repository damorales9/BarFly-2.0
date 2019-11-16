//
//  PreProcess.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/15/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit

class PreProcess: UIViewController {
    
    override func viewDidLoad() {
        print("ATTEMPTING TO LOGIN")
        if let email = UserDefaults.standard.string(forKey: "email"), let password = UserDefaults.standard.string(forKey: "password") {
            LoginVC.login(email: email, password: password, completion: {
                print("LOGGED IN")
                self.navigationController?.popViewController(animated: true)
                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                let tabVC = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                self.navigationController?.pushViewController(tabVC, animated:true)
        
            }) { (error) in
                print("NEEDS LOGIN")
                self.navigationController?.popViewController(animated: true)
                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginVC
                self.navigationController?.pushViewController(loginVC, animated:true)
            }
        } else {
            print("needs login")
            self.navigationController?.popViewController(animated: true)
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginVC
            self.navigationController?.pushViewController(loginVC, animated:true)
        }
    }
}
