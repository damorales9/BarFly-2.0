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
    
    override func viewDidLoad() {
        create.layer.cornerRadius = 10;
        email.layer.cornerRadius = 15;
        password.layer.cornerRadius = 15;
        name.layer.cornerRadius = 15;

        
        self.hideKeyboardWhenTappedAround()
    }
}
