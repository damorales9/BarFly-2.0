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
    
    @IBOutlet weak var fieldView: UIView!
    
    var fieldViewTopConstraint:  NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.hideKeyboardWhenTappedAround()
        
        edit.layer.cornerRadius = 5
        changeProfile.layer.cornerRadius =  5
        dragIndicator.layer.cornerRadius =  5
        
        fieldView.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.75)
        
        fieldViewTopConstraint = NSLayoutConstraint(item: self.fieldView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -200)
        self.view.addConstraint(fieldViewTopConstraint!)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        fieldView.addGestureRecognizer(gesture)
        fieldView.isUserInteractionEnabled = true
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        if let user = AppDelegate.user {
            name.text = user.name
            email.text = user.email
            username.text = user.username
            password.text = UserDefaults.standard.string(forKey: "password")
            
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
        
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        if(!editting) {
            editting = true
            self.name.becomeFirstResponder()
            UIView.animate(withDuration: 1, animations: {
                self.edit.setTitle("Done", for: .normal)
                self.changeProfile.alpha += 1
//                self.fieldViewTopConstraint?.constant -= 340
                self.view.layoutIfNeeded()
                self.edit.isHidden = false
            })
            
            
        } else {
            editting = false
            self.name.resignFirstResponder()
            UIView.animate(withDuration: 1, animations: {
                self.edit.setTitle("Edit", for: .normal)
                self.changeProfile.alpha -= 1
                self.fieldViewTopConstraint?.constant += 340
                self.view.layoutIfNeeded()
                self.edit.isHidden = true
            })
            
            
            if(profileImage.image != nil) {
                self.saveFIRData()
            }
        }
        name.isEnabled = editting
        email.isEnabled = editting
        password.isEnabled = editting
        username.isEnabled = editting
        password.isSecureTextEntry = !editting
        
        
        //save changes made
    }
    
    @IBAction func changeProfileClicked(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var clr: UIColor
        if(row == 0){
            clr = UIColor.black
        }
        else if (row == 1) {
            clr = UIColor.white
        } else {
            clr = UIColor.blue
        }
        name.textColor = clr
        email.textColor = clr
        password.textColor = clr
        
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
        print(gestureRecognizer.translation(in: fieldView.superview).x)
        if(gestureRecognizer.state == .began && fieldViewTopConstraint?.constant == -200) {
            UIView.animate(withDuration: 0.5) {
                self.fieldViewTopConstraint?.constant -= 40
                self.view.layoutIfNeeded()
            }
        } else if (gestureRecognizer.state  == .ended && fieldViewTopConstraint?.constant == -240) {
            if(gestureRecognizer.translation(in: fieldView.superview).x <= -10) {
                UIView.animate(withDuration: 0.5) {
                    self.fieldViewTopConstraint?.constant -= 300
                    self.view.layoutIfNeeded()
                }
            }
            
            editButtonClicked(gestureRecognizer)
        }
//        } else if (gestureRecognizer.state == .ended && fieldViewTopConstraint?.constant == -540) {
//            if(gestureRecognizer.translation(in: fieldView.superview).x >= 10){
//                UIView.animate(withDuration: 0.5) {
//                    self.fieldViewTopConstraint?.constant += 340
//                    self.view.layoutIfNeeded()
//                }
//            }
//
//            editButtonClicked(gestureRecognizer)
//        }

    }
    
}

extension ProfileVC: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        
        if let image = image {
            self.profileImage.image = image
        }
        
    }
}

