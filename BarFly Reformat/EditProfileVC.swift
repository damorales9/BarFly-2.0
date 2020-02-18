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
import NVActivityIndicatorView

class EditProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    var statuses =  [
            User.NIL,
            User.LOOKING,
            User.JEALOUS,
            User.COMPLICATED,
            User.FRIENDS,
            User.RELATIONSHIP,
            User.SEEING_SOMEONE,
            User.SEXILED,
            User.POPPIN,
            User.CLAM,
            User.JESUS
    ]
    
    
    var delegate: UIViewController?
    
    var config = YPImagePickerConfiguration()
    
    var image: UIImage?
    
    var confirmIndex = -1
    
    var galleryImages = [UIImage]()
    
    var saveEnabled = false
    
    var profileSpinner: NVActivityIndicatorView?
    var gallerySpinner: NVActivityIndicatorView?
    
    
    var indicator: NVActivityIndicatorView?
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var galleryView: UICollectionView!
    
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var confirmButtonView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmImageView: UIImageView!
    
    @IBOutlet weak var cancelButtonView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var savingView: UIView!
    @IBOutlet weak var savingProgress: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    var navbar: UINavigationBar?
    
    override func viewDidLoad() {
        
        status.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        
        status.layer.cornerRadius = 5
        status.layer.borderWidth = 0
        status.layer.borderColor = UIColor.barflyblue.cgColor
        
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
        
        
        previewView.layer.cornerRadius = 10
        previewButton.layer.cornerRadius = 10
        previewButton.layer.borderWidth = 3
        previewButton.layer.borderColor = UIColor.black.cgColor
        
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.borderColor = UIColor.black.cgColor
        cancelButton.layer.borderWidth = 3
        
        cancelButtonView.layer.cornerRadius = 10
        
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.borderColor = UIColor.black.cgColor
        confirmButton.layer.borderWidth = 3
        
        confirmButtonView.layer.cornerRadius = 10
        
        cancelButton.addTarget(self, action: #selector(cancelDelete), for: .touchUpInside)
        
        confirmButton.addTarget(self, action: #selector(confirmDelete), for: .touchUpInside)
        
        confirmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelDelete)))
        
        view.bringSubviewToFront(confirmView)
        view.bringSubviewToFront(savingView)
        
        indicator = NVActivityIndicatorView(frame: CGRect(x: savingView.frame.width / 2 - 50, y: savingView.frame.height / 2 - 50, width: 100, height: 100), type: .circleStrokeSpin, color: .barflyblue, padding: 0)
        
        savingView.addSubview(indicator!)
        
        config.colors.tintColor = .barflyblue
        config.onlySquareImagesFromCamera = false
        config.screens = [.library]
        config.library.maxNumberOfItems = 1
        config.showsCrop = .rectangle(ratio: 0.5)
        config.shouldSaveNewPicturesToAlbum = false
        
        profileSpinner = NVActivityIndicatorView(frame: CGRect(x: profileImage.frame.width / 2 - 30, y: profileImage.frame.height / 2 - 30, width: 60, height: 60), type: .circleStrokeSpin, color: .barflyblue, padding: 0)
        profileSpinner?.startAnimating()
        profileImage?.addSubview(profileSpinner!)
        
        var placeholder: UIImage?
        if #available(iOS 13.0, *) {
            placeholder = UIImage(systemName: "person")
        } else {
            // Fallback on earlier versions
            placeholder = UIImage(named: "profile")
        }
        
        if AppDelegate.user?.profileURL != "" {

            self.profileImage.getImage(ref: AppDelegate.user!.profileURL!, placeholder: placeholder!, maxMB: 40) {
                self.profileSpinner!.stopAnimating()
                self.profileSpinner!.isHidden = true
            }
        } else {
            self.profileImage.image = placeholder
            self.profileSpinner!.stopAnimating()
            self.profileSpinner!.isHidden = true
        }
        
        if 0 == AppDelegate.user!.galleryURLs.count {
            print("enabling save here")
            saveEnabled = true
        }  else {
            
            gallerySpinner = NVActivityIndicatorView(frame: CGRect(x: galleryView.frame.width / 2 - 20, y: galleryView.frame.height / 2 - 20, width: 40, height: 40), type: .circleStrokeSpin, color: .barflyblue, padding: 0)
            gallerySpinner!.startAnimating()
            galleryView?.addSubview(gallerySpinner!)
            
            var x = 0
            
            for i in AppDelegate.user!.galleryURLs {
                
                print("im here image url is \(i!)")
                
                UIImageView.downloadImage(from: URL(string: i!)!, completion: { (image) in
                    self.galleryImages.append(image)
                    self.galleryView.reloadData()
                    
                    print("image is \(image)")
                    
                    x+=1
                    if(x == AppDelegate.user!.galleryURLs.count) {
                        print("enabling save")
                        self.saveEnabled = true
                        self.gallerySpinner!.stopAnimating()
                        self.gallerySpinner!.isHidden = true
                    }
                }) {
                    
                }
                
            }
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
                   target: self,
                   action: #selector(EditProfileVC.dismissKeyboardAndPicker))

               tap.cancelsTouchesInView = false
               view.addGestureRecognizer(tap)
        
        
        
        galleryView.delegate = self
        galleryView.dataSource = self
        galleryView.reloadData()

    }
        
    override func viewDidAppear(_ animated: Bool) {
        User.getUser(uid: AppDelegate.user!.uid!) { (user: User?) in
            
            AppDelegate.user = user!
            
            self.name.text =  user?.name
            self.username.text = user?.username
            self.email.text =  user?.email
            self.password.text = UserDefaults.standard.string(forKey: "password")
            self.status.text = user?.status
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        if self.saveEnabled {
            print("i worked")
            saveProfile()
        } else {
            print("she wasnt rdy")
        }
        
    }

    @objc func dismissKeyboardAndPicker()
    {
        view.endEditing(true)
        pickerView.isHidden = true
    }
    
    func saveProfile() {
        
        savingView.alpha = 1
        savingProgress.text = "Saving your information and pictures..."
        indicator?.startAnimating()
        self.navigationController?.navigationBar.alpha = 0
        self.tabBarController?.tabBar.alpha = 0
        
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
                                AppDelegate.user?.status = self.status.text ?? ""
                                
                                self.savingProgress.text = "Saving your password..."

                                Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                                    if(error == nil) {
                                        UserDefaults.standard.set(password, forKey: "password")
                                    } else {
                                        self.password.text = UserDefaults.standard.string(forKey: "password")
                                    }
                                }
                                
                                self.savingProgress.text = "Saving your email..."

                                Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
                                    if(error == nil) {
                                        UserDefaults.standard.set(email, forKey: "email")
                                    } else {
                                        self.email.text = UserDefaults.standard.string(forKey: "email")
                                    }
                                })
                                
                                self.savingProgress.text = "Saving your profile picture..."
                                
                                if let image = self.image {
                                    self.saveFIRData(image: image)
                                }
                                
                                AppDelegate.user?.galleryURLs.removeAll()
                                
                                
                                self.savingProgress.text = "Saving your gallery images..."
                                
                                var x = 0
                                var num_finished = 0
                                for i in self.galleryImages {
                                    print("saving \(i)")
                                    self.saveGalleryFIRData(image: i, galleryNum: x, completion: {
                                        print("saved \(i)")
                                        num_finished+=1
                                        if(num_finished == self.galleryImages.count) {
                                            print("final update and pop back")
                                        
                                            self.navigationController?.navigationBar.alpha = 1
                                            self.tabBarController?.tabBar.alpha = 1

                                            User.updateUser(user: AppDelegate.user!)
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    })
                                    x+=1
                                }
                                
                                
                            } else {
                                self.errorLabel.text = "This email is not valid"
                                self.savingView.alpha = 0
                                self.indicator?.stopAnimating()
                                self.navigationController?.navigationBar.alpha = 1
                                self.tabBarController?.tabBar.alpha = 1

                            }
                
                        } else {
                            self.errorLabel.text = "This password is not long enough"
                            self.savingView.alpha = 0
                            self.indicator?.stopAnimating()
                            self.navigationController?.navigationBar.alpha = 1
                            self.tabBarController?.tabBar.alpha = 1

                        }
                    
                    } else {
                        self.errorLabel.text =  "This username is taken"
                        self.savingView.alpha = 0
                        self.indicator?.stopAnimating()
                        self.navigationController?.navigationBar.alpha = 1
                        self.tabBarController?.tabBar.alpha = 1

                    }
                    
                    
                    
                }
            }
            
        }
        
    }
    
    func saveFIRData(image: UIImage){
        self.uploadMedia(image: image){ url in
            self.saveImage(profileImageURL: url!){ success in
                //if you please ;)
            }
        }
    }
    
    func saveGalleryFIRData(image: UIImage, galleryNum: Int, completion: @escaping () -> Void ){
        
        self.uploadGalleryImage(image: image, galleryNum: galleryNum) { url, gallerNum in
            self.saveGalleryImage(galleryURL: url!, galleryNum: galleryNum, completion: {
                //if you please
                completion()
            })
        }
    }
    
    func uploadGalleryImage(image: UIImage, galleryNum: Int, completion: @escaping ((_ url: URL?, _ galleryNum: Int) -> ())) {
        let uid = (Auth.auth().currentUser?.uid)!
        let uidStr = uid + "_\(galleryNum).png"
        let storageRef = Storage.storage().reference().child(uidStr)
        let imgData = image.pngData()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storageRef.putData(imgData!, metadata: metaData) { (metadata, error) in
            if error == nil{
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url, galleryNum)
                })
            }else{
                print("error in save image")
                completion(nil, galleryNum)
            }
        }
        
    }
    
    func saveGalleryImage(galleryURL: URL, galleryNum: Int, completion: @escaping () -> Void) {
        AppDelegate.user?.galleryURLs.append(galleryURL.absoluteString)
        completion()
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
    
    func saveImage(profileImageURL: URL , completion: @escaping ((_ url: URL?) -> ())){
        
        AppDelegate.user?.profileURL = profileImageURL.absoluteString
        User.updateUser(user: AppDelegate.user!)
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.image = photo.image
                self.profileImage.image = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        updateNavBarSettings()
        present(picker, animated: true, completion: nil)
        
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        //check for any save needs
        
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(galleryImages.count < 4) {
            return galleryImages.count + 1
        } else {
            return 4
        }
      }
      
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(indexPath.row >= galleryImages.count) {
            //this is the add image button
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addImageCell", for: indexPath)
            
            cell.layer.cornerRadius = 40
            
            return cell
            
        } else {
            //this is a gallery image
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath) as! GalleryViewCell
            
            cell.galleryImage.layer.cornerRadius = 40
            cell.editButton.layer.cornerRadius = 5
            cell.deleteButton.layer.cornerRadius = 5
            
            cell.deleteButton.addTarget(self, action: #selector(deleteImage(sender:)), for: .touchUpInside)
            cell.editButton.addTarget(self, action: #selector(editImage(sender:)), for: .touchUpInside)
            
            cell.galleryImage.image = galleryImages[indexPath.row]
            cell.editButton.tag = indexPath.row
            cell.deleteButton.tag = indexPath.row
            
            return cell
        }
      }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row >= galleryImages.count) {
            
            let picker = YPImagePicker(configuration: config)
            picker.didFinishPicking { [unowned picker] items, _ in
                if let photo = items.singlePhoto {
                    self.galleryImages.append(photo.image)
                    self.galleryView.reloadData()
                }
                picker.dismiss(animated: true, completion: nil)
            }
            updateNavBarSettings()
            
            self.navigationController?.present(picker, animated: true)
            
            
            //add button
        } else {
            //other image
        }
    }
    
    @objc func editImage(sender: UIButton) {
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.galleryImages[sender.tag] = photo.image
                self.galleryView.reloadData()
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        updateNavBarSettings()
        present(picker, animated: true, completion: nil)
        
    }
    
    @objc func deleteImage(sender: UIButton) {
        self.confirmIndex = sender.tag
        self.confirmImageView.image = galleryImages[confirmIndex]
        self.navbar = self.navigationController?.navigationBar
        self.navigationController?.navigationBar.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.confirmView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func confirmDelete() {
        self.galleryImages.remove(at: confirmIndex)
        self.galleryView.reloadData()
        self.navigationController?.navigationBar.alpha = 1
        cancelDelete()
    }
    
    @objc func cancelDelete() {
        self.confirmIndex = -1
        self.navigationController?.navigationBar.alpha = 1
        UIView.animate(withDuration: 0.5) {
            self.confirmView.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func hideNavBar() {
        
    }
    
    func showNavBar() {
        
    }
    
    func updateNavBarSettings() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.barflyblue ]
        UINavigationBar.appearance().tintColor = .barflyblue
        UINavigationBar.appearance().backgroundColor = .black
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statuses.count
     }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statuses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        status.text = statuses[row]
        self.pickerView.isHidden = true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        print("I AM THE DELEGATE WHOW")
        
        pickerView.isHidden = false
        return false
    }
}
