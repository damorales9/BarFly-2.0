//
//  PregameRequestCell.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 2/24/20.
//  Copyright © 2020 LoFi Games. All rights reserved.
//


import Foundation
import UIKit

class PregameRequestCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var pregame: UILabel!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var accept: UIButton!
    @IBOutlet weak var decline: UIButton!
}
