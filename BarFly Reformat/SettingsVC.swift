//
//  SettingsVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/14/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: UITableViewController {
    
    @IBOutlet weak var logOutCell: UITableViewCell!
    @IBOutlet weak var privacy: UITableViewCell!
    @IBOutlet weak var security: UITableViewCell!
    
    override func viewDidLoad() {
        
        logOutCell.layer.borderWidth = 2
        logOutCell.layer.borderColor = UIColor.black.cgColor
        logOutCell.layer.cornerRadius = 10
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 2) {
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "password")
            AppDelegate.loggedIn = false
            AppDelegate.user = nil
            
        self.tabBarController?.navigationController?.popToRootViewController(animated: true)
            
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginVC
            self.tabBarController?.navigationController?.pushViewController(loginVC, animated:true)
        }
    }
    
}
