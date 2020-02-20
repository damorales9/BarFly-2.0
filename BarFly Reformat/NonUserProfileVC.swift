//
//  NonUserProfile.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/3/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseUI

class NonUserProfileVC: UIViewController, UIScrollViewDelegate {
    
    
    
    var nonUser: User?
    
    var confirm = false
    var confirmUnfollow = false
    
    @IBOutlet weak var dragIndicator: UILabel!
    @IBOutlet weak var fieldView: UIView!
    
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var block: UIButton!
    @IBOutlet weak var cancelBlock: UIButton!
    @IBOutlet weak var following: UIButton!
    @IBOutlet weak var numFollowing: UILabel!
    @IBOutlet weak var followers: UIButton!
    @IBOutlet weak var numFollowers: UILabel!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var cancelUnfollowView: UIView!
    @IBOutlet weak var cancelUnfollow: UIButton!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var barChoice: UIImageView!
    @IBOutlet weak var barChoiceLbl: UILabel!
    
    var profileSpinner = UIActivityIndicatorView(style: .whiteLarge)
    var barChoiceSpinner = UIActivityIndicatorView(style: .whiteLarge)

    var scrollView: UIScrollView?
    var profileImage: UIImageView?
    var galleryImages = [UIImageView]()
    
    var centerConstraint: NSLayoutConstraint!
    var startingConstant: CGFloat  = -200
    
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    @IBOutlet weak var pageControl: UIPageControl!
    
    var trailingFollowConstraint: NSLayoutConstraint!
    var trailingUnfollowConstraint: NSLayoutConstraint!

    var cancelWidthConstraint: NSLayoutConstraint!
    var cancelUnfollowWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        dragIndicator.layer.cornerRadius = 5
        follow.layer.cornerRadius = 10
        following.layer.cornerRadius = 10
        followers.layer.cornerRadius = 10
        fieldView.layer.cornerRadius = 30
        fieldView.layer.borderColor =  UIColor.barflyblue.cgColor
        fieldView.layer.borderWidth = 4
        follow.layer.borderColor = UIColor.black.cgColor
        follow.layer.borderWidth = 2
        block.layer.borderColor = UIColor.barflyblue.cgColor
        block.layer.borderWidth = 2
        block.layer.cornerRadius = 10
        cancelBlock.layer.cornerRadius = 10
        cancelBlock.layer.borderWidth = 2
        cancelBlock.layer.borderColor = UIColor.black.cgColor
        cancelView.layer.cornerRadius = 10
        cancelUnfollowView.layer.cornerRadius = 10
        cancelUnfollow.layer.cornerRadius = 10
        cancelUnfollow.layer.borderWidth = 2
        cancelUnfollow.layer.borderColor = UIColor.black.cgColor
        blockView.layer.cornerRadius = 10
        followView.layer.cornerRadius = 10
        
        trailingFollowConstraint = NSLayoutConstraint(item: blockView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -50)
        
        trailingUnfollowConstraint = NSLayoutConstraint(item: followView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -50)
        
        cancelWidthConstraint = NSLayoutConstraint(item: cancelView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        
        cancelUnfollowWidthConstraint = NSLayoutConstraint(item: cancelUnfollowView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)

        cancelView.addConstraint(cancelWidthConstraint)
        cancelUnfollowView.addConstraint(cancelUnfollowWidthConstraint)
        
        view.addConstraint(trailingFollowConstraint)
        view.addConstraint(trailingUnfollowConstraint)
        
        self.centerConstraint = fieldView.topAnchor.constraint(equalTo: view.bottomAnchor)
        self.centerConstraint.constant = startingConstant
        self.centerConstraint.isActive = true
        
        fieldView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
        
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
    
        
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        fieldView.addGestureRecognizer(gesture)
        fieldView.isUserInteractionEnabled = true
        
        
        following.addTarget(self, action: #selector(showFollowing), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateFieldView()
    }
    
    func getFollowers(){
        Firestore.firestore().collection(LoginVC.USER_DATABASE).whereField("friends", arrayContains: nonUser?.uid).getDocuments { (snapshot,err)in (snapshot, err)
            self.numFollowers.text = "\(snapshot!.documents.count)"
        }
    }
    
    
    func updateFieldView() {
        
        User.getUser(uid: AppDelegate.user!.uid!) { (currentUser: User?) in
            AppDelegate.user = currentUser!
        
            User.getUser(uid: self.nonUser!.uid!) { (user: User?) in
                
                self.nonUser = user!
        
                if let user = self.nonUser {
                    
                    self.title = user.username
                    
                    self.name.text = user.name
                    self.username.text = user.username
                    self.numFollowing.text = "\(user.friends.count)"
                    self.getFollowers()
                    
                    if(user.friends.contains(AppDelegate.user?.uid)) {
                        self.blockView.isHidden = false
                        if((AppDelegate.user?.blocked.contains(user.uid))!) {
                            self.block.setTitle("Unblock", for: .normal)
                            self.block.setTitleColor(.barflyblue, for: .normal)
                            self.block.layer.borderColor = UIColor.barflyblue.cgColor
                            self.blockView.backgroundColor = .black
                        } else {
                            self.block.setTitle("Block", for: .normal)
                            self.block.setTitleColor(.black, for: .normal)
                            self.block.layer.borderColor = UIColor.black.cgColor
                            self.blockView.backgroundColor = .red
                        }
                    } else {
                        self.blockView.isHidden = true
                    }
                    
                    var placeholder: UIImage?
                    if #available(iOS 13.0, *) {
                        placeholder = UIImage(systemName: "questionmark")
                    } else {
                        // Fallback on earlier versions
                        placeholder = UIImage(named: "first")
                    }
                    self.barChoice.image = placeholder
                    
                    
                    if user.profileURL != "" {
                        
                        self.profileImage!.getImage(ref: user.profileURL!, placeholder: placeholder!, maxMB: 40) {
                            self.profileSpinner.stopAnimating()
                            self.profileSpinner.isHidden = true
                            self.configurePageControl()
                            
                            for i in 0..<self.nonUser!.galleryURLs.count {
                                
                                self.galleryImages[i].getImage(ref: user.galleryURLs[i]!, placeholder: placeholder!, maxMB: 40) {
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
                    
                
                    if((currentUser?.friends.contains(user.uid))!) {
                        
                        self.follow.setTitle("Unfollow", for: .normal);
                        self.follow.backgroundColor = .red
                        self.followView.backgroundColor = .red
                        
                        if(user.bar == "nil" || user.blocked.contains(currentUser?.uid!)) {
                            self.barChoiceLbl.text = self.getStatusMessage()
                        } else {
                            self.barChoiceLbl.text = self.getStatusMessage()
                            
                            
                           
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
                                    
                                    self.barChoiceSpinner.translatesAutoresizingMaskIntoConstraints = false
                                    self.barChoiceSpinner.startAnimating()
                                    self.barChoice?.addSubview(self.barChoiceSpinner)

                                    self.barChoiceSpinner.centerXAnchor.constraint(equalTo: self.barChoice!.centerXAnchor).isActive = true
                                    self.barChoiceSpinner.centerYAnchor.constraint(equalTo: self.barChoice!.centerYAnchor).isActive = true
                                    
                                    
                                    self.barChoice.getImage(ref: imageURL, placeholder: placeholder!, maxMB: 40) {
                                        self.barChoiceSpinner.stopAnimating()
                                        self.barChoiceSpinner.isHidden = true
                                    }
                                        
                                }
                            }
                        }
                    } else if (user.friends.contains(AppDelegate.user?.uid) && !user.requests.contains(AppDelegate.user?.uid)) {
                        
                        self.follow.setTitle("Follow Back", for: .normal);
                        self.follow.backgroundColor = .barflyblue
                        self.followView.backgroundColor = .barflyblue
                        
                        self.barChoiceLbl.text = "Follow \(user.name!) back to see where they're going!"
                    } else if (!user.friends.contains(AppDelegate.user?.uid) && !user.requests.contains(AppDelegate.user?.uid)) {
                        
                        self.follow.setTitle("Follow", for: .normal);
                        self.follow.backgroundColor = .barflyblue
                        self.followView.backgroundColor = .barflyblue
                                       
                        self.barChoiceLbl.text = "Follow \(user.name!) to see where they're going!"
                        
                    } else if (user.requests.contains(AppDelegate.user?.uid)) {
                        
                        self.follow.setTitle("Cancel Request", for: .normal);
                        self.follow.backgroundColor = .gray
                        self.followView.backgroundColor = .gray
                                                      
                        self.barChoiceLbl.text = "Once \(user.name!) accepts you can see where they're going!"
                        
                    }
                }
            }
        }
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
                    self.centerConstraint.constant = -600
                    self.view.layoutIfNeeded()
                }
            } else {
                print("too low")
                
                UIView.animate(withDuration: 0.3) {
                    self.startingConstant = -200
                    self.centerConstraint.constant = self.startingConstant
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }

    }
    
    @objc func showFollowing() {
        print("show me following")
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        confirm = false
        
        UIView.animate(withDuration: 0.5) {
            self.trailingFollowConstraint.constant = -50
            self.cancelView.isHidden = true
            self.cancelWidthConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func cancelUnfollowButtonClicked(_ sender: Any) {
        confirmUnfollow = false
        
        UIView.animate(withDuration: 0.5) {
            self.trailingUnfollowConstraint.constant = -50
            self.cancelUnfollowView.isHidden = true
            self.cancelUnfollowWidthConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func blockButtonClicked(_ sender: Any) {
        
        if(confirm) {
            
            if((AppDelegate.user?.blocked.contains(self.nonUser!.uid))!) {
                    
                    User.getUser(uid: AppDelegate.user!.uid!) { (user) in
                        AppDelegate.user = user!
                        
                        AppDelegate.user?.blocked.remove(at: (user?.blocked.firstIndex(of: self.nonUser?.uid))!)
                        
                        User.updateUser(user: AppDelegate.user)
                        
                        self.updateFieldView()
                                                   
                        UIView.animate(withDuration: 0.5) {
                            self.trailingFollowConstraint.constant = -50
                            self.cancelView.isHidden = true
                            self.cancelWidthConstraint.constant = 0
                            self.view.layoutIfNeeded()
                                    
                        }
                        self.confirm = false
                    
                    }
                
                } else {
                    User.getUser(uid: AppDelegate.user!.uid!, setFunction: { (user: User?) -> Void in

                            AppDelegate.user = user!
                            
        
                            AppDelegate.user?.blocked.append(self.nonUser?.uid)
                            
                        
                            User.updateUser(user: AppDelegate.user)
                            
                            self.updateFieldView()
                            
                            UIView.animate(withDuration: 0.5) {
                                self.trailingFollowConstraint.constant = -50
                                self.cancelView.isHidden = true
                                self.cancelWidthConstraint.constant = 0
                                self.view.layoutIfNeeded()
                                
                            }
                            self.confirm = false

                        })
                    }
            
        } else {
            
            UIView.animate(withDuration: 0.5) {
                self.trailingFollowConstraint.constant = -110
                self.cancelView.isHidden = false
                self.cancelWidthConstraint.constant = 50
                self.view.layoutIfNeeded()
                
            }
            confirm = true
        }
    }
    
    @IBAction func followButtonClicked(_ sender: Any) {
            
            User.getUser(uid: self.nonUser!.uid!, setFunction: { (user: User?) -> Void in
                self.nonUser = user!
                
                if let user = self.nonUser {
                    
                    if ((AppDelegate.user?.friends.contains(user.uid))!) {
                        
                        //UNFOLLOW CASE
                        
                        if(self.confirmUnfollow) {
                            
                            UIView.animate(withDuration: 0.5) {
                                self.trailingUnfollowConstraint.constant = -50
                                self.cancelUnfollowView.isHidden = false
                                self.cancelUnfollowWidthConstraint.constant = 0
                                self.view.layoutIfNeeded()
                                
                            }
                        
                            AppDelegate.user!.friends.remove(at: (AppDelegate.user!.friends.firstIndex(of: user.uid)!))
                            self.nonUser?.followers.remove(at: user.followers.firstIndex(of: AppDelegate.user?.uid)!)
                            if (user.blocked.contains(AppDelegate.user?.uid)) {
                                self.nonUser?.blocked.remove(at: user.blocked.firstIndex(of: AppDelegate.user?.uid)!)
                            }
                            
                            self.updateFieldView()
                            User.updateUser(user: AppDelegate.user)
                            User.updateUser(user: self.nonUser)
                            
                            self.confirmUnfollow = false
                            
                        } else {
                         
                            self.confirmUnfollow = true
                            
                            UIView.animate(withDuration: 0.5) {
                                self.trailingUnfollowConstraint.constant = -110
                                self.cancelUnfollowView.isHidden = false
                                self.cancelUnfollowWidthConstraint.constant = 50
                                self.view.layoutIfNeeded()
                                
                            }
                            
                            return
                            
                        }

                        
                    } else if (!(AppDelegate.user?.friends.contains(user.uid))! && !(user.requests.contains(AppDelegate.user?.uid))) {
                        
                        //REQUEST CASE
                        
                        self.nonUser!.requests.append(AppDelegate.user?.uid)
                        let userToken = user.messagingID ?? ""
                        let notifPayload: [String: Any] = ["to": userToken,"notification": ["title":"\(self.getRequestMessage())","body":" \(AppDelegate.user!.username!) has requested to follow you","badge":1,"sound":"default"]]
                        User.sendPushNotification(payloadDict: notifPayload)
                        
                        
                        
                    } else if (!(AppDelegate.user?.friends.contains(user.uid))! &&  (user.requests.contains(AppDelegate.user?.uid))) {
                        
                        //REMOVE REQUEST
                        
                        self.nonUser?.requests.remove(at: (user.requests.firstIndex(of: AppDelegate.user?.uid))!)
                       
                    }
                
                    self.updateFieldView()
                    User.updateUser(user: AppDelegate.user)
                    User.updateUser(user: self.nonUser)
                }
                
            })
        
    }
    
    func getStatusMessage() -> String {
        if let user = nonUser, let name = user.name, let bar = user.bar, let status = user.status {
            return "\(name) is \(status) at \(bar == LoginVC.NO_BAR ? "home" : bar ). \(getSass())"
        } else {
            return "ERROR"
        }
    }
    
    func getSass() -> String {
        
        if let user = nonUser, let name = user.name, let bar = user.bar {
            if user.bar == LoginVC.NO_BAR {
                let number = Int.random(in: 0 ..< 5)
                switch number {
                case 0: return "Great tactic, \(name). That'll show that slut from marketing."
                case 1: return "K."
                case 2: return "Probably gonna say they had a great night but we know they didn't."
                case 3: return "If society says your weird if you bring your flashcards to \(bar), then just don't study."
                default: return "Go out for once you peice of sh*t."
                }
            } else {
                if user.status == User.CLAM {
                    let number = Int.random(in: 0 ..< 5)
                    switch number {
                    case 0: return "Great tactic, \(name). I hope that works out for you."
                    case 1: return "Why not make it the full package? #freethenip"
                    case 2: return "Bold, \(name). Bold."
                    case 3: return "Hope the bathroom lines aren't too long."
                    default: return "I'm jsut gonna say it. Thas nasty yo."
                    }
                } else if (user.status == User.COMPLICATED) {
                    let number = Int.random(in: 0 ..< 5)
                    switch number {
                    case 0: return "Great tactic, \(name). Nothing resolves conflict like drinking heavily."
                    case 1: return "Let's be real, that basically just means they're taken."
                    case 2: return "I feel like I shouldn't have added this as a status."
                    case 3: return "Nobody cares about your problems, \(name)"
                    default: return "K."
                    }
                } else {
                    return "ERROR"
                }
            }
        } else {
            return "ERROR"
        }
    }
    
    func getRequestMessage() -> String {
        
        let number = Int.random(in: 0 ..< 10)
        
        switch number {
        case 0: return "LMAO Someone wants to follow you"
        case 1: return "Put your dentures back in, Barbara"
        case 2: return "Don't get your panties knackered, Jessica"
        case 3: return "Focus on your career some other night"
        case 4: return "Go out for once you peice of sh*t"
        case 5: return "This was probably just a sex bot"
        case 6: return "Wake up George! Time to lose your re-virginity"
        case 7: return "TBD2"
        case 8: return "TBD3"
        default:
            return "New Follow Request"
        }
        
    }
    
    func okCancel(msg: String, after: @escaping () -> Void) {
        let refreshAlert = UIAlertController(title: "Refresh", message: msg, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            after()
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))

        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func followingBtnClicked(_ sender: Any) {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let listVC = storyBoard.instantiateViewController(withIdentifier: "nonUserList") as! NonUserListVC
            listVC.isFollowers = false
            listVC.nonUser = self.nonUser!
            self.navigationController?.pushViewController(listVC, animated:true)
       }
       
       @IBAction func followersBtnClicked(_ sender: Any) {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let listVC = storyBoard.instantiateViewController(withIdentifier: "nonUserList") as! NonUserListVC
            listVC.isFollowers = true
            listVC.nonUser = self.nonUser!
            self.navigationController?.pushViewController(listVC, animated:true)
       }
    
    func configurePageControl() {
    
           // The total number of pages that are available is based on how many available colors we have.
           self.pageControl.numberOfPages = (nonUser?.galleryURLs.count)! + 1
           
           self.scrollView?.contentSize = CGSize(width: self.view.frame.width * CGFloat((nonUser?.galleryURLs.count)! + 1), height: scrollView!.frame.size.height)
           
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
    
}

extension UIColor {
    static let barflyblue = UIColor(red: 0.71, green: 1.00, blue: 0.99, alpha: 1.0)
}
