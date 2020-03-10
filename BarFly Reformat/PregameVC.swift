
import Foundation
import UIKit

class PregameVC: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet weak var pregameTitle: UILabel!
    @IBOutlet weak var pregameSubtitle: UILabel!
    
    @IBOutlet weak var dragIndicator: UILabel!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var changeChoiceButton: UIButton!
    
    @IBOutlet weak var showAcceptedButton: UIButton!
    @IBOutlet weak var numAccepted: UILabel!
    
    @IBOutlet weak var numInvited: UILabel!
    
    @IBOutlet weak var showInvitedButton: UIButton!
    
    @IBOutlet weak var cancelChangeView: UIView!
    @IBOutlet weak var cancelChangeButton: UIButton!
    
    @IBOutlet weak var pregameDescription: UILabel!
    
    @IBOutlet weak var fieldView: UIView!
    
    var trailingChangeChoiceViewConstraint: NSLayoutConstraint!
    var cancelChangeViewWidth: NSLayoutConstraint!
    
    var profileSpinner = UIActivityIndicatorView(style: .whiteLarge)

    var scrollView: UIScrollView?
    var profileImage: UIImageView?
    var galleryImages = [UIImageView]()
    
    var centerConstraint: NSLayoutConstraint!
    var startingConstant: CGFloat  = -200
    
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    
    var pregame: Pregame?
    
    override func viewDidLoad() {
        
        dragIndicator.layer.cornerRadius = 5
        changeChoiceButton.layer.cornerRadius = 10
        showInvitedButton.layer.cornerRadius = 10
        showAcceptedButton.layer.cornerRadius = 10
        fieldView.layer.cornerRadius = 30
        fieldView.layer.borderColor =  UIColor.barflyblue.cgColor
        fieldView.layer.borderWidth = 4
        changeChoiceButton.layer.borderColor = UIColor.black.cgColor
        changeChoiceButton.layer.borderWidth = 2
        cancelChangeButton.layer.cornerRadius = 10
        cancelChangeView.layer.cornerRadius = 10
        buttonView.layer.cornerRadius = 10
        
        trailingChangeChoiceViewConstraint = NSLayoutConstraint(item: buttonView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -50)
               
               
        cancelChangeViewWidth = NSLayoutConstraint(item: cancelChangeView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
               

        cancelChangeView.addConstraint(cancelChangeViewWidth)
               
        view.addConstraint(trailingChangeChoiceViewConstraint)
               
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
            
            self.frame.origin.x = self.scrollView!.frame.size.width *   CGFloat(index)
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
   
       
       
        let gesture = UIPanGestureRecognizer(target: self, action:    #selector(wasDragged))
        fieldView.addGestureRecognizer(gesture)
        fieldView.isUserInteractionEnabled = true
       
       
        showAcceptedButton.addTarget(self, action: #selector(showAccepted), for: .touchUpInside)
        showInvitedButton.addTarget(self, action: #selector(showInvited), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let pregame = pregame, let createdBy = pregame.createdBy, let location = pregame.location, let description = pregame.description, let date = pregame.date, let profileURL = pregame.profileURL {
            
            self.pregameTitle.text = "\(getName(name: createdBy)) "
            self.pregameSubtitle.text = "on \(date) at \(location)"
            self.pregameDescription.text = description
            
            self.numAccepted.text = "\(pregame.accepted.count)"
            self.numInvited.text = "\(pregame.invited.count)"
            
            
            if pregame.accepted.contains(AppDelegate.user?.uid) {
                
                changeChoiceButton.backgroundColor = .green
                buttonView.backgroundColor = .green
                changeChoiceButton.setTitle("Accepted", for: .normal)
                
                trailingChangeChoiceViewConstraint.constant = 0
                cancelChangeViewWidth.constant = 0
                
            } else if pregame.declined.contains(AppDelegate.user?.uid) {
                
                changeChoiceButton.backgroundColor = .red
                buttonView.backgroundColor = .red
                changeChoiceButton.setTitle("Declined", for: .normal)
                
                trailingChangeChoiceViewConstraint.constant = 0
                cancelChangeViewWidth.constant = 0
                
            } else {
                
                changeChoiceButton.backgroundColor = .barflyblue
                buttonView.backgroundColor = .barflyblue
                changeChoiceButton.setTitle("Accept", for: .normal)
                
                cancelChangeView.backgroundColor = .red
                cancelChangeButton.backgroundColor = .red
                cancelChangeButton.setTitle("Decline", for: .normal)
                
                trailingChangeChoiceViewConstraint.constant = 0
                cancelChangeViewWidth.constant = 0
                
            }
            
            var placeholder: UIImage?
            if #available(iOS 13.0, *) {
                placeholder = UIImage(systemName: "questionmark")
            } else {
                // Fallback on earlier versions
                placeholder = UIImage(named: "first")
            }
            
            if profileURL != "" {
                
                if let url = URL(string: profileURL) {
                    self.profileImage!.kf.setImage(with: url) { result in
                        self.profileSpinner.stopAnimating()
                        self.profileSpinner.isHidden = true
                        self.configurePageControl()
                        
                        for i in 0..<self.pregame!.galleryURLs.count {
                            
                            if let gURL = URL(string: pregame.galleryURLs[i]!) {
                                self.galleryImages[i].kf.setImage(with: gURL) {result in
                                    self.configurePageControl()
                                }
                            }
                        }
                    }
                } else {
                    self.profileImage?.image = placeholder
                    self.profileSpinner.stopAnimating()
                    self.profileSpinner.isHidden = true
                    self.configurePageControl()
                }
            } else {
                self.profileImage?.image = placeholder
                self.profileSpinner.stopAnimating()
                self.profileSpinner.isHidden = true
                self.configurePageControl()
            }
            
        }
        
        
        
    }
    
    
    func getName(name: String) -> String {
        
        if name.last == "s" {
            return "\(name)'"
        }
        return "\(name)'s"
        
    }
    
    
    
    @objc func showAccepted() {
        
    }
    
    @objc func showInvited() {
        
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
    
    
    
    func configurePageControl() {
    
       // The total number of pages that are available is based on how many available colors we have.
       self.pageControl.numberOfPages = (pregame?.galleryURLs.count)! + 1
       
       self.scrollView?.contentSize = CGSize(width: self.view.frame.width * CGFloat((pregame?.galleryURLs.count)! + 1), height: scrollView!.frame.size.height)
       
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
