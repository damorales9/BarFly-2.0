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
    @IBOutlet weak var blockedCell: UITableViewCell!
    
    override func viewDidLoad() {
        
        logOutCell.layer.borderWidth = 2
        logOutCell.layer.borderColor = UIColor.black.cgColor
        logOutCell.layer.cornerRadius = 10
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
