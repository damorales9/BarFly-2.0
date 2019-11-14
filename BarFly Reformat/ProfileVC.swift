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
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var changeProfile: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var dragIndicator: UILabel!
    @IBOutlet weak var requestsButton: UIBarButtonItem!
    
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
        
        edit.layer.cornerRadius = 5
        changeProfile.layer.cornerRadius =  5
        dragIndicator.layer.cornerRadius =  5
        fieldView.layer.cornerRadius = 30
        fieldView.layer.borderColor =  UIColor.barflyblue.cgColor
        fieldView.layer.borderWidth = 4
        
        name.layer.borderWidth = 0
        username.layer.borderWidth = 0
        email.layer.borderWidth = 0
        password.layer.borderWidth = 0
        
        fieldView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
        
        
        

        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        fieldView.addGestureRecognizer(gesture)
        fieldView.isUserInteractionEnabled = true
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        paintComponents()
        updateBadge()
    }
    
    func paintComponents() {
        
        User.getUser(uid: AppDelegate.user!.uid!) { (user: inout User?) in
            
            AppDelegate.user = user!
        
            if let user = AppDelegate.user {
                self.name.text = user.name
                self.email.text = user.email
                self.username.text = user.username
                self.password.text = UserDefaults.standard.string(forKey: "password")
                
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
                
                if(user.requests.count == 0) {
                    
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
    
    func updateBadge() {
        if(AppDelegate.user?.requests.count != 0){
            tabBarItem.badgeValue = "\(AppDelegate.user!.requests.count)"
        } else {
            tabBarItem.badgeValue = nil
        }
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
    
        editting = false
        self.name.resignFirstResponder()
        UIView.animate(withDuration: 1, animations: {
            self.edit.setTitle("Save", for: .normal)
            self.changeProfile.isHidden = true
//                     self.fieldViewTopConstraint?.constant += 340
            self.view.layoutIfNeeded()
            
        })
        
        UIView.animate(withDuration: 0.3) {
            self.startingConstant = -250
            self.centerConstraint.constant = self.startingConstant
            self.view.layoutIfNeeded()
            self.edit.isHidden = true
        }
                    
          
        User.getUser(uid: AppDelegate.user!.uid!) { (user: inout User?) in
            AppDelegate.user = user!
            
            
            if let username = self.username.text, let password = self.password.text , let email = self.email.text{
                Firestore.firestore().collection(LoginVC.USER_DATABASE).whereField("username", isEqualTo: self.username.text!)
                .getDocuments() { (querySnapshot, err) in
                    if(querySnapshot?.documents.count == 0) {
                        AppDelegate.user?.username = username
                    } else {
                        self.username.text = AppDelegate.user?.username
                    }
                    
                    AppDelegate.user?.name = self.name.text
                    AppDelegate.user?.email = email
                    
                    
                    if(password.count >= 6 && email.isValidEmail()) {
                        Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                            if(error == nil) {
                                UserDefaults.standard.set(password, forKey: "password")
                            } else {
                                self.password.text = UserDefaults.standard.string(forKey: "password")
                            }
                        }
                        Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
                            if(error == nil) {
                                UserDefaults.standard.set(email, forKey: "email")
                            } else {
                                self.email.text = UserDefaults.standard.string(forKey: "email")
                            }
                        })
                    }
                    
                    User.updateUser(user: AppDelegate.user!)
                }
            }
            
            
            
        }
        if(profileImage.image != nil) {
            self.saveFIRData()
        }
            
        self.name.isEnabled = false
        self.email.isEnabled = false
        self.password.isEnabled = false
        self.username.isEnabled = false
        self.password.isSecureTextEntry = true
                
                
                //save changes made
    }
    
    @IBAction func changeProfileClicked(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
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
                
                editting = true
                self.name.becomeFirstResponder()
                UIView.animate(withDuration: 0.3, animations: {
                    self.edit.setTitle("Save", for: .normal)
                    self.changeProfile.isHidden = false
                    //                self.fieldViewTopConstraint?.constant -= 340
                    self.view.layoutIfNeeded()
                    self.edit.isHidden = false
                })
                
                
                name.isEnabled = editting
                email.isEnabled = editting
                password.isEnabled = editting
                username.isEnabled = editting
                password.isSecureTextEntry = !editting
                
                
                print("high enough")
                
                UIView.animate(withDuration: 0.3) {
                    self.centerConstraint.constant = -600
                    self.view.layoutIfNeeded()
                    self.edit.isHidden = false
                }
            } else {
                print("too low")
                
                if(editting) {
                    UIView.animate(withDuration: 0.3) {
                        self.centerConstraint.constant = -600
                        self.view.layoutIfNeeded()
                        self.edit.isHidden = false
                    }
                } else {
                    
                    UIView.animate(withDuration: 0.3) {
                        self.startingConstant = -250
                        self.centerConstraint.constant = self.startingConstant
                        self.view.layoutIfNeeded()
                        self.edit.isHidden = true
                    }
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
        }
        
    }
}

