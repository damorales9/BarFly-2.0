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
    
    override func viewDidLoad() {
        create.layer.cornerRadius = 10;
        
        self.hideKeyboardWhenTappedAround()
    }
}
