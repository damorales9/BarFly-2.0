//
//  CreatePregameVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 3/1/20.
//  Copyright © 2020 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import YPImagePicker
import NVActivityIndicatorView

class CreatePregameVC: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var savePregame: UINavigationItem!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var acceptedButton: UIButton!
    @IBOutlet weak var invitedButton: UIButton!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var numAccepted: UILabel!
    @IBOutlet weak var numInvited: UILabel!
    @IBOutlet weak var galleryView: UICollectionView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var confirmImageView: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmButtonView: UIView!
    @IBOutlet weak var cancelButtonView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var savingView: UIView!
    @IBOutlet weak var savingProgress: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var changeProfile: UIButton!
    
    
    var galleryImages = [UIImage]()
    var gallerySpinner: NVActivityIndicatorView?
    var profileSpinner: NVActivityIndicatorView?
    var indicator: NVActivityIndicatorView?
    
    var config = YPImagePickerConfiguration()
    var image: UIImage?
    var confirmIndex = -1
    var saveEnabled = false
    var navbar: UINavigationBar?
    
    
    var pregame: Pregame?
    
    override func viewDidLoad() {
        
        date.delegate = self
        
        galleryView.delegate = self
        galleryView.dataSource = self
        
        date.layer.cornerRadius = 5
        date.layer.borderWidth = 0
        date.layer.borderColor = UIColor.barflyblue.cgColor
        
        location.layer.cornerRadius = 5
        location.layer.borderWidth = 0
        location.layer.borderColor = UIColor.barflyblue.cgColor
        
        desc.layer.cornerRadius = 5
        desc.layer.borderWidth = 0
        desc.layer.borderColor = UIColor.barflyblue.cgColor
        
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
            
        self.date.setInputViewDatePicker(target: self, selector: #selector(tapDone))
        
        indicator = NVActivityIndicatorView(frame: CGRect(x: savingView.frame.width / 2 - 50, y: savingView.frame.height / 2 - 50, width: 100, height: 100), type: .circleStrokeSpin, color: .barflyblue, padding: 0)
        
        savingView.addSubview(indicator!)

        config.colors.tintColor = .barflyblue
        config.onlySquareImagesFromCamera = false
        config.screens = [.library]
        config.library.maxNumberOfItems = 1
        config.showsCrop = .rectangle(ratio: 0.5)
        config.shouldSaveNewPicturesToAlbum = false
        
        self.galleryView.reloadData()


    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let pregame = pregame, let location = pregame.location, let date = pregame.date, let description = pregame.description {
            
            self.numAccepted.text = "\(pregame.accepted.count)"
            self.numInvited.text = "\(pregame.invited.count)"
            self.location.text = "\(location)"
            self.date.text = "\(date)"
            self.desc.text = "\(description)"
            
            
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
            
            if pregame.profileURL != "" {

                self.profileImage.kf.setImage(with: URL(string: pregame.profileURL!)) {result in
                    self.profileSpinner!.stopAnimating()
                    self.profileSpinner!.isHidden = true
                }

            } else {
                self.profileImage.image = placeholder
                self.profileSpinner!.stopAnimating()
                self.profileSpinner!.isHidden = true
            }
            
            if 0 == pregame.galleryURLs.count {
                print("enabling save here")
                saveEnabled = true
            }  else {
                
                gallerySpinner = NVActivityIndicatorView(frame: CGRect(x: galleryView.frame.width / 2 - 20, y: galleryView.frame.height / 2 - 20, width: 40, height: 40), type: .circleStrokeSpin, color: .barflyblue, padding: 0)
                gallerySpinner!.startAnimating()
                galleryView?.addSubview(gallerySpinner!)
                
                var x = 0
                
                for i in pregame.galleryURLs {
                    
                    print("im here image url is \(i!)")
                    
                    let tmp = UIImageView()
                    tmp.kf.setImage(with: URL(string: i!)) {result in
                        self.galleryImages.append(tmp.image!)
                        self.galleryView.reloadData()
                        
                        print("image is \(tmp.image)")
                        
                        x+=1
                        if(x == self.pregame!.galleryURLs.count) {
                            print("enabling save")
                            self.saveEnabled = true
                            self.gallerySpinner!.stopAnimating()
                            self.gallerySpinner!.isHidden = true
                        }
                    }
                    
                }
                
            }
            
        } else {
            pregame = Pregame.newPregame(creator: AppDelegate.user!.uid!)
            
            self.numAccepted.text = "0"
            self.numInvited.text = "0"
                 
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

    func saveProfile() {
        
        savingView.alpha = 1
        savingProgress.text = "Saving your information and pictures..."
        indicator?.startAnimating()
        self.navigationController?.navigationBar.alpha = 0
        self.tabBarController?.tabBar.alpha = 0
            
        if let location = self.location.text, let date = self.date.text {
            
            if self.pregame?.uid == Pregame.NEW {
            
                Pregame.getPregame(uid: Firestore.firestore().collection(LoginVC.PREGAME_DATABASE).addDocument(data: [:]).documentID) { (p) in
                    
                    var pregame = p
                    
                    self.savingProgress.text = "Saving event information..."
                    
                    pregame?.location = location
                    pregame?.description = self.desc.text ?? ""
                    pregame?.date = date
                    
                    pregame?.blocked = self.pregame!.blocked
                    pregame?.invited = self.pregame!.invited
                    
                    self.savingProgress.text = "Saving the profile picture..."
                                                                      
                    if let image = self.image {
                        self.saveFIRData(image: image)
                    }
                       
                    pregame?.galleryURLs.removeAll()
                                                      
                                                      
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

                                Pregame.updatePregame(pregame: pregame)
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                        x+=1
                    }
                    
                }
                
            } else {
                    
                Pregame.getPregame(uid: self.pregame!.uid!) { (p) in
                    var pregame = p
                    
                    self.savingProgress.text = "Saving event information..."
                    
                    pregame?.location = location
                    pregame?.description = self.desc.text ?? ""
                    pregame?.date = date

                    self.savingProgress.text = "Saving the profile picture..."
                                                                      
                    if let image = self.image {
                        self.saveFIRData(image: image)
                    }
                       
                    pregame?.galleryURLs.removeAll()
                                                      
                                                      
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

                                Pregame.updatePregame(pregame: pregame)
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                        x+=1
                    }
                }
                        
            }
            
        } else {
            self.errorLabel.text = "You must set date and location"
            self.savingView.alpha = 0
            self.indicator?.stopAnimating()
            self.navigationController?.navigationBar.alpha = 1
            self.tabBarController?.tabBar.alpha = 1
            
        }
    }
     
    
    //2
        @objc func tapDone() {
            if let datePicker = self.date.inputView as? UIDatePicker { // 2-1
                let dateformatter = DateFormatter() // 2-2
                dateformatter.dateStyle = .medium // 2-3
                dateformatter.timeStyle = .short
                self.date.text = dateformatter.string(from: datePicker.date) //2-4
            }
            self.date.resignFirstResponder() // 2-5
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
        self.pregame?.galleryURLs.append(galleryURL.absoluteString)
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
        
        self.pregame?.profileURL = profileImageURL.absoluteString
        Pregame.updatePregame(pregame: pregame)
    }
    
    
}

extension UITextField {
     
     func setInputViewDatePicker(target: Any, selector: Selector) {
         // Create a UIDatePicker object and assign to inputView
         let screenWidth = UIScreen.main.bounds.width
         let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.backgroundColor = .barflyblue
        
         datePicker.datePickerMode = .dateAndTime //2
         self.inputView = datePicker //3
         
         // Create a toolbar and assign it to inputAccessoryView
         let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) //4
         let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //5
         let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel)) // 6
         let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector) //7
         toolBar.setItems([cancel, flexible, barButton], animated: false) //8
         self.inputAccessoryView = toolBar //9
     }
     
     @objc func tapCancel() {
         self.resignFirstResponder()
     }
     
 }
