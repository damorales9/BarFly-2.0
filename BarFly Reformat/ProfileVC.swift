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

class ProfileVC: UIViewController, UIScrollViewDelegate {
        
    //VAR
    
    var editting = false
    
    //UI
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
    
    var profileSpinner = UIActivityIndicatorView(style: .whiteLarge)
    var barChoiceSpinner = UIActivityIndicatorView(style: .whiteLarge)

    var scrollView: UIScrollView?
    var profileImage: UIImageView?
    var galleryImages = [UIImageView]()
    
    var centerConstraint: NSLayoutConstraint!
    var startingConstant: CGFloat  = -250
    
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    @IBOutlet weak var pageControl: UIPageControl!
    
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
                   self.centerConstraint.constant -= 20
                   self.view.layoutIfNeeded()
               }, completion: { (value: Bool) in
                   UIView.animate(withDuration: 0.3) {
                       self.centerConstraint.constant += 20
                       self.view.layoutIfNeeded()
                   }
               })
        
        self.pageControl.currentPageIndicatorTintColor = .barflyblue
        self.scrollView = UIScrollView(frame: CGRect(x:0, y:0, width: view.frame.width, height: view.frame.height))
        self.scrollView!.delegate = self
        self.scrollView!.isPagingEnabled = true
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.contentInsetAdjustmentBehavior = .never
        self.view.addSubview(pageControl)
        self.view.addSubview(self.scrollView!)
        self.view.sendSubviewToBack(scrollView!)
        self.configurePageControl()
        
        self.frame.origin.x = 0
        self.frame.size = self.scrollView!.frame.size
        profileImage = UIImageView(frame: frame)
        profileImage?.contentMode = .scaleAspectFill
        profileImage?.clipsToBounds = true
        profileImage?.tintColor = .barflyblue
        self.scrollView?.addSubview(self.profileImage!)
        
        for index in 1...4 {
            
            print("we at \(index) mother fucker")

            self.frame.origin.x = self.scrollView!.frame.size.width * CGFloat(index)
            self.frame.size = self.scrollView!.frame.size
            
            let iv = UIImageView(frame: frame)
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            self.scrollView?.addSubview(iv)
            self.galleryImages.append(iv)
            
        }
        
        profileSpinner.translatesAutoresizingMaskIntoConstraints = false
        profileSpinner.startAnimating()
        profileImage?.addSubview(profileSpinner)

        profileSpinner.centerXAnchor.constraint(equalTo: profileImage!.centerXAnchor).isActive = true
        profileSpinner.centerYAnchor.constraint(equalTo: profileImage!.centerYAnchor).isActive = true
        
        self.pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
        
        
    }
    
    
    
    func unpaintComponents() {
        
//        requestsButton.tintColor = .clear
//        changeBarChoice.tintColor = .clear
//        settingsButton.tintColor = .clear
        
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
                
                self.title = user.username
                
                self.navigationController?.isNavigationBarHidden = false
                self.name.text = user.name
                self.username.text = user.username
                self.numFollowing.text = "\(user.friends.count)"
                self.numFollowers.text = "\(user.followers.count)"
                
                
                var placeholder: UIImage?
                if #available(iOS 13.0, *) {
                    placeholder = UIImage(systemName: "person")
                } else {
                    // Fallback on earlier versions
                    placeholder = UIImage(named: "profile")
                }
                    
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk()
    
                
                if AppDelegate.user?.profileURL != "" {
                    self.profileImage!.getImage(ref: user.profileURL!, placeholder: placeholder!, maxMB: 40) {
                        self.profileSpinner.stopAnimating()
                        self.profileSpinner.isHidden = true
                        self.configurePageControl()
                        
                        for i in 0..<AppDelegate.user!.galleryURLs.count {
                            
                            self.galleryImages[i].getImage(ref: AppDelegate.user!.galleryURLs[i]!, placeholder: placeholder!, maxMB: 40) {
                                self.configurePageControl()
                            }
                            
                        }
                    }
                } else {
                    self.profileImage?.image = placeholder
                    self.profileSpinner.stopAnimating()
                    self.profileSpinner.isHidden = true
                    self.configurePageControl()
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
                            
                            self.barChoiceSpinner.translatesAutoresizingMaskIntoConstraints = false
                            self.barChoiceSpinner.startAnimating()
                            self.barChoice?.addSubview(self.barChoiceSpinner)

                            self.barChoiceSpinner.centerXAnchor.constraint(equalTo: self.barChoice!.centerXAnchor).isActive = true
                            self.barChoiceSpinner.centerYAnchor.constraint(equalTo: self.barChoice!.centerYAnchor).isActive = true
                            
                            self.barChoice.getImage(ref: imageURL, placeholder: placeholder!, maxMB: 6) {
                                self.barChoiceSpinner.stopAnimating()
                                self.barChoiceSpinner.isHidden = true
                            }
                                
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
            print("i was in here LMFAO")
            self.paintComponents()
            self.updateBadge()
                
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
            fieldView.addGestureRecognizer(gesture)
            fieldView.isUserInteractionEnabled = true
        }
        
    }
    
    func updateBadge() {
        if(AppDelegate.user?.requests.count != 0){
            self.navigationController?.tabBarItem.badgeValue = "\(AppDelegate.user!.requests.count)"
        } else {
            self.navigationController?.tabBarItem.badgeValue = nil
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
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        if (AppDelegate.loggedIn) {
            self.pageControl.numberOfPages = (AppDelegate.user?.galleryURLs.count)! + 1
            self.scrollView?.contentSize = CGSize(width: self.view.frame.width * CGFloat((AppDelegate.user?.galleryURLs.count)! + 1), height: scrollView!.frame.size.height)
        }
        
        print("set page number")
    }

    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView!.frame.size.width
        scrollView!.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    @IBAction func changeChoiceClicked(_ sender: Any) {
        self.navigationController?.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let editVC = storyBoard.instantiateViewController(withIdentifier: "EditProfile") as! EditProfileVC
        editVC.delegate = self
        self.navigationController?.pushViewController(editVC, animated:true)
    }
    
}

extension UIImage {
    
    static func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {

        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }
}
