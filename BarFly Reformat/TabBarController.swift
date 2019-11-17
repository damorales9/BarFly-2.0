//
//  TabBarController.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/1/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class TabBarController: UITabBarController {
    
    var timer = Timer()
    
    override func viewDidLoad() {
        
        findAndUpdate()
        
//        scheduledTimerWithTimeInterval()
        
        //if there are requests we paint the number on the vc label
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func findAndUpdate() {
        for i in viewControllers! {
            if(i is ProfileVC) {
                (i as! ProfileVC).updateBadge()
            }
        }
    }
    
//    func scheduledTimerWithTimeInterval(){
//        // Scheduling timer to Call the function "updateUser" with the interval of 15 seconds
//        timer = Timer.scheduledTimer(timeInterval: 60*2, target: self, selector: #selector(self.updateUser), userInfo: nil, repeats: true)
//    }
//
//    @objc func updateUser() {
//
//        if(AppDelegate.loggedIn) {
//            User.getUser(uid: AppDelegate.user!.uid!) { (user: inout User?) in
//                AppDelegate.user = user!
//                self.findAndUpdate()
//            }
//        }
//    }
    
    
}
