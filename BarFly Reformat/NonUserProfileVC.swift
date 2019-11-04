//
//  NonUserProfile.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/3/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseUI

class NonUserProfileVC: UIViewController {
    
    
    
    static var nonUser: User?
    
    @IBOutlet weak var dragIndicator: UILabel!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var username: UITextField!
    
    var fieldViewTopConstraint: NSLayoutConstraint?
    
    
    override func viewDidLoad() {
        dragIndicator.layer.cornerRadius = 5
        
        fieldView.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.75)
        
        fieldViewTopConstraint = NSLayoutConstraint(item: fieldView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -120)
        view.addConstraint(fieldViewTopConstraint!)
        
        if let user = NonUserProfileVC.nonUser {
            name.text = user.name
            username.text = user.username
            
            let placeholder = UIImage( named: "person.circle.fill")
            
            
            print("profileURL is \(user.profileURL)")
            
            if (user.profileURL != "") {
                
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk()
                
                let storage = Storage.storage()
                let httpsReference = storage.reference(forURL: user.profileURL!)
                
                self.profileImage.sd_setImage(with: httpsReference, placeholderImage: placeholder)
            
                    
            } else {
                self.profileImage.image = placeholder
            }

        }
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        fieldView.addGestureRecognizer(gesture)
        fieldView.isUserInteractionEnabled = true
        
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        print(gestureRecognizer.translation(in: fieldView.superview).x)
        if(gestureRecognizer.state == .began && fieldViewTopConstraint?.constant == -120) {
            UIView.animate(withDuration: 0.5) {
                self.fieldViewTopConstraint?.constant -= 40
                self.view.layoutIfNeeded()
            }
        } else if (gestureRecognizer.state  == .ended && fieldViewTopConstraint?.constant == -160) {
            if(gestureRecognizer.translation(in: fieldView.superview).x <= -10) {
                UIView.animate(withDuration: 0.5) {
                    self.fieldViewTopConstraint?.constant -= 300
                    self.view.layoutIfNeeded()
                }
            }
        } else if (gestureRecognizer.state == .ended && fieldViewTopConstraint?.constant == -460) {
            if(gestureRecognizer.translation(in: fieldView.superview).x >= 10){
                UIView.animate(withDuration: 0.5) {
                    self.fieldViewTopConstraint?.constant += 340
                    self.view.layoutIfNeeded()
                }
            }
        }

    }
}
