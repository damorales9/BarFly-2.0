//
//  LogOutVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/29/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit

class LogOutVC: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        progressView.progress = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        progressView.setProgress(1, animated: true)
        
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
        AppDelegate.user?.messagingID = ""
        User.updateUser(user: AppDelegate.user!)
        AppDelegate.loggedIn = false
        AppDelegate.user = nil
        self.tabBarController?.navigationController?.popToRootViewController(animated: true)
    }
}
