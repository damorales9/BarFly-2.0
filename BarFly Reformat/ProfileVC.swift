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
    
    
   

    //VARS
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
    
    @IBOutlet weak var fieldView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        edit.layer.cornerRadius = 5
        changeProfile.layer.cornerRadius =  5
        
        fieldView.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.75)
        
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
            UIView.animate(withDuration: 1, animations: {
                self.edit.setTitle("Done", for: .normal)
                self.changeProfile.alpha += 1
    
            })
        } else {
            editting = false
            UIView.animate(withDuration: 1, animations: {
                self.edit.setTitle("Edit", for: .normal)
                self.changeProfile.alpha -= 1
                
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
    
}

extension ProfileVC: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        
        if let image = image {
            self.profileImage.image = image
        }
        
    }
}

