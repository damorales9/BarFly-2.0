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
    var startingConstant: CGFloat  = -200
    
    
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
    
        
        self.centerConstraint = fieldView.topAnchor.constraint(equalTo: view.bottomAnchor)
        self.centerConstraint.constant = startingConstant
        self.centerConstraint.isActive = true
        
        fieldView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
    
        if let user = NonUserProfileVC.nonUser {
            name.text = user.name
            username.text = user.username
            numFollowing.text = "\(user.friends.count)"
            getFollowers()
            
            updateFollowAndBarChoice()
            
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
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration:0.5, delay: 0.5, usingSpringWithDamping: 1,
        initialSpringVelocity: 0.2,
        options: .allowAnimatedContent,
        animations: {
            self.centerConstraint.constant = self.startingConstant - 20
            self.view.layoutIfNeeded()
        }, completion: { (value: Bool) in
            UIView.animate(withDuration: 0.2) {
                self.centerConstraint.constant = self.startingConstant
                self.view.layoutIfNeeded()
            }
        })
        
    }
    
    func getFollowers(){
        Firestore.firestore().collection(LoginVC.USER_DATABASE).whereField("friends", arrayContains: NonUserProfileVC.nonUser?.uid).getDocuments { (snapshot,err)in (snapshot, err)
            self.numFollowers.text = "\(snapshot!.documents.count)"
        }
    }
    
    
    func updateFollowAndBarChoice() {
        
        User.getUser(uid: NonUserProfileVC.nonUser!.uid!) { (user: inout User?) in
            
            NonUserProfileVC.nonUser = user!
    
            if let user = NonUserProfileVC.nonUser {
            
                if((AppDelegate.user?.friends.contains(user.uid))!) {
                    
                    self.follow.setTitle("Unfollow", for: .normal);
                    self.follow.backgroundColor = .red
                    
                    if(user.bar == "nil") {
                        self.barChoiceLbl.text = "\(user.name!) has not made a bar selection for tonight"
                    } else {
                        self.barChoiceLbl.text = "\(user.name!) is going to \(user.bar!)!"
                       
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
                    
                    self.follow.setTitle("Follow Back", for: .normal);
                    self.follow.backgroundColor = .barflyblue
                    
                    self.barChoiceLbl.text = "Follow \(user.name!) back to see where they're going!"
                } else if (!(AppDelegate.user?.friends.contains(user.uid))! && !user.friends.contains(AppDelegate.user?.uid) && !user.requests.contains(AppDelegate.user?.uid)) {
                    
                    self.follow.setTitle("Follow", for: .normal);
                    self.follow.backgroundColor = .barflyblue
                                   
                    self.barChoiceLbl.text = "Follow \(user.name!) to see where they're going!"
                    
                } else if (!(AppDelegate.user?.friends.contains(user.uid))! && !user.friends.contains(AppDelegate.user?.uid) && user.requests.contains(AppDelegate.user?.uid)) {
                    
                    self.follow.setTitle("Cancel Request", for: .normal);
                    self.follow.backgroundColor = .gray
                                                  
                    self.barChoiceLbl.text = "Once \(user.name!) accepts you can see where they're going!"
                    
                }
            }
        }
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
                    self.startingConstant = -200
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
        
        User.getUser(uid: NonUserProfileVC.nonUser!.uid!, setFunction: { (user: inout User?) -> Void in
            NonUserProfileVC.nonUser = user!
            
            if let user = NonUserProfileVC.nonUser {
                
                if ((AppDelegate.user?.friends.contains(user.uid))!) {
                    
                    let refreshAlert = UIAlertController(title: "Refresh", message: "\(user.username!) contributes to charity. Are you sure you want to unfollow them?", preferredStyle: UIAlertController.Style.alert)

                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        AppDelegate.user!.friends.remove(at: (AppDelegate.user!.friends.firstIndex(of: user.uid)!))
                        self.updateFollowAndBarChoice()
                        User.updateUser(user: AppDelegate.user)
                        User.updateUser(user: NonUserProfileVC.nonUser)
                    }))

                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                        print("Handle Cancel Logic here")
                    }))

                    self.present(refreshAlert, animated: true, completion: nil)
                    
                } else if (!(AppDelegate.user?.friends.contains(user.uid))! && !(user.requests.contains(AppDelegate.user?.uid))) {
                    
                    NonUserProfileVC.nonUser!.requests.append(AppDelegate.user?.uid)
                    
                } else if (!(AppDelegate.user?.friends.contains(user.uid))! &&  (user.requests.contains(AppDelegate.user?.uid))) {
                    
                    NonUserProfileVC.nonUser?.requests.remove(at: (user.requests.firstIndex(of: AppDelegate.user?.uid))!)
                   
                }
            
                self.updateFollowAndBarChoice()
                User.updateUser(user: AppDelegate.user)
                User.updateUser(user: NonUserProfileVC.nonUser)
            }
            
        })
        
    }
    
}

extension UIColor {
    static let barflyblue = UIColor(red: 0.71, green: 1.00, blue: 0.99, alpha: 1.0)
}
