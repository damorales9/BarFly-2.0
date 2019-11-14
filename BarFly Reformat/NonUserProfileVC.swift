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
    
    var confirm = false

    
    @IBOutlet weak var dragIndicator: UILabel!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var block: UIButton!
    @IBOutlet weak var cancelBlock: UIButton!
    @IBOutlet weak var following: UIButton!
    @IBOutlet weak var numFollowing: UILabel!
    @IBOutlet weak var followers: UIButton!
    @IBOutlet weak var numFollowers: UILabel!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var followView: UIView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var barChoice: UIImageView!
    @IBOutlet weak var barChoiceLbl: UILabel!
    
    var centerConstraint: NSLayoutConstraint!
    var startingConstant: CGFloat  = -200
    
    
    var trailingFollowConstraint: NSLayoutConstraint!
    
    var cancelWidthConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        dragIndicator.layer.cornerRadius = 5
        follow.layer.cornerRadius = 10
        following.layer.cornerRadius = 10
        followers.layer.cornerRadius = 10
        fieldView.layer.cornerRadius = 30
        fieldView.layer.borderColor =  UIColor.barflyblue.cgColor
        fieldView.layer.borderWidth = 4
        follow.layer.borderColor = UIColor.black.cgColor
        follow.layer.borderWidth = 2
        block.layer.borderColor = UIColor.barflyblue.cgColor
        block.layer.borderWidth = 2
        block.layer.cornerRadius = 10
        cancelBlock.layer.cornerRadius = 10
        cancelBlock.layer.borderWidth = 2
        cancelBlock.layer.borderColor = UIColor.black.cgColor
        cancelView.layer.cornerRadius = 10
        blockView.layer.cornerRadius = 10
        followView.layer.cornerRadius = 10

        
        trailingFollowConstraint = NSLayoutConstraint(item: blockView!, attribute: .trailing, relatedBy: .equal, toItem: follow, attribute: .trailing, multiplier: 1, constant: 0)
        
        cancelWidthConstraint = NSLayoutConstraint(item: cancelView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        
        cancelView.addConstraint(cancelWidthConstraint)
        
        view.addConstraint(trailingFollowConstraint)
        
        self.centerConstraint = fieldView.topAnchor.constraint(equalTo: view.bottomAnchor)
        self.centerConstraint.constant = startingConstant
        self.centerConstraint.isActive = true
        
        fieldView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
    
        if let user = NonUserProfileVC.nonUser {
            
            updateFieldView()
            
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
    
    
    func updateFieldView() {
        
        User.getUser(uid: AppDelegate.user!.uid!) { (user: inout User?) in
            AppDelegate.user = user!
        
            User.getUser(uid: NonUserProfileVC.nonUser!.uid!) { (user: inout User?) in
                
                NonUserProfileVC.nonUser = user!
        
                if let user = NonUserProfileVC.nonUser {
                    
                    self.name.text = user.name
                    self.username.text = user.username
                    self.numFollowing.text = "\(user.friends.count)"
                    self.getFollowers()
                    
                    if(user.friends.contains(AppDelegate.user?.uid)) {
                        self.blockView.isHidden = false
                    }  else {
                        self.blockView.isHidden = true
                    }
                    
                    var placeholder: UIImage?
                    if #available(iOS 13.0, *) {
                        placeholder = UIImage(systemName: "questionmark")
                    } else {
                        // Fallback on earlier versions
                        placeholder = UIImage(named: "profile")
                    }
                    self.barChoice.image = placeholder
                    
                
                    if((AppDelegate.user?.friends.contains(user.uid))!) {
                        
                        self.follow.setTitle("Unfollow", for: .normal);
                        self.follow.backgroundColor = .red
                        self.followView.backgroundColor = .red
                        
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
                    } else if (user.friends.contains(AppDelegate.user?.uid) && !user.requests.contains(AppDelegate.user?.uid)) {
                        
                        self.follow.setTitle("Follow Back", for: .normal);
                        self.follow.backgroundColor = .barflyblue
                        self.followView.backgroundColor = .barflyblue
                        
                        self.barChoiceLbl.text = "Follow \(user.name!) back to see where they're going!"
                    } else if (!user.friends.contains(AppDelegate.user?.uid) && !user.requests.contains(AppDelegate.user?.uid)) {
                        
                        self.follow.setTitle("Follow", for: .normal);
                        self.follow.backgroundColor = .barflyblue
                        self.followView.backgroundColor = .barflyblue
                                       
                        self.barChoiceLbl.text = "Follow \(user.name!) to see where they're going!"
                        
                    } else if (user.requests.contains(AppDelegate.user?.uid)) {
                        
                        self.follow.setTitle("Cancel Request", for: .normal);
                        self.follow.backgroundColor = .gray
                        self.followView.backgroundColor = .gray
                                                      
                        self.barChoiceLbl.text = "Once \(user.name!) accepts you can see where they're going!"
                        
                    }
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
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        confirm = false
        
        UIView.animate(withDuration: 0.5) {
            self.trailingFollowConstraint.constant = 0
            self.cancelView.isHidden = true
            self.cancelWidthConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func blockButtonClicked(_ sender: Any) {
        
        if(confirm) {
            
            User.getUser(uid: NonUserProfileVC.nonUser!.uid!, setFunction: { (user: inout User?) -> Void in

                user!.friends.remove(at: user!.friends.firstIndex(of: AppDelegate.user?.uid)!)
                User.updateUser(user: user)
                
                
                self.updateFieldView()
                
                UIView.animate(withDuration: 0.5) {
                    self.trailingFollowConstraint.constant = 0
                    self.cancelView.isHidden = true
                    self.cancelWidthConstraint.constant = 0
                    self.view.layoutIfNeeded()
                    
                }
                self.confirm = false

            })
            
        } else {
            
            UIView.animate(withDuration: 0.5) {
                self.trailingFollowConstraint.constant = -60
                self.cancelView.isHidden = false
                self.cancelWidthConstraint.constant = 50
                self.view.layoutIfNeeded()
                
            }
            confirm = true
        }
    }
    
    @IBAction func followButtonClicked(_ sender: Any) {
        
        User.getUser(uid: NonUserProfileVC.nonUser!.uid!, setFunction: { (user: inout User?) -> Void in
            NonUserProfileVC.nonUser = user!
            
            if let user = NonUserProfileVC.nonUser {
                
                if ((AppDelegate.user?.friends.contains(user.uid))!) {
                    
                    self.okCancel(msg: "\(user.username!) contributes to charity. Are you sure you want to unfollow them?", after: { () -> Void in
                        
                        AppDelegate.user!.friends.remove(at: (AppDelegate.user!.friends.firstIndex(of: user.uid)!))
                        self.updateFieldView()
                        User.updateUser(user: AppDelegate.user)
                        User.updateUser(user: NonUserProfileVC.nonUser)
                            
                    })
                    
                } else if (!(AppDelegate.user?.friends.contains(user.uid))! && !(user.requests.contains(AppDelegate.user?.uid))) {
                    
                    NonUserProfileVC.nonUser!.requests.append(AppDelegate.user?.uid)
                    
                } else if (!(AppDelegate.user?.friends.contains(user.uid))! &&  (user.requests.contains(AppDelegate.user?.uid))) {
                    
                    NonUserProfileVC.nonUser?.requests.remove(at: (user.requests.firstIndex(of: AppDelegate.user?.uid))!)
                   
                }
            
                self.updateFieldView()
                User.updateUser(user: AppDelegate.user)
                User.updateUser(user: NonUserProfileVC.nonUser)
            }
            
        })
        
    }
    
    func okCancel(msg: String, after: @escaping () -> Void) {
        let refreshAlert = UIAlertController(title: "Refresh", message: msg, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            after()
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))

        self.present(refreshAlert, animated: true, completion: nil)
    }
    
}

extension UIColor {
    static let barflyblue = UIColor(red: 0.71, green: 1.00, blue: 0.99, alpha: 1.0)
}
