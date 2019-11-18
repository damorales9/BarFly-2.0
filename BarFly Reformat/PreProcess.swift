//
//  PreProcess.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/15/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import FirebaseFirestore

class PreProcess: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        progressView.progress = 0
        progressView.layer.cornerRadius  = 6
        
        self.label.text = "Getting Bars..."
        let basicQuery = Firestore.firestore().collection("Bars").limit(to: 50)
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allBars = snapshot.documents
            for barDocument in allBars {
                let amntPeople = barDocument.data()["amountPeople"] as? Int
                let name = barDocument.data()["name"] as? String
                let latitude = barDocument.data()["latitude"] as? Double
                let longitude = barDocument.data()["longitude"] as? Double
                let imageURL = barDocument.data()["imageURL"] as? String
                let url = barDocument.data()["url"] as? String
                
                let bar = CustomBarAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
                bar.title = NSLocalizedString(name!, comment: name!)
                bar.imageName = imageURL!
                bar.amntPeople = amntPeople
                bar.url = url
                //print(bar.imageName as Any)
                //print(bar)
                FirstViewController.allBars.append(bar)
                //print(allBars)
                FirstViewController.allAnnotations.append(bar)
            }
            
            print("ATTEMPTING TO LOGIN")
            self.label.text = "Logging you in..."
                   if let email = UserDefaults.standard.string(forKey: "email"), let password = UserDefaults.standard.string(forKey: "password") {
                       UIView.animate(withDuration: 0.3) {
                           self.progressView.progress = 0.75
                           self.view.layoutIfNeeded()
                       }
                       LoginVC.login(email: email, password: password, completion: {
                           UIView.animate(withDuration: 0.3) {
                               self.progressView.progress = 1
                               self.view.layoutIfNeeded()
                           }
                           print("LOGGED IN")
                           self.navigationController?.popViewController(animated: true)
                           let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                           let tabVC = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                           self.navigationController?.pushViewController(tabVC, animated:true)
                   
                       }) { (error) in
                           UIView.animate(withDuration: 0.3) {
                               self.progressView.progress = 1
                               self.view.layoutIfNeeded()
                           }
                           print("NEEDS LOGIN")
                           self.navigationController?.popViewController(animated: true)
                           let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                           let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginVC
                           self.navigationController?.pushViewController(loginVC, animated:true)
                       }
                   } else {
                       UIView.animate(withDuration: 0.3) {
                           self.progressView.progress = 1
                           self.view.layoutIfNeeded()
                       }
                       print("needs login")
                       self.navigationController?.popViewController(animated: true)
                       let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                       let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginVC
                       self.navigationController?.pushViewController(loginVC, animated:true)
                   }
        }
        
       
            
        
       
    }
}
