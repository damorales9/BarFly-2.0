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
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var following: UIButton!
    @IBOutlet weak var numFollowing: UILabel!
    @IBOutlet weak var followers: UIButton!
    @IBOutlet weak var numFollowers: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var barChoice: UIImageView!
    @IBOutlet weak var barChoiceLbl: UILabel!
    
    var centerConstraint: NSLayoutConstraint!
    var startingConstant: CGFloat  = -250
    
    
    override func viewDidLoad() {
        dragIndicator.layer.cornerRadius = 5
        follow.layer.cornerRadius = 10
        following.layer.cornerRadius = 10
        followers.layer.cornerRadius = 10
        fieldView.layer.cornerRadius = 30
        fieldView.layer.borderColor =  UIColor.barflyblue.cgColor
        fieldView.layer.borderWidth = 4
        follow.layer.borderColor = UIColor.black.cgColor
        follow.layer.borderWidth = 1
        
        numFollowing.text = "\(NonUserProfileVC.nonUser!.friends.count)"
        numFollowers.text = "\(0)"
        
        self.centerConstraint = fieldView.topAnchor.constraint(equalTo: view.bottomAnchor)
        self.centerConstraint.constant = startingConstant
        self.centerConstraint.isActive = true
        
        fieldView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
    
        if let user = NonUserProfileVC.nonUser {
            name.text = user.name
            username.text = user.username
            
            if((AppDelegate.user?.friends.contains(user.uid))!) {
                
                follow.setTitle("Unfollow", for: .normal);
                
                if(user.bar == "nil") {
                    barChoiceLbl.text = "\(user.name!) has not made a bar selection for tonight"
                } else {
                    barChoiceLbl.text = "\(user.name!) is going to \(user.bar!)!"
                   
                    let firestore = Firestore.firestore()
                    let userRef = firestore.collection("Bars")
                    let docRef = userRef.document("\(user.bar!)")
                    docRef.getDocument { (document, error) in
                            
                        if(error != nil) {
                            print("error bro")
                        } else {
                            let imageURL = document?.get("imageURL") as! String
                            
                            var placeholder: UIImage?
                            
                            if #available(iOS 13.0, *) {
                                placeholder = UIImage(systemName: "questionmark")
                            } else {
                                placeholder = UIImage(named: "first")
                            }
                            
                            let storage = Storage.storage()
                            let httpsReference = storage.reference(forURL: imageURL)
                            
                            self.barChoice.sd_setImage(with: httpsReference, placeholderImage: placeholder)
                                
                        }
                    }
                }
            } else if (!(AppDelegate.user?.friends.contains(user.uid))! && user.friends.contains(AppDelegate.user?.uid)) {
                
                follow.setTitle("Follow Back", for: .normal);
                
                barChoiceLbl.text = "Follow \(user.name!) back to see where they're going!"
            }
            
            let placeholder = UIImage( named: "person.circle.fill")
            
            
            print("profileURL is \(user.profileURL!)")
            
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
        
        
        following.addTarget(self, action: #selector(showFollowing), for: .touchUpInside)
        
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .began:
            self.startingConstant = self.centerConstraint.constant
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            self.centerConstraint.constant = self.startingConstant + translation.y
        case .ended:
            if(self.centerConstraint.constant < -350) {
                
                UIView.animate(withDuration: 0.3) {
                    self.centerConstraint.constant = -600
                    self.view.layoutIfNeeded()
                }
            } else {
                print("too low")
                
                UIView.animate(withDuration: 0.3) {
                    self.startingConstant = -250
                    self.centerConstraint.constant = self.startingConstant
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }

    }
    
    @objc func showFollowing() {
        print("show me following")
    }
    
    
    @IBAction func followButtonClicked(_ sender: Any) {
        
        if let user = User.updateUser(uid: NonUserProfileVC.nonUser!.uid!) {
            
            if((AppDelegate.user?.friends.contains(user.uid))!) {
                AppDelegate.user
            }
        
        }
        
    }
    
}

extension UIColor {
    static let barflyblue = UIColor(red: 0.71, green: 1.00, blue: 0.99, alpha: 1.0)
}
