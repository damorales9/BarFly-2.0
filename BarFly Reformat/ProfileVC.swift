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
    var imagePicker: ImagePicker!
    var editting = false
    
    //UI
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var dragIndicator: UILabel!
    @IBOutlet weak var requestsButton: UIBarButtonItem!
    @IBOutlet weak var changeBarChoiceView: UIView!
    @IBOutlet weak var changeBarChoice: UIButton!
    @IBOutlet weak var barChoiceLabel: UILabel!
    @IBOutlet weak var barChoice: UIImageView!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editButtonView: UIView!
    
    
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
        
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        fieldView.addGestureRecognizer(gesture)
        fieldView.isUserInteractionEnabled = true
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        paintComponents()
        updateBadge()
        getFollowers()
    }
    
    func paintComponents() {
        
        User.getUser(uid: AppDelegate.user!.uid!) { (user: User?) in
            
            AppDelegate.user = user!
        
            if let user = AppDelegate.user {
                self.name.text = user.name
                self.username.text = user.username
                self.numFollowing.text = "\(AppDelegate.user!.friends.count)"
                
                
                var placeholder: UIImage?
                if #available(iOS 13.0, *) {
                    placeholder = UIImage(systemName: "questionmark")
                } else {
                    // Fallback on earlier versions
                    placeholder = UIImage(named: "profile")
                }
                self.barChoice.image = placeholder
                
                placeholder = UIImage( named: "person.circle.fill")
                
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
                
                if(user.requests.count == 0) {
                    self.requestsButton.tintColor = .clear
                } else {
                    self.requestsButton.tintColor = .barflyblue
                }
                
                if(user.bar == "nil") {
                    
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
                
            }
        }
        
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
        
        paintComponents()
        updateBadge()
    }
    
    func getFollowers(){
        Firestore.firestore().collection(LoginVC.USER_DATABASE).whereField("friends", arrayContains: AppDelegate.user?.uid).getDocuments { (snapshot,err)in (snapshot, err)
            self.numFollowers.text = "\(snapshot!.documents.count)"
        }
    }
    
    func updateBadge() {
        if(AppDelegate.user?.requests.count != 0){
            tabBarItem.badgeValue = "\(AppDelegate.user!.requests.count)"
        } else {
            tabBarItem.badgeValue = nil
        }
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        self.imagePicker.present(from: sender as! UIView)
    }
    
    func saveFIRData(){
        self.uploadMedia(image: profileImage.image!){ url in
            self.saveImage(userName: Auth.auth().currentUser!.uid, profileImageURL: url!){ success in
                if (success != nil){
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        }
    }
    
    func uploadMedia(image :UIImage, completion: @escaping ((_ url: URL?) -> ())) {
        let uid = (Auth.auth().currentUser?.uid)!
        let uidStr = uid + ".png"
        let storageRef = Storage.storage().reference().child(uidStr)
        let imgData = self.profileImage.image?.pngData()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storageRef.putData(imgData!, metadata: metaData) { (metadata, error) in
            if error == nil{
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            }else{
                print("error in save image")
                completion(nil)
            }
        }
    }
    
    func saveImage(userName:String, profileImageURL: URL , completion: @escaping ((_ url: URL?) -> ())){
        Firestore.firestore().collection(LoginVC.USER_DATABASE).document(Auth.auth().currentUser!.uid).updateData(["profileURL":profileImageURL.absoluteString])
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
                    self.centerConstraint.constant = -650
                    self.view.layoutIfNeeded()
                    
                }
            } else {
                    
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
    
}

extension ProfileVC: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        
        if let image = image {
            self.profileImage.image = image
            self.saveFIRData()
        }
    }
}

