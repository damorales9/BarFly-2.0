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
    
    
    
    var nonUser: User?
    
    var confirm = false
    var confirmUnfollow = false
    
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
    @IBOutlet weak var cancelUnfollowView: UIView!
    @IBOutlet weak var cancelUnfollow: UIButton!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var barChoice: UIImageView!
    @IBOutlet weak var barChoiceLbl: UILabel!
    
    var centerConstraint: NSLayoutConstraint!
    var startingConstant: CGFloat  = -200
    
    
    var trailingFollowConstraint: NSLayoutConstraint!
    var trailingUnfollowConstraint: NSLayoutConstraint!

    var cancelWidthConstraint: NSLayoutConstraint!
    var cancelUnfollowWidthConstraint: NSLayoutConstraint!
    
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
        cancelUnfollowView.layer.cornerRadius = 10
        cancelUnfollow.layer.cornerRadius = 10
        cancelUnfollow.layer.borderWidth = 2
        cancelUnfollow.layer.borderColor = UIColor.black.cgColor
        blockView.layer.cornerRadius = 10
        followView.layer.cornerRadius = 10

        
        trailingFollowConstraint = NSLayoutConstraint(item: blockView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -50)
        
        trailingUnfollowConstraint = NSLayoutConstraint(item: followView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -50)
        
        cancelWidthConstraint = NSLayoutConstraint(item: cancelView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        
        cancelUnfollowWidthConstraint = NSLayoutConstraint(item: cancelUnfollowView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)

        cancelView.addConstraint(cancelWidthConstraint)
        cancelUnfollowView.addConstraint(cancelUnfollowWidthConstraint)
        
        view.addConstraint(trailingFollowConstraint)
        view.addConstraint(trailingUnfollowConstraint)
        
        self.centerConstraint = fieldView.topAnchor.constraint(equalTo: view.bottomAnchor)
        self.centerConstraint.constant = startingConstant
        self.centerConstraint.isActive = true
        
        fieldView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
    
        if let user = nonUser {
            
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
    }
    
    func getFollowers(){
        Firestore.firestore().collection(LoginVC.USER_DATABASE).whereField("friends", arrayContains: nonUser?.uid).getDocuments { (snapshot,err)in (snapshot, err)
            self.numFollowers.text = "\(snapshot!.documents.count)"
        }
    }
    
    
    func updateFieldView() {
        
        User.getUser(uid: AppDelegate.user!.uid!) { (currentUser: User?) in
            AppDelegate.user = currentUser!
        
            User.getUser(uid: self.nonUser!.uid!) { (user: User?) in
                
                self.nonUser = user!
        
                if let user = self.nonUser {
                    
                    self.name.text = user.name
                    self.username.text = user.username
                    self.numFollowing.text = "\(user.friends.count)"
                    self.getFollowers()
                    
                    if(user.friends.contains(AppDelegate.user?.uid)) {
                        self.blockView.isHidden = false
                        if((AppDelegate.user?.blocked.contains(user.uid))!) {
                            self.block.setTitle("Unblock", for: .normal)
                            self.block.setTitleColor(.barflyblue, for: .normal)
                            self.block.layer.borderColor = UIColor.barflyblue.cgColor
                            self.blockView.backgroundColor = .black
                        } else {
                            self.block.setTitle("Block", for: .normal)
                            self.block.setTitleColor(.black, for: .normal)
                            self.block.layer.borderColor = UIColor.black.cgColor
                            self.blockView.backgroundColor = .red
                        }
                    } else {
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
                    
                
                    if((currentUser?.friends.contains(user.uid))!) {
                        
                        self.follow.setTitle("Unfollow", for: .normal);
                        self.follow.backgroundColor = .red
                        self.followView.backgroundColor = .red
                        
                        if(user.bar == "nil" || user.blocked.contains(currentUser?.uid!)) {
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
            self.trailingFollowConstraint.constant = -50
            self.cancelView.isHidden = true
            self.cancelWidthConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func cancelUnfollowButtonClicked(_ sender: Any) {
        confirmUnfollow = false
        
        UIView.animate(withDuration: 0.5) {
            self.trailingUnfollowConstraint.constant = -50
            self.cancelUnfollowView.isHidden = true
            self.cancelUnfollowWidthConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func blockButtonClicked(_ sender: Any) {
        
        if(confirm) {
            
            if((AppDelegate.user?.blocked.contains(self.nonUser!.uid))!) {
                    
                    User.getUser(uid: AppDelegate.user!.uid!) { (user) in
                        AppDelegate.user = user!
                        
                        AppDelegate.user?.blocked.remove(at: (user?.blocked.firstIndex(of: self.nonUser?.uid))!)
                        
                        User.updateUser(user: AppDelegate.user)
                        
                        self.updateFieldView()
                                                   
                        UIView.animate(withDuration: 0.5) {
                            self.trailingFollowConstraint.constant = -50
                            self.cancelView.isHidden = true
                            self.cancelWidthConstraint.constant = 0
                            self.view.layoutIfNeeded()
                                    
                        }
                        self.confirm = false
                    
                    }
                
                } else {
                    User.getUser(uid: AppDelegate.user!.uid!, setFunction: { (user: User?) -> Void in

                            AppDelegate.user = user!
                            
        
                            AppDelegate.user?.blocked.append(self.nonUser?.uid)
                            
                        
                            User.updateUser(user: AppDelegate.user)
                            
                            self.updateFieldView()
                            
                            UIView.animate(withDuration: 0.5) {
                                self.trailingFollowConstraint.constant = -50
                                self.cancelView.isHidden = true
                                self.cancelWidthConstraint.constant = 0
                                self.view.layoutIfNeeded()
                                
                            }
                            self.confirm = false

                        })
                    }
            
        } else {
            
            UIView.animate(withDuration: 0.5) {
                self.trailingFollowConstraint.constant = -110
                self.cancelView.isHidden = false
                self.cancelWidthConstraint.constant = 50
                self.view.layoutIfNeeded()
                
            }
            confirm = true
        }
    }
    
    @IBAction func followButtonClicked(_ sender: Any) {
            
            User.getUser(uid: self.nonUser!.uid!, setFunction: { (user: User?) -> Void in
                self.nonUser = user!
                
                if let user = self.nonUser {
                    
                    if ((AppDelegate.user?.friends.contains(user.uid))!) {
                        
                        //UNFOLLOW CASE
                        
                        if(self.confirmUnfollow) {
                            
                            UIView.animate(withDuration: 0.5) {
                                self.trailingUnfollowConstraint.constant = -50
                                self.cancelUnfollowView.isHidden = false
                                self.cancelUnfollowWidthConstraint.constant = 0
                                self.view.layoutIfNeeded()
                                
                            }
                        
                            AppDelegate.user!.friends.remove(at: (AppDelegate.user!.friends.firstIndex(of: user.uid)!))
                            self.nonUser?.followers.remove(at: user.followers.firstIndex(of: AppDelegate.user?.uid)!)
                            if (user.blocked.contains(AppDelegate.user?.uid)) {
                                self.nonUser?.blocked.remove(at: user.blocked.firstIndex(of: AppDelegate.user?.uid)!)
                            }
                            
                            self.updateFieldView()
                            User.updateUser(user: AppDelegate.user)
                            User.updateUser(user: self.nonUser)
                            
                            self.confirmUnfollow = false
                            
                        } else {
                         
                            self.confirmUnfollow = true
                            
                            UIView.animate(withDuration: 0.5) {
                                self.trailingUnfollowConstraint.constant = -110
                                self.cancelUnfollowView.isHidden = false
                                self.cancelUnfollowWidthConstraint.constant = 50
                                self.view.layoutIfNeeded()
                                
                            }
                            
                            return
                            
                        }

                        
                    } else if (!(AppDelegate.user?.friends.contains(user.uid))! && !(user.requests.contains(AppDelegate.user?.uid))) {
                        
                        //REQUEST CASE
                        
                        self.nonUser!.requests.append(AppDelegate.user?.uid)
                        let userToken = user.messagingID ?? ""
                        let notifPayload: [String: Any] = ["to": userToken,"notification": ["title":"\(self.getRequestMessage())","body":" \(AppDelegate.user!.username!) has requested to follow you","badge":1,"sound":"default"]]
                        User.sendPushNotification(payloadDict: notifPayload)
                        
                        
                        
                    } else if (!(AppDelegate.user?.friends.contains(user.uid))! &&  (user.requests.contains(AppDelegate.user?.uid))) {
                        
                        //REMOVE REQUEST
                        
                        self.nonUser?.requests.remove(at: (user.requests.firstIndex(of: AppDelegate.user?.uid))!)
                       
                    }
                
                    self.updateFieldView()
                    User.updateUser(user: AppDelegate.user)
                    User.updateUser(user: self.nonUser)
                }
                
            })
        
    }
    
    func getRequestMessage() -> String {
        
        let number = Int.random(in: 0 ..< 10)
        
        switch number {
        case 0: return "LMAO Someone wants to follow you"
        case 1: return "Put your dentures back in, Barbara"
        case 2: return "Don't get your panties knackered, Jessica"
        case 3: return "Focus on your career some other night"
        case 4: return "Go out for once you peice of sh*t"
        case 5: return "TBD0"
        case 6: return "TBD1"
        case 7: return "TBD2"
        case 8: return "TBD3"
        default:
            return "New Follow Request"
        }
        
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
    
    @IBAction func followingBtnClicked(_ sender: Any) {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let listVC = storyBoard.instantiateViewController(withIdentifier: "nonUserList") as! NonUserListVC
            listVC.isFollowers = false
            listVC.nonUser = self.nonUser!
            self.navigationController?.pushViewController(listVC, animated:true)
       }
       
       @IBAction func followersBtnClicked(_ sender: Any) {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let listVC = storyBoard.instantiateViewController(withIdentifier: "nonUserList") as! NonUserListVC
            listVC.isFollowers = true
            listVC.nonUser = self.nonUser!
            self.navigationController?.pushViewController(listVC, animated:true)
       }
    
}

extension UIColor {
    static let barflyblue = UIColor(red: 0.71, green: 1.00, blue: 0.99, alpha: 1.0)
}
