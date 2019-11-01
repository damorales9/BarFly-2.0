//
//  User.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 10/31/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct User {
    var uid:String?
    var name:String?
    var bar:String?
    var admin:Bool?
    var email: String?
    var friends: [String?]
    var requests: [String?]
    var profileURL: String?

}
