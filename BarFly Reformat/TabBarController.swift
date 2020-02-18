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
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Roboto-Light", size: 20)!]
        
        findAndUpdate()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        findAndUpdate()
        
    }
    
    func findAndUpdate() {
        for i in viewControllers! {
            if((i as! UINavigationController).viewControllers[0] is ProfileVC) {
                ((i as! UINavigationController).viewControllers[0] as! ProfileVC).updateBadge()
            }
        }
    }
    
//    func scheduledTimerWithTimeInterval(){
//        // Scheduling timer to Call the function "updateUser" with the interval of 15 seconds
//        timer = Timer.scheduledTimer(timeInterval: 60*2, target: self, selector: #selector(self.updateUser), userInfo: nil, repeats: true)
//    }
//
    
    func checkForNewRequests() {
           
        
        
    }
    
    
}
