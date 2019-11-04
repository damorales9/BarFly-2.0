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
    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var dragIndicator: UILabel!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var following: UIButton!
    @IBOutlet weak var numFollowing: UILabel!
    @IBOutlet weak var followers: UIButton!
    @IBOutlet weak var numFollowers: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    
    
    
    override func viewDidLoad() {
        dragIndicator.layer.cornerRadius = 5
        follow.layer.cornerRadius = 10
        following.layer.cornerRadius = 10
        followers.layer.cornerRadius = 10
        follow.layer.borderColor = UIColor.black.cgColor
        follow.layer.borderWidth = 1
        
        numFollowing.text = "\(NonUserProfileVC.nonUser!.friends.count)"
        numFollowers.text = "\(0)"
        
        fieldView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
    
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
    
    var initialCenter = CGPoint()
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
//        print(gestureRecognizer.translation(in: fieldView.superview).x)
//        if(gestureRecognizer.state == .began && fieldViewTopConstraint?.constant == -120) {
//            UIView.animate(withDuration: 0.5) {
//                self.fieldViewTopConstraint?.constant -= 40
//                self.view.layoutIfNeeded()
//            }
//        } else if (gestureRecognizer.state  == .ended && fieldViewTopConstraint?.constant == -160) {
//            if(gestureRecognizer.translation(in: fieldView.superview).x <= -10) {
//                UIView.animate(withDuration: 0.5) {
//                    self.fieldViewTopConstraint?.constant -= 300
//                    self.view.layoutIfNeeded()
//                }
//            }
//        } else if (gestureRecognizer.state == .ended && fieldViewTopConstraint?.constant == -460) {
//            if(gestureRecognizer.translation(in: fieldView.superview).x >= 10){
//                UIView.animate(withDuration: 0.5) {
//                    self.fieldViewTopConstraint?.constant += 340
//                    self.view.layoutIfNeeded()
//                }
//            }
//        }
      
        
        let piece = gestureRecognizer.view!
        // Get the changes in the X and Y directions relative to
        // the superview's coordinate space.
        let translation = gestureRecognizer.translation(in: piece.superview)
        if gestureRecognizer.state == .began {
           // Save the view's original position.
           self.initialCenter = piece.center
        }
        if(gestureRecognizer.state == .ended) {
            print("height is \(UIScreen.main.bounds.height)")
            if(piece.center.y < UIScreen.main.bounds.height) {
                print("going to main  - 500")
                UIView.animate(withDuration: 0.3) {
                    piece.center = CGPoint(x: self.initialCenter.x, y: UIScreen.main.bounds.height - 250)
                    piece.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    print("going to main  - 200")
                    piece.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height -  150)
                    piece.layoutIfNeeded()
                }
            }
        } else if gestureRecognizer.state != .cancelled {
           // Add the X and Y translation to the view's original position.
           let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)
           piece.center = newCenter
        }
        else {
           // On cancellation, return the piece to its original location.
           piece.center = initialCenter
        }

    }
}
