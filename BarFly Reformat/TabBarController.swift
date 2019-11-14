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
        getBars()
        
//        scheduledTimerWithTimeInterval()
        
        //if there are requests we paint the number on the vc label
        findAndUpdate()
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
    
    func getBars(){
        let basicQuery = Firestore.firestore().collection("Bars").limit(to: 50)
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allBars = snapshot.documents
            for barDocument in allBars {
                let barId = barDocument.data()["id"] as? Int
                let name = barDocument.data()["name"] as? String
                let latitude = barDocument.data()["latitude"] as? Double
                let longitude = barDocument.data()["longitude"] as? Double
                let imageURL = barDocument.data()["imageURL"] as? String
                
                let bar = CustomBarAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
                bar.title = NSLocalizedString(name!, comment: name!)
                bar.imageName = imageURL!
                //print(bar.imageName as Any)
                //print(bar)
                FirstViewController.allBars.append(bar)
                //print(allBars)
                FirstViewController.allAnnotations.append(bar)
            }
        }
        
    }
}
