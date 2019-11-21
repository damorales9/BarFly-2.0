//
//  SecondViewController.swift
//  BarFly Reformat
//
//  Created by Derek Morales on 10/31/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import UIKit
import FirebaseAuth
import Photos
import FirebaseStorage
import FirebaseFirestore
import FirebaseUI

class ProfileVC: UIViewController {
        
    //VAR
    
    var editting = false
    
    //UI
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var dragIndicator: UILabel!

    @IBOutlet weak var changeBarChoiceView: UIView!
    @IBOutlet weak var changeBarChoice: UIButton!
    @IBOutlet weak var barChoiceLabel: UILabel!
    @IBOutlet weak var barChoice: UIImageView!
    
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editButtonView: UIView!
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    @IBOutlet weak var numFollowers: UILabel!
    @IBOutlet weak var numFollowing: UILabel!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    
    
    @IBOutlet weak var fieldView: UIView!
    
    var centerConstraint: NSLayoutConstraint!
    var startingConstant: CGFloat  = -250
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        self.centerConstraint = fieldView.topAnchor.constraint(equalTo: view.bottomAnchor)
        self.centerConstraint.constant = startingConstant
        self.centerConstraint.isActive = true
        self.hideKeyboardWhenTappedAround()
        
        dragIndicator.layer.cornerRadius =  5
        fieldView.layer.cornerRadius = 30
        fieldView.layer.borderColor =  UIColor.barflyblue.cgColor
        fieldView.layer.borderWidth = 4
        
        name.layer.borderWidth = 0
        username.layer.borderWidth = 0
        
        name.layer.cornerRadius =  5
        username.layer.cornerRadius =  5
        
        changeBarChoice.layer.borderWidth = 2
        changeBarChoiceView.layer.cornerRadius = 5
        changeBarChoice.layer.cornerRadius = 5
        changeBarChoice.layer.borderColor = UIColor.black.cgColor
        
        editButtonView.layer.cornerRadius = 5
        editButton.layer.cornerRadius = 5
        editButton.layer.borderWidth = 2
        editButton.layer.borderColor = UIColor.barflyblue.cgColor
        
        name.layer.borderWidth = 0
        username.layer.borderWidth = 0
        
        name.layer.borderColor = UIColor.barflyblue.cgColor
        username.layer.borderColor = UIColor.barflyblue.cgColor
        
        fieldView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
        
        UIView.animate(withDuration:0.3, delay: 0.1, usingSpringWithDamping: 1,
                   initialSpringVelocity: 0.2,
                   options: .allowAnimatedContent,
                   animations: {
                       self.centerConstraint.constant = self.startingConstant - 20
                       self.view.layoutIfNeeded()
                   }, completion: { (value: Bool) in
                       UIView.animate(withDuration: 0.3) {
                           self.centerConstraint.constant = self.startingConstant
                           self.view.layoutIfNeeded()
                       }
                   })
    }
    
    
    
    func unpaintComponents() {
        
//        requestsButton.tintColor = .clear
//        changeBarChoice.tintColor = .clear
//        settingsButton.tintColor = .clear
        self.navigationController?.isNavigationBarHidden = true
        
        name.text = ""
        username.text = ""
        numFollowers.text = ""
        numFollowing.text = ""
        
        var placeholder: UIImage?
        if #available(iOS 13.0, *) {
            placeholder = UIImage(systemName: "questionmark")
        } else {
            // Fallback on earlier versions
            placeholder = UIImage(named: "profile")
        }
        self.barChoice.image = placeholder
        
        barChoiceLabel.text = ""
    }
    
    func paintComponents() {
        
        self.maskView.alpha = 0
        
        User.getUser(uid: AppDelegate.user!.uid!) { (user: User?) in
            
            AppDelegate.user = user!
            
            if let user = AppDelegate.user {
                
                self.navigationController?.isNavigationBarHidden = false
                self.name.text = user.name
                self.username.text = user.username
                self.numFollowing.text = "\(user.friends.count)"
                self.numFollowers.text = "\(user.followers.count)"
                
                var placeholder = UIImage( named: "person.circle.fill")
                
                print("profileURL is \(user.profileURL)")
                
                if (user.profileURL != "") {
                    
                    SDImageCache.shared.clearMemory()
                    SDImageCache.shared.clearDisk()
                    
                    let storage = Storage.storage()
                    let httpsReference = storage.reference(forURL: user.profileURL!)
                    
                    httpsReference.getData(maxSize: 40 * 1024 * 1024) { data, error in
                      if let error = error {
                        
                        self.profileImage.image = placeholder
                      } else {
                        
                        self.profileImage.image = UIImage(data: data!)
                      }
                    }
                        
                } else {
                    self.profileImage.image = placeholder
                }
                
                if(user.requests.count == 0) {
                    self.navigationItem.setRightBarButtonItems([ self.settingsButton], animated: true)
                } else {
                    
                    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
                    button.tintColor = .barflyblue

                    let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
                    if #available(iOS 13.0, *) {
                        iv.image = UIImage(systemName: "circle.fill")
                    }
                    iv.tintColor = .red

                    let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
                    lbl.text = "\(user.requests.count)"
                    lbl.textColor = .black
                    lbl.textAlignment = .center
                    lbl.font = UIFont(name: "Roboto-Black", size: 10)
                    
                    iv.addSubview(lbl)
                   
                    button.addSubview(iv)
                   
                    if #available(iOS 13.0, *) {
                        button.setImage(UIImage(systemName: "person.fill"), for: .normal)
                    }
                    
                    button.addTarget(self, action: #selector(self.showRequests), for: .touchUpInside)
                   
                    let requests = UIBarButtonItem(customView: button)
                    self.navigationItem.setRightBarButtonItems([ self.settingsButton, requests], animated: true)
                    
                }
                
                if(user.bar == "nil") {
                    
                    var placeholder: UIImage?
                    if #available(iOS 13.0, *) {
                        placeholder = UIImage(systemName: "questionmark")
                    } else {
                        // Fallback on earlier versions
                        placeholder = UIImage(named: "profile")
                    }
                    self.barChoice.image = placeholder
                    
                    self.changeBarChoice.setTitle("Make a Choice", for: .normal)
                    self.barChoiceLabel.text = "You have not selected a bar"
                } else {
                    self.changeBarChoice.setTitle("Change Your Choice", for: .normal)
                    self.barChoiceLabel.text = "You are going to \(user.bar!)"
        
                    let firestore = Firestore.firestore()
                    let userRef = firestore.collection("Bars")
                    let docRef = userRef.document("\(user.bar!)")
                    docRef.getDocument { (document, error) in
                            
                        if(error != nil) {
                            print("error bro")
                        } else {
                            let imageURL = document?.get("imageURL") as! String
                            
                            if #available(iOS 13.0, *) {
                                placeholder = UIImage(systemName: "questionmark")
                            } else {
                                placeholder = UIImage(named: "first")
                            }
                            
                            let storage = Storage.storage()
                            let httpsReference = storage.reference(forURL: imageURL)
                            
                            self.barChoice.setFirebaseImage(ref: httpsReference, placeholder: placeholder!, maxMB: 6)
                                
                        }
                    }
                }
            }
                
        }
        
    }
    
    @objc func showRequests() {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let req = storyBoard.instantiateViewController(withIdentifier: "requestsVC") as! RequestsVC
        self.navigationController?.pushViewController(req, animated:true)
        
//        self.performSegue(withIdentifier: "showRequests", sender: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

        paintIfLoggedIn()
    }
    
    func paintIfLoggedIn() {
    
        if(AppDelegate.loggedIn) {
            self.paintComponents()
            self.updateBadge()
                
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
            fieldView.addGestureRecognizer(gesture)
            fieldView.isUserInteractionEnabled = true
        }
        
    }
    
    func updateBadge() {
        if(AppDelegate.user?.requests.count != 0){
            self.tabBarItem.badgeValue = "\(AppDelegate.user!.requests.count)"
        } else {
            self.tabBarItem.badgeValue = nil
        }
    }

    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .began:
            self.startingConstant = self.centerConstraint.constant
        case .changed:
            self.maskView.alpha = abs(self.centerConstraint.constant+200) / 800
//            self.maskView.layoutIfNeeded()
            let translation = gestureRecognizer.translation(in: self.view)
            self.centerConstraint.constant = self.startingConstant + translation.y
        case .ended:
            if(self.centerConstraint.constant < -450) {
                
                UIView.animate(withDuration: 0.3) {
                    self.centerConstraint.constant = -650
                    self.maskView.alpha = 0.5
                    self.view.layoutIfNeeded()
                    
                }
            } else {
                    
                UIView.animate(withDuration: 0.3) {
                    self.startingConstant = -250
                    self.maskView.alpha = 0
                    self.centerConstraint.constant = self.startingConstant
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }


    }
    
    @IBAction func followingBtnClicked(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let listVC = storyBoard.instantiateViewController(withIdentifier: "nonUserList") as! NonUserListVC
        listVC.isFollowers = false
        listVC.nonUser = AppDelegate.user
        self.navigationController?.pushViewController(listVC, animated:true)
    }
    
    @IBAction func followersBtnClicked(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let listVC = storyBoard.instantiateViewController(withIdentifier: "nonUserList") as! NonUserListVC
        listVC.isFollowers = true
        listVC.nonUser = AppDelegate.user
        self.navigationController?.pushViewController(listVC, animated:true)
    }
}
