//
//  RequestCellView.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/13/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit

class RequestCellView: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var accept: UIButton!
    @IBOutlet weak var decline: UIButton!
}
