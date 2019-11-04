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
    
    var centerConstraint: NSLayoutConstraint!

    var startingConstant: CGFloat  = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.hideKeyboardWhenTappedAround()
        
        edit.layer.cornerRadius = 5
        changeProfile.layer.cornerRadius =  5
        dragIndicator.layer.cornerRadius =  5
        
        fieldView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
        

        
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
                        self.edit.setTitle("Save", for: .normal)
                        self.changeProfile.isHidden = false
        //                self.fieldViewTopConstraint?.constant -= 340
                        self.view.layoutIfNeeded()
                        self.edit.isHidden = false
                    })
                    
                    
                } else {
                    editting = false
                    self.name.resignFirstResponder()
                    UIView.animate(withDuration: 1, animations: {
                        self.edit.setTitle("Edit", for: .normal)
                        self.changeProfile.isHidden = true
//                        self.fieldViewTopConstraint?.constant += 340
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
    
    var initialCenter = CGPoint()
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
//        let piece = gestureRecognizer.view!
//
//        print("center  y is \(piece.center.y)")
//        // Get the changes in the X and Y directions relative to
//        // the superview's coordinate space.
//        let translation = gestureRecognizer.translation(in: piece.superview)
//        if gestureRecognizer.state == .began {
//           // Save the view's original position.
//           self.initialCenter = piece.center
//        }
//        if(gestureRecognizer.state == .ended) {
//            if(piece.center.y <  UIScreen.main.bounds.height + 90) {
//                print("go up")
//                UIView.animate(withDuration: 0.3) {
//                    piece.center.y = UIScreen.main.bounds.height - 200
//                    self.edit.isHidden = false
//                }
//            } else {
//                UIView.animate(withDuration: 0.3) {
//                    piece.center.y = UIScreen.main.bounds.height + 200
//                    self.edit.isHidden = true
//                }
//            }
//        } else if gestureRecognizer.state != .cancelled {
//           // Add the X and Y translation to the view's original position.
//           let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)
//           piece.center = newCenter
//        }
//        else {
//           // On cancellation, return the piece to its original location.
//           piece.center = initialCenter
//        }
        
        switch gestureRecognizer.state {
        case .began:
            self.startingConstant = self.centerConstraint.constant
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            self.centerConstraint.constant = self.startingConstant + translation.y
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

