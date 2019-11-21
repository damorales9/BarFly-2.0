//
//  EditProfileVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/15/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import YPImagePicker

class EditProfileVC: UIViewController {
    
    var image: UIImage?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveButtonView: UIView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        
        saveButton.layer.cornerRadius = 5
        saveButtonView.layer.cornerRadius = 5
        saveButton.layer.borderColor = UIColor.black.cgColor
        saveButton.layer.borderWidth = 2
        
        name.layer.cornerRadius = 5
        name.layer.borderWidth = 0
        name.layer.borderColor = UIColor.barflyblue.cgColor
        
        username.layer.cornerRadius = 5
        username.layer.borderWidth = 0
        username.layer.borderColor = UIColor.barflyblue.cgColor
        
        email.layer.cornerRadius = 5
        email.layer.borderWidth = 0
        email.layer.borderColor = UIColor.barflyblue.cgColor
        
        password.layer.cornerRadius = 5
        password.layer.borderWidth = 0
        password.layer.borderColor = UIColor.barflyblue.cgColor
        
        
        
    }
        
    override func viewDidAppear(_ animated: Bool) {
        User.getUser(uid: AppDelegate.user!.uid!) { (user: User?) in
            
            AppDelegate.user = user!
            
            self.name.text =  AppDelegate.user?.name
            self.username.text = AppDelegate.user?.username
            self.email.text =  AppDelegate.user?.email
            self.password.text = UserDefaults.standard.string(forKey: "password")
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        saveProfile()
    }
    
    func saveProfile() {
        
        User.getUser(uid: AppDelegate.user!.uid!) { (user: User?) in
            AppDelegate.user = user!
            
            
            if let username = self.username.text, let password = self.password.text , let email = self.email.text{
                Firestore.firestore().collection(LoginVC.USER_DATABASE).whereField("username", isEqualTo: self.username.text!)
                .getDocuments() { (querySnapshot, err) in
                    if(querySnapshot?.documents.count == 0 || (querySnapshot?.documents.count == 1 && querySnapshot?.documents[0].documentID == AppDelegate.user!.uid!)) {
                        
                        if(password.count >= 6) {
                            
                            if(email.isValidEmail()) {
                                
                                AppDelegate.user?.username = username
                                AppDelegate.user?.name = self.name.text
                                AppDelegate.user?.email = email
                                
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
                                
                                if let image = self.image {
                                    self.saveFIRData(image: image)
                                }
                                
                                User.updateUser(user: AppDelegate.user!)
                                self.navigationController?.popToRootViewController(animated: true)
                            } else {
                                self.errorLabel.text = "This email is not valid"
                            }
                
                        } else {
                            self.errorLabel.text = "This password is not long enough"
                        }
                    
                    } else {
                        self.errorLabel.text =  "This username is taken"
                    }
                    
                    
                }
            }
            
            
            
        }
    }
    
    func saveFIRData(image: UIImage){
        self.uploadMedia(image: image){ url in
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
        let imgData = image.pngData()
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
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        var config = YPImagePickerConfiguration()
        //config for image picker
        config.onlySquareImagesFromCamera = false
        config.screens = [.library]
        config.library.maxNumberOfItems = 1
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.image = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
        
    }
    
}
