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

class ProfileVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
   

    //VARS
    var imagePicker: ImagePicker!
    var editting = false
    
    var pickerData = ["Black Color", "White Color", "System Blue Color"]
    
    //UI
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var changeProfile: UIButton!
    @IBOutlet weak var colorPicker: UIPickerView!
    @IBOutlet weak var color: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        color.layer.cornerRadius = 5
        edit.layer.cornerRadius = 5
        changeProfile.layer.cornerRadius =  5
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        if let user = AppDelegate.user {
            name.text = user.name
            email.text = user.email
            password.text = UserDefaults.standard.string(forKey: "password")
            
            let placeholder = UIImage( named: "person.circle.fill")
            
            if (user.profileURL != "") {
            
                let storage = Storage.storage()
                let httpsReference = storage.reference(forURL: user.profileURL!)
                
                self.profileImage.sd_setImage(with: httpsReference, placeholderImage: placeholder)
                    
            } else {
                self.profileImage.image = placeholder
            }

        }
            
        self.colorPicker.delegate = self
        self.colorPicker.dataSource = self
    }

    @IBAction func colorClicked(_ sender: Any) {
        colorPicker.isHidden = !colorPicker.isHidden
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        if(!editting) {
            editting = true
            UIView.animate(withDuration: 1, animations: {
                self.edit.setTitle("Done", for: .normal)
                self.changeProfile.alpha += 1
                self.color.alpha += 1
            })
        } else {
            editting = false
            UIView.animate(withDuration: 1, animations: {
                self.edit.setTitle("Edit", for: .normal)
                self.changeProfile.alpha -= 1
                self.color.alpha -= 1
            })
        }
        name.isEnabled = editting
        email.isEnabled = editting
        password.isEnabled = editting
        password.isSecureTextEntry = !editting
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
        
        colorPicker.isHidden = true
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
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
        self.profileImage.image = image
        
        self.saveFIRData()
    }
}
