//
//  FirstViewController.swift
//  BarFly Reformat
//
//  Created by Derek Morales on 10/31/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreLocation
import GoogleMapsTileOverlay
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import SafariServices

class FirstViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    

    @IBAction func segue(_ sender: Any) {
        BarDetailsVC.delegate = self
        self.performSegue(withIdentifier: "showBarList", sender: self.navigationController)
    }
    
    var nonUser: User?
    
    @IBOutlet var barDetails: UIView!
    @IBOutlet var myNavBar: UINavigationBar!
    @IBOutlet var myMapView: MKMapView!
    var locationManager = CLLocationManager()
    var pointAnnotation:CustomPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    @IBOutlet var barDetailsTitle: UILabel!
    @IBOutlet var barDetailsImage: UIImageView!
    @IBOutlet var amntPeople: UILabel!
    @IBOutlet var dragButton: UILabel!
    @IBOutlet var imGoingBtn: AmountPeopleButton!
    @IBOutlet var viewFriendsBtn: UIButton!
    @IBOutlet var exitDetails: UIButton!
    @IBOutlet var linkBtn: URLButton!
    @IBOutlet var guestView: UIView!
    @IBOutlet var imGoingView: UIView!
    @IBOutlet var viewFriendsView: UIView!
    @IBOutlet var locationBtn: UIBarButtonItem!
    @IBOutlet var refreshBtn: UIBarButtonItem!
    @IBOutlet var barImageBckg: UIView!
    @IBOutlet var barTaskBarView: UIView!
    
    @IBOutlet weak var feedView: UIView!
    @IBOutlet var exitImGoing: UIView!
    @IBOutlet var checkImGoing: UIView!
    
    @IBOutlet var checkBtn: CheckClicked!
    @IBOutlet var cancelBtn: CheckClicked!
    
    @IBOutlet var addPostBtn: UIButton!
    
    
    var confirmChangeBar = false
    
    @IBOutlet var streetLbl: UILabel!
    @IBOutlet var cityLbl: UILabel!
    @IBOutlet var stateLbl: UILabel!
    @IBOutlet var zipcodeLbl: UILabel!
    @IBOutlet var countryLbl: UILabel!
    @IBOutlet var phoneLbl: UILabel!
    @IBOutlet var priceLbl: UILabel!
    
    public var currentBarName: String!
    
    @IBOutlet weak var feedContainer: UIView!
    
    var checkBtnWidth: NSLayoutConstraint!
    var goingBtnConstraint: NSLayoutConstraint!
    var cancelBtnWidth: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView?
    
    static var currentAnnotation: MKAnnotation!
    static var annotations = [MKAnnotation]()
    
    var barDetailsTop: NSLayoutConstraint?
    var barDetailsBottom: NSLayoutConstraint?
    static var centerConstraint: NSLayoutConstraint!
    
    static var startingConstant: CGFloat  = -85
    
    var user: User?
    
    var timer = Timer()
    var barTimer = BarTimer()
    
    var friendsGoingList = [User]()
    
    var allPosts = [Post]()
    
    @IBOutlet var newPost: UIView!
    
    @IBOutlet var postBtn: UIButton!
    @IBOutlet var cancelPostBtn: UIButton!
    
    @IBOutlet var postTxtView: UITextView!
    
    
    
    /*
    @IBOutlet var messageText: UILabel!
    @IBOutlet var amntLikesPost: UILabel!
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var dislikeBtn: UIButton!
    */
    
    
    
    
    public static var allAnnotations = [MKAnnotation]()
    
    public static var allBars = [CustomBarAnnotation]()
    
    private var displayedAnnotations: [MKAnnotation]? {
        willSet {
            if let currentAnnotations = displayedAnnotations {
                myMapView.removeAnnotations(currentAnnotations)
            }
        }
        didSet {
            if let newAnnotations = displayedAnnotations {
                myMapView.addAnnotations(newAnnotations)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
         
    }
    
    @IBAction func locationButtonClicked(_ sender: Any) {
        centerLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postTxtView.delegate = self
        
        self.postTxtView.text = "Enter Text"
        self.postTxtView.textColor = UIColor.lightGray
        
        self.newPost.layer.borderWidth = 5
        self.newPost.layer.borderColor = UIColor.black.cgColor
        self.newPost.layer.cornerRadius = 10
        //self.newPost.isHidden = true
        
        UIView.animate(withDuration: 0, animations: {
            self.newPost.alpha = 0
        }) { _ in
            self.newPost.removeFromSuperview()
        }
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Roboto-Light", size: 20)!,
                                                                    NSAttributedString.Key.foregroundColor : UIColor.barflyblue]
        
        myMapView.register(CustomMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        self.barDetails.layer.cornerRadius = 20
        self.barDetails.layer.borderWidth = 4
        let color = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
        self.barDetails.layer.borderColor = color.cgColor
        self.barDetails.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
        
        cancelBtnWidth = NSLayoutConstraint(item: exitImGoing!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        exitImGoing.addConstraint(cancelBtnWidth)
        
        checkBtnWidth = NSLayoutConstraint(item: checkImGoing!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        checkImGoing.addConstraint(checkBtnWidth)
        
        goingBtnConstraint = NSLayoutConstraint(item: imGoingView!, attribute: .trailing, relatedBy: .equal, toItem: barDetails, attribute: .trailing, multiplier: 1, constant: -25)
        barDetails.addConstraint(goingBtnConstraint)
        
        // Do any additional setup after loading the view.
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        registerMapAnnotationViews()
        myMapView.delegate = self
//       myMapView.mapType = .standard
        
        myMapView.isZoomEnabled = true
        myMapView.isScrollEnabled = true
        myMapView.setUserTrackingMode(.none, animated: true)
        
        refreshBtn.action = #selector(refreshButtonAction)
        locationBtn.action = #selector(centerLocation)
        
        print(FirstViewController.allAnnotations)
        
        
        //barDetailsTop = NSLayoutConstraint(item: barDetails as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -85)
        //view.addConstraint(barDetailsTop!)
        
        FirstViewController.centerConstraint = self.barDetails.topAnchor.constraint(equalTo: view.bottomAnchor)
        FirstViewController.centerConstraint.constant = FirstViewController.startingConstant
        FirstViewController.centerConstraint.isActive = true
        
        exitDetails.addTarget(self, action: #selector(exitBarDetails), for: .touchUpInside)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        self.barDetails.addGestureRecognizer(gesture)
        self.barDetails.isUserInteractionEnabled = true
        
        showAllAnnotations(self)
        addCustomOverlay()
        
        self.feedContainer.layer.cornerRadius = 15
        self.tableView?.layer.cornerRadius = 15
        self.tableView?.layer.borderWidth = 5
        self.tableView!.layer.borderColor = UIColor.black.cgColor
        
        //scheduledTimerWithTimeInterval()
        
        if let coor = myMapView.userLocation.location?.coordinate{
            print(coor)
            myMapView.setCenter(coor, animated: true)
        }
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            myMapView.setRegion(viewRegion, animated: false)
        }

        //self.locationManager = locationManager

        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        FirstViewController.annotations = myMapView.annotations
        
        tableView?.delegate=self
        tableView?.dataSource=self
        
    
    }
    
    /*
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
//        myMapView.mapType = MKMapType.standard
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        myMapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        annotation.title = "Derek Morales"
        annotation.subtitle = "current location"
        myMapView.addAnnotation(annotation)
        
        let bar = MKPointAnnotation()
        bar.coordinate = CLLocationCoordinate2D(latitude: 51.531190, longitude: -1.235914)
        
        /*
        let info = CustomPointAnnotation()
        info.coordinate = CLLocationCoordinate2D(latitude: 51.531190, longitude: -1.235914)
        let resizedImage = UIImage(named: "0")
        info.imageName = resizedImage
        
        
        myMapView.addAnnotation(info)
        */
        
        
        //centerMap(locValue)
     
    }
    */
    @IBAction private func showAllAnnotations(_ sender: Any) {
        // User tapped "All" button in the bottom toolbar
        displayedAnnotations = FirstViewController.allAnnotations
    }
    
    
    private func addCustomOverlay() {
        guard let jsonURL = Bundle.main.url(forResource: "overlay", withExtension: "json") else { return }

        do {
            let gmTileOverlay = try GoogleMapsTileOverlay(jsonURL: jsonURL)
            gmTileOverlay.canReplaceMapContent = false
            myMapView.addOverlay(gmTileOverlay)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func registerMapAnnotationViews() {
        myMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomBarAnnotation.self))
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? CustomBarAnnotation {
            
            annotationView = setupBarAnnotationView(for: annotation, on: mapView)
            annotationView?.displayPriority = .required
        }
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let annotation = view.annotation, annotation.isKind(of: CustomBarAnnotation.self) {
            print("Tapped Bar")
            
            if let barDetailsVC = storyboard?.instantiateViewController(withIdentifier: "BarDetailsVC") {
                barDetailsVC.modalPresentationStyle = .popover
                let presentationController = barDetailsVC.popoverPresentationController
                presentationController?.permittedArrowDirections = .any
                
                // Anchor the popover to the button that triggered the popover.
                presentationController?.sourceRect = control.frame
                presentationController?.sourceView = control
                
                present(barDetailsVC, animated: true, completion: nil)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        getUserBarChoice(barName: (view.annotation?.title!)!)
        
        barTaskBarView.layer.cornerRadius = 10
        
        exitImGoing.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.layer.borderWidth = 4
        cancelBtn.layer.borderColor = UIColor.black.cgColor
        
        checkImGoing.layer.cornerRadius = 10
        checkBtn.layer.cornerRadius = 10
        checkBtn.layer.borderWidth = 4
        checkBtn.layer.borderColor = UIColor.black.cgColor
        
        
        confirmChangeBar = false
        
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        // 2
        let barAnnotation = view.annotation as! CustomBarAnnotation
        let views = Bundle.main.loadNibNamed("CustomCallout", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCallout
        
        currentBarName = ""
        currentBarName = barAnnotation.title
        
        friendsGoingList.removeAll()
        for friend in AppDelegate.user!.friends{
            User.getUser(uid: friend!) { (user) in
                if (user?.bar == barAnnotation.title!){
                    self.friendsGoingList.append(user!)
                }
            }
            //self.tableView.reloadData()
        }
        
        let db = Firestore.firestore()
        print(barAnnotation.title)
        let ui = db.collection("Bars").document("\(barAnnotation.title!)")
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let uiDocument: DocumentSnapshot
            do {
                try uiDocument = transaction.getDocument(ui)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
           
            guard let newAmountPeople = uiDocument.data()?["amountPeople"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(uiDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            DispatchQueue.main.async {
                barAnnotation.amntPeople = newAmountPeople
                calloutView.amntPeople.text = "\(barAnnotation.amntPeople!)"
                
            }
            transaction.updateData(["amountPeople": newAmountPeople], forDocument: ui)
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Failed to update amount people: \(error)")
            } else {
                print("Successfully updated amount people")
            }
        }
        
        var placeholder: UIImage?
        if #available(iOS 13.0, *) {
            placeholder = UIImage(systemName: "questionmark")
        } else {
            // Fallback on earlier versions
            placeholder = UIImage(named: "profile")
        }
        //calloutView.image.getImage(ref: barAnnotation.imageName!, placeholder: placeholder!, maxMB: 6)
        calloutView.image.image = barAnnotation.image?.image
        //calloutView.image.image = UIImage(named: barAnnotation.imageName!)
        calloutView.amntPeople.text = "10"
        calloutView.amntPeople.layer.cornerRadius = 10
        calloutView.image.layer.cornerRadius = 20
        let color = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
        calloutView.image.layer.borderColor = color.cgColor
        calloutView.image.layer.borderWidth = 4
        calloutView.title.text = barAnnotation.title!
        calloutView.title.layer.cornerRadius = 10
        calloutView.layer.cornerRadius = 20
        calloutView.view.layer.cornerRadius = 20
//        calloutView.messages = getMSGS()
//        self.tableView?.reloadData()
        let gesture = BarTapGesture(target: self, action: #selector(barTapped))
        gesture.bar = barAnnotation
        calloutView.amntPeople.text = "\(barAnnotation.amntPeople ?? 2) "
        
        barAnnotation.view = calloutView
        
        allPosts.removeAll()
        getPosts(barName: "\(barAnnotation.title!)") { (success) in
            if (success){
                self.tableView?.reloadData()
            }
        }
        
        print(allPosts)
        
        calloutView.view.addGestureRecognizer(gesture)
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.30)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
        barDetailsTitle.text = barAnnotation.title!
//        barDetailsTitle.layer.cornerRadius = 15
        //barDetailsImage.getImage(ref: barAnnotation.imageName!, placeholder: placeholder!, maxMB: 6)
        barDetailsImage.image = barAnnotation.image!.image
        barDetailsImage.layer.cornerRadius = 10
        barDetailsImage.layer.borderWidth = 6
        barDetailsImage.layer.borderColor = UIColor.black.cgColor
        amntPeople.text = "\(barAnnotation.amntPeople!)"
        amntPeople.layer.cornerRadius = 15
        dragButton.layer.cornerRadius = 5
        imGoingBtn.layer.cornerRadius = 10
        imGoingBtn.layer.borderWidth = 4
        imGoingBtn.layer.borderColor = UIColor.black.cgColor
        viewFriendsBtn.layer.cornerRadius = 10
        viewFriendsBtn.layer.borderWidth = 4
        viewFriendsBtn.layer.borderColor = UIColor.black.cgColor
//        streetLbl.text = barAnnotation.street!
//        cityLbl.text = barAnnotation.city!
//        stateLbl.text = barAnnotation.state!
//        countryLbl.text = barAnnotation.country!
//        zipcodeLbl.text = barAnnotation.zipcode!
//        phoneLbl.text = barAnnotation.phone!
//        priceLbl.text = barAnnotation.price!
        
        imGoingBtn.passedData = barAnnotation
        imGoingBtn.passedAnnotation = view
        imGoingBtn.passedCallout = calloutView
        imGoingBtn.addTarget(self, action: #selector(amntPeoplebtnAction(sender: )), for: .touchUpInside)
        
        imGoingView.layer.cornerRadius = 10
//        viewFriendsView.layer.cornerRadius = 10
        
        guestView.layer.borderWidth = 3
        guestView.layer.borderColor = color.cgColor
        guestView.layer.cornerRadius = 8
        
        barImageBckg.layer.cornerRadius = 10
        
        //set the star for favorites
        User.getUser(uid: AppDelegate.user!.uid!) { (user) in
            let str = ((user?.favorites.contains(barAnnotation.title))! ? "star.fill" : "star")
            print("THE STAR STRING IS \(str)")
            if #available(iOS 13.0, *) {
                let star = UIBarButtonItem(image: UIImage(systemName: str), style: .plain, target: self, action: Selector("toggleFavorite"))
                self.navigationItem.setLeftBarButtonItems([self.locationBtn, star], animated: false)
            } else {
                // Fallback on earlier versions
                let star = UIBarButtonItem(image: UIImage(named: str), style: .plain, target: self, action: Selector("toggleFavorite"))
                self.navigationItem.setLeftBarButtonItems([self.locationBtn, star], animated: false)
            }
        
            
        }
        
//        if (barAnnotation.url == "nil"){
//            linkBtn.link = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
//            let mySelectedAttributedTitle = NSAttributedString(string: "\(barAnnotation.title!).com",
//                                                               attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
//            linkBtn.setAttributedTitle(mySelectedAttributedTitle, for: .selected)
//
//            // .Normal
//            let myNormalAttributedTitle = NSAttributedString(string: "\(barAnnotation.title!).com",
//                                                             attributes: [NSAttributedString.Key.foregroundColor : UIColor.blue])
//            linkBtn.setAttributedTitle(myNormalAttributedTitle, for: .normal)
//        }
//        else{
//            linkBtn.link = barAnnotation.url
//
//            let mySelectedAttributedTitle = NSAttributedString(string: "\(barAnnotation.url!)",
//                                                               attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
//            linkBtn.setAttributedTitle(mySelectedAttributedTitle, for: .selected)
//
//            // .Normal
//            let myNormalAttributedTitle = NSAttributedString(string: "\(barAnnotation.url!)",
//                                                             attributes: [NSAttributedString.Key.foregroundColor : UIColor.blue])
//            linkBtn.setAttributedTitle(myNormalAttributedTitle, for: .normal)
//        }
//
//        linkBtn.addTarget(self, action: #selector(openLink(sender:)), for: .touchUpInside)
        
        UIView.animate(withDuration: 0.5) {
            FirstViewController.centerConstraint.constant = -300
            self.view.layoutIfNeeded()
            self.barDetails.layoutIfNeeded()
        
        }
        /*
        UIView.animate(withDuration: 1) {
            self.barDetailsBottom?.constant -= 300
            self.barDetails.layoutIfNeeded()
        }
        */
    }
    
    @objc func toggleFavorite() {
        
        if let user = AppDelegate.user, let title = self.barDetailsTitle.text {
        
            if((user.favorites.contains(title))) {
                AppDelegate.user?.favorites.remove(at: (user.favorites.firstIndex(of: title)!))
                
                if #available(iOS 13.0, *) {
                    let star = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: Selector("toggleFavorite"))
                    self.navigationItem.setLeftBarButtonItems([self.locationBtn, star], animated: false)
                } else {
                    // Fallback on earlier versions
                    let star = UIBarButtonItem(image: UIImage(named: "str"), style: .plain, target: self, action: Selector("toggleFavorite"))
                    self.navigationItem.setLeftBarButtonItems([self.locationBtn, star], animated: false)
                }
                
                AppDelegate.showBanner(title: "Removed \(title) from favorites", image: self.barDetailsImage.image)
            } else {
                AppDelegate.user?.favorites.append(title)
                
                if #available(iOS 13.0, *) {
                    let star = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: Selector("toggleFavorite"))
                    self.navigationItem.setLeftBarButtonItems([self.locationBtn, star], animated: false)
                } else {
                    // Fallback on earlier versions
                    let star = UIBarButtonItem(image: UIImage(named: "star.fill"), style: .plain, target: self, action: Selector("toggleFavorite"))
                    self.navigationItem.setLeftBarButtonItems([self.locationBtn, star], animated: false)
                }
                
                AppDelegate.showBanner(title: "Added \(title) to favorites", image: self.barDetailsImage.image)

            }
            
            User.updateUser(user: AppDelegate.user)

        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        else{
            UIView.animate(withDuration: 0.5) {
                    self.cancelBtnWidth.constant = 0
                    self.goingBtnConstraint.constant = -50
                    self.checkBtnWidth.constant = 0
                    self.barDetails.layoutIfNeeded()
                    self.view.layoutIfNeeded()
            
            }
            
            self.navigationItem.setLeftBarButtonItems([self.locationBtn], animated: false)
            
            
            let barAnnotation = view.annotation as! CustomBarAnnotation
            //let views = Bundle.main.loadNibNamed("CustomCallout", owner: nil, options: nil)
            //let calloutView = views?[0] as! CustomCallout
            
            let db = Firestore.firestore()
            let ui = db.collection("Bars").document("\(barAnnotation.title!)")
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                let uiDocument: DocumentSnapshot
                do {
                    try uiDocument = transaction.getDocument(ui)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
               
                guard let newAmountPeople = uiDocument.data()?["amountPeople"] as? Int else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(uiDocument)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                
                DispatchQueue.main.async {
                    barAnnotation.amntPeople = newAmountPeople
                    //self.amntPeople.text = ("\(newAmountPeople)")
                    
                }
                transaction.updateData(["amountPeople": newAmountPeople], forDocument: ui)
                
                return nil
            }) { (object, error) in
                if let error = error {
                    print("Failed to update amount people: \(error)")
                } else {
                    print("Successfully updated amount people deselect")
                }
            }
            
            
            let bar = view.annotation as! CustomBarAnnotation
            bar.view?.removeFromSuperview()
            UIView.animate(withDuration: 0.5) {
                FirstViewController.self.centerConstraint.constant = -85
                self.view.layoutIfNeeded()
                self.barDetails.layoutIfNeeded()
            }
            /*
            UIView.animate(withDuration: 0.5) {
                self.barDetailsBottom?.constant += 300
                self.barDetails.layoutIfNeeded()
            }
            */
        
        }
        allPosts.removeAll()
    }
    
    @objc func barTapped(sender: BarTapGesture) {
        
    
    }
    
    private func setupBarAnnotationView(for annotation: CustomBarAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let identifier = NSStringFromClass(CustomBarAnnotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout = true
            let image = UIImage(named: "lofi")?.withRenderingMode(.alwaysTemplate)
            markerAnnotationView.glyphImage = image!
            //markerAnnotationView.selectedGlyphImage = image!
            markerAnnotationView.displayPriority = .required
            markerAnnotationView.glyphTintColor = UIColor.black
            markerAnnotationView.markerTintColor = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
            //markerAnnotationView.image = UIImage(named: "logo.noborder")
            

            // Provide an image view to use as the accessory view's detail view.
            //markerAnnotationView.detailCalloutAccessoryView = UIImageView(image: UIImage(named: annotation.imageName!))
            //let rightButton = UIButton(type: .detailDisclosure)
            //rightButton.tintColor = UIColor(red: 180, green: 254, blue: 253, alpha: 0)
            //let leftButton = UIButton(type: .infoDark)
            //markerAnnotationView.leftCalloutAccessoryView?.addSubview(amount)
            //markerAnnotationView.rightCalloutAccessoryView = rightButton
            //markerAnnotationView.leftCalloutAccessoryView = lblTitle
            
            
        }
        
        return view
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {

            switch gestureRecognizer.state {
            case .began:
                FirstViewController.startingConstant = FirstViewController.centerConstraint.constant
            case .changed:
                let translation = gestureRecognizer.translation(in: self.view)
                FirstViewController.centerConstraint.constant = FirstViewController.startingConstant + translation.y
            case .ended:
                if(FirstViewController.centerConstraint.constant < -450) {
                    
                    print("high enough")
                    
                    UIView.animate(withDuration: 0.5) {
                        FirstViewController.centerConstraint.constant = -800
                        self.view.layoutIfNeeded()
                        //self.edit.isHidden = false
                    }
                } else {
                    print("too low")
                    
    //                if(editting) {
    //                    editting = false
    //                    self.name.resignFirstResponder()
    //                    UIView.animate(withDuration: 0.3, animations: {
    //                        self.edit.setTitle("Edit", for: .normal)
    //                        self.changeProfile.isHidden = true
    //                        self.view.layoutIfNeeded()
    //
    //                    })
    //
    //
    //                    if(profileImage.image != nil) {
    //                        self.saveFIRData()
    //                    }term
                    
    //                }
                    
                    UIView.animate(withDuration: 0.3) {
                        FirstViewController.startingConstant = -300
                        FirstViewController.centerConstraint.constant = FirstViewController.startingConstant
                        self.view.layoutIfNeeded()
                        //self.edit.isHidden = true
                    }
                }
            default:
                break
            }


        }
    
    func getUserBarChoice(barName: String) {
        User.getUser(uid: Auth.auth().currentUser!.uid) { (user: User?) in
            self.user = user!
            
            if (user!.bar == "nil"){
                self.imGoingBtn.setTitle("I'm Going!", for: UIControl.State.normal)
                self.imGoingBtn.backgroundColor = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
                self.imGoingView.backgroundColor = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
            }
            else if (user!.bar == barName){
                self.imGoingBtn.setTitle("Remove Choice", for: UIControl.State.normal)
                self.imGoingBtn.backgroundColor = UIColor.red
                self.imGoingView.backgroundColor = UIColor.red
            }
            else{
                self.imGoingBtn.setTitle("Already Going Somewhere!", for: UIControl.State.normal)
                self.imGoingBtn.titleLabel!.font = self.imGoingBtn.titleLabel!.font.withSize(16.0)
                self.imGoingBtn.backgroundColor = UIColor.gray
                self.imGoingView.backgroundColor = UIColor.gray
            }
        }
    }
    
    
    @objc func amntPeoplebtnAction(sender: AmountPeopleButton){
        let barAnnotation = sender.passedAnnotation!.annotation as! CustomBarAnnotation
        
        var newAmount = 0
        var subtractOne = 0
        let db = Firestore.firestore()
        print("\(sender.passedData!.title ?? "nil")")
        let sfReference = db.collection("Bars").document("\(sender.passedData!.title ?? "nil")")
        let ui = db.collection("User Info").document("\(Auth.auth().currentUser!.uid)")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            let uiDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
                try uiDocument = transaction.getDocument(ui)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldAmount = sfDocument.data()?["amountPeople"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            guard let barChoice = uiDocument.data()?["bar"] as? String else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve barchoice from snapshot \(uiDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            newAmount = oldAmount + 1
            
            if (barChoice == "nil"){
                /*
                transaction.updateData(["bar": sender.passedData!.title!, "timestamp": NSDate().timeIntervalSince1970], forDocument: ui)
                transaction.updateData(["amountPeople": newAmount], forDocument: sfReference)
                DispatchQueue.main.async {
                    self.amntPeople.text = "\(newAmount)"
                    barAnnotation.amntPeople = newAmount
                    sender.passedCallout!.amntPeople.text = "\(newAmount)"
                    self.imGoingBtn.setTitle("You're Going Here!", for: UIControl.State.normal)
                    self.imGoingBtn.backgroundColor = UIColor.red
                    self.imGoingView.backgroundColor = UIColor.red
                }
                */
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                            self.imGoingBtn.setTitle("Choose Bar?", for: UIControl.State.normal)
                            self.imGoingBtn.backgroundColor = UIColor.green
                            self.imGoingView.backgroundColor = UIColor.green
                            self.cancelBtnWidth.constant = 50
                            self.goingBtnConstraint.constant = -170
                            self.checkBtnWidth.constant = 50
                            self.barDetails.layoutIfNeeded()
                            self.view.layoutIfNeeded()
                    
                    }
                    self.checkBtn.title = sender.passedData!.title!
                    self.checkBtn.amntBtnPassed = sender
                    self.cancelBtn.title = sender.passedData!.title!
                    self.cancelBtn.amntBtnPassed = sender
                    self.checkBtn.addTarget(self, action: #selector(self.checkClicked(sender:)), for: .touchUpInside)
                    self.cancelBtn.addTarget(self, action: #selector(self.cancelButtonClicked(sender:)), for: .touchUpInside)
                }
            }
            else if (barChoice == sender.passedData!.title){
                subtractOne = oldAmount - 1
                
                self.confirmChangeBar = true
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                            self.imGoingBtn.setTitle("Remove Choice?", for: UIControl.State.normal)
                            self.imGoingBtn.backgroundColor = UIColor.gray
                            self.imGoingView.backgroundColor = UIColor.gray
                            self.cancelBtnWidth.constant = 50
                            self.goingBtnConstraint.constant = -170
                            self.checkBtnWidth.constant = 50
                            self.barDetails.layoutIfNeeded()
                            self.view.layoutIfNeeded()
                    
                    }
                    self.checkBtn.title = sender.passedData!.title!
                    self.checkBtn.amntBtnPassed = sender
                    self.cancelBtn.title = sender.passedData!.title!
                    self.cancelBtn.amntBtnPassed = sender
                    self.checkBtn.addTarget(self, action: #selector(self.checkClicked(sender:)), for: .touchUpInside)
                    self.cancelBtn.addTarget(self, action: #selector(self.cancelButtonClicked(sender:)), for: .touchUpInside)
                }
                
                
                    

            }
            else{
                DispatchQueue.main.async {
                    //self.amntPeople.text = "\(oldAmount)"
                    //sender.passedCallout!.amntPeople.text = "\(oldAmount)"
                    UIView.animate(withDuration: 0.5) {
                        self.imGoingBtn.setTitle("Change to this Bar?", for: UIControl.State.normal)
                        self.imGoingBtn.backgroundColor = UIColor.green
                        self.imGoingView.backgroundColor = UIColor.green
                        self.cancelBtnWidth.constant = 50
                        self.goingBtnConstraint.constant = -170
                        self.checkBtnWidth.constant = 50
                        self.barDetails.layoutIfNeeded()
                        self.view.layoutIfNeeded()
                    }
                    self.checkBtn.title = sender.passedData!.title!
                    self.checkBtn.amntBtnPassed = sender
                    self.cancelBtn.title = sender.passedData!.title!
                    self.cancelBtn.amntBtnPassed = sender
                    self.checkBtn.addTarget(self, action: #selector(self.checkClicked(sender:)), for: .touchUpInside)
                    self.cancelBtn.addTarget(self, action: #selector(self.checkClicked(sender:)), for: .touchUpInside)
                }
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    @objc func checkClicked(sender: CheckClicked){
        let barAnnotation = sender.amntBtnPassed.passedAnnotation!.annotation as! CustomBarAnnotation
        var newAmount = 0
        var subtractOne = 0
        var oldBarSubtract = 0
        let db = Firestore.firestore()
        //print("\(sender.passedData!.title ?? "nil")")
        let sfReference = db.collection("Bars").document("\(sender.title!)")
        let ui = db.collection("User Info").document("\(Auth.auth().currentUser!.uid)")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            let uiDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
                try uiDocument = transaction.getDocument(ui)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldAmount = sfDocument.data()?["amountPeople"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from oldAmount \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            guard let barChoice = uiDocument.data()?["bar"] as? String else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve barchoice from barChoice \(uiDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            newAmount = oldAmount + 1
            if (barChoice == "nil"){
                transaction.updateData(["bar": sender.title!, "timestamp": NSDate().timeIntervalSince1970], forDocument: ui)
                transaction.updateData(["amountPeople": newAmount], forDocument: sfReference)
                DispatchQueue.main.async {
                    self.amntPeople.text = "\(newAmount)"
                    //barAnnotation.amntPeople = newAmount
                    sender.amntBtnPassed.passedCallout!.amntPeople.text = "\(newAmount)"
                    UIView.animate(withDuration: 0.5) {
                        self.imGoingBtn.setTitle("Remove Choice", for: UIControl.State.normal)
                        self.imGoingBtn.backgroundColor = UIColor.red
                        self.imGoingView.backgroundColor = UIColor.red
                        self.cancelBtnWidth.constant = 0
                        self.goingBtnConstraint.constant = -25
                        self.checkBtnWidth.constant = 0
                        self.barDetails.layoutIfNeeded()
                        self.view.layoutIfNeeded()
                    }
                }
                
            }
            else if (barChoice == sender.title!){
                subtractOne = oldAmount - 1
                transaction.updateData(["bar": "nil"], forDocument: ui)
                transaction.updateData(["amountPeople": subtractOne], forDocument: sfReference)
                DispatchQueue.main.async {
                    self.amntPeople.text = "\(subtractOne)"
                    sender.amntBtnPassed.passedCallout!.amntPeople.text = "\(subtractOne)"
                    UIView.animate(withDuration: 0.5) {
                        self.imGoingBtn.setTitle("I'm Going!", for: UIControl.State.normal)
                        self.imGoingBtn.backgroundColor = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
                        self.imGoingView.backgroundColor = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
                        self.cancelBtnWidth.constant = 0
                        self.goingBtnConstraint.constant = -25
                        self.checkBtnWidth.constant = 0
                        self.barDetails.layoutIfNeeded()
                        self.view.layoutIfNeeded()
                    }
                }
            }
            else {
                let newReference = db.collection("Bars").document(barChoice)
                let newDocument: DocumentSnapshot
                do {
                    try newDocument = transaction.getDocument(newReference)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                guard let oldBarAmount = newDocument.data()?["amountPeople"] as? Int else{
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve population from oldBarAmount \(sfDocument)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                oldBarSubtract = oldBarAmount - 1
                transaction.updateData(["amountPeople": oldBarSubtract], forDocument: newReference)
                transaction.updateData(["bar": sender.title!, "timestamp": NSDate().timeIntervalSince1970], forDocument: ui)
                transaction.updateData(["amountPeople": newAmount], forDocument: sfReference)
                DispatchQueue.main.async {
                    self.amntPeople.text = "\(newAmount)"
                    self.refreshAnnotation(title: barChoice)
            
                    //barAnnotation.amntPeople = newAmount
                    sender.amntBtnPassed.passedCallout!.amntPeople.text = "\(newAmount)"
                    UIView.animate(withDuration: 0.5) {
                        self.imGoingBtn.setTitle("Remove Choice", for: UIControl.State.normal)
                        self.imGoingBtn.backgroundColor = UIColor.red
                        self.imGoingView.backgroundColor = UIColor.red
                        self.cancelBtnWidth.constant = 0
                        self.goingBtnConstraint.constant = -25
                        self.checkBtnWidth.constant = 0
                        self.barDetails.layoutIfNeeded()
                        self.view.layoutIfNeeded()
                    }
                }
                
                
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    @objc func cancelButtonClicked(sender: CheckClicked){
        let db = Firestore.firestore()
        let sfReference = db.collection("Bars").document("\(sender.title!)")
        let ui = db.collection("User Info").document("\(Auth.auth().currentUser!.uid)")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            let uiDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
                try uiDocument = transaction.getDocument(ui)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldAmount = sfDocument.data()?["amountPeople"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            guard let barChoice = uiDocument.data()?["bar"] as? String else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve barchoice from snapshot \(uiDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            if (barChoice == "nil"){
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                            self.imGoingBtn.setTitle("I'm Going!", for: UIControl.State.normal)
                            self.imGoingBtn.backgroundColor = UIColor.barflyblue
                        self.imGoingView.backgroundColor = UIColor.barflyblue
                            self.cancelBtnWidth.constant = 0
                            self.goingBtnConstraint.constant = -25
                            self.checkBtnWidth.constant = 0
                            self.barDetails.layoutIfNeeded()
                            self.view.layoutIfNeeded()
                    
                    }
                }
            }
            else if (barChoice == sender.title!){
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                            self.imGoingBtn.setTitle("Remove Choice", for: UIControl.State.normal)
                            self.imGoingBtn.backgroundColor = UIColor.red
                            self.imGoingView.backgroundColor = UIColor.red
                            self.cancelBtnWidth.constant = 0
                            self.goingBtnConstraint.constant = -25
                            self.checkBtnWidth.constant = 0
                            self.barDetails.layoutIfNeeded()
                            self.view.layoutIfNeeded()
                    
                    }
                }
            }
            else{
                DispatchQueue.main.async {
                    //self.amntPeople.text = "\(oldAmount)"
                    //sender.passedCallout!.amntPeople.text = "\(oldAmount)"
                    UIView.animate(withDuration: 0.5) {
                        self.imGoingBtn.setTitle("Already Going Somewhere!", for: UIControl.State.normal)
                        self.imGoingBtn.backgroundColor = UIColor.gray
                        self.imGoingView.backgroundColor = UIColor.gray
                        self.cancelBtnWidth.constant = 0
                        self.goingBtnConstraint.constant = -25
                        self.checkBtnWidth.constant = 0
                        self.barDetails.layoutIfNeeded()
                        self.view.layoutIfNeeded()
                    }
                }
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 15 seconds
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
//        var oldAmount = 0;
//        let db = Firestore.firestore()
//        //for i in 0..<bars.endIndex {
//        oldAmount = sender.passedData!.amntPeople!
//        let sfReference = db.collection("Bars").document("\(sender.passedData!.title ?? "nil")")
//
//        db.runTransaction({ (transaction, errorPointer) -> Any? in
//            let sfDocument: DocumentSnapshot
//            do {
//                try sfDocument = transaction.getDocument(sfReference)
//            } catch let fetchError as NSError {
//                errorPointer?.pointee = fetchError
//                return nil
//            }
//
//            guard let newAmount = sfDocument.data()?["amountPeople"] as? Int else {
//                let error = NSError(
//                    domain: "AppErrorDomain",
//                    code: -1,
//                    userInfo: [
//                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(sfDocument)"
//                    ]
//                )
//                errorPointer?.pointee = error
//                return nil
//            }
//            if (oldAmount != newAmount){
//                sender.passedData!.amntPeople = newAmount
//                DispatchQueue.main.async {
//                    self.amntPeople.text = "\(sender.passedData!.amntPeople ?? 2)"
//                }
//            }
//            transaction.updateData(["amountPeople": newAmount], forDocument: sfReference)
//            return nil
//        }) { (object, error) in
//            if let error = error {
//                print("Transaction failed: \(error)")
//            } else {
//                print("Successfully updated amount people")
//
//            }
//        }
//        //}
        //FirstViewController.allAnnotations.removeAll()
        myMapView.removeAnnotations(FirstViewController.allAnnotations)
        let basicQuery = Firestore.firestore().collection("Bars").limit(to: 50)
               basicQuery.getDocuments { (snapshot, error) in
                   if let error = error {
                       print("Oh no! Got an error! \(error.localizedDescription)")
                       return
                   }
                   guard let snapshot = snapshot else { return }
                   let allBars = snapshot.documents
                   for barDocument in allBars {
                       let amntPeople = barDocument.data()["amountPeople"] as? Int
                       let name = barDocument.data()["name"] as? String
                       let latitude = barDocument.data()["latitude"] as? Double
                       let longitude = barDocument.data()["longitude"] as? Double
                       let imageURL = barDocument.data()["imageURL"] as? String
                       
                       let bar = CustomBarAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
                       bar.title = NSLocalizedString(name!, comment: name!)
                       bar.imageName = imageURL!
                       bar.amntPeople = amntPeople
                       //print(bar.imageName as Any)
                       //print(bar)
                       FirstViewController.allBars.append(bar)
                       //print(allBars)
                       print(bar)
                       FirstViewController.allAnnotations.append(bar)
                       self.myMapView.addAnnotation(bar)
                   }
               }
        //print(FirstViewController.allAnnotations)
        myMapView.addAnnotations(FirstViewController.allAnnotations)
        //showAllAnnotations(self)
        print("updated")
        
    }
    @IBAction func refresh(_ sender: Any) {
        refreshButtonAction()
    }
    
    @objc func refreshButtonAction(){
        pullBars { (success) in
            if (success){
                //FirstViewController.annotations = myMapView.annotations
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //FirstViewController.annotations = self.myMapView.annotations
            print(FirstViewController.annotations)
            print("updated")
        }
        //print(FirstViewController.annotations)
        //print("updated")
    }
    
    func refreshAnnotation(title: String?){
        let barAnnotation = FirstViewController.getAnnotation(title: title!) as! CustomBarAnnotation
        
        let db = Firestore.firestore()
        let ui = db.collection("Bars").document("\(barAnnotation.title!)")
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let uiDocument: DocumentSnapshot
            do {
                try uiDocument = transaction.getDocument(ui)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
           
            guard let newAmountPeople = uiDocument.data()?["amountPeople"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(uiDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            DispatchQueue.main.async {
                barAnnotation.amntPeople = newAmountPeople
                //self.amntPeople.text = ("\(newAmountPeople)")
                
            }
            transaction.updateData(["amountPeople": newAmountPeople], forDocument: ui)
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Failed to update amount people: \(error)")
            } else {
                print("Successfully refreshed annotation")
            }
        }
        
    }
    
    func pullBars(completion: (_ success: Bool) -> Void){
        myMapView.removeAnnotations(FirstViewController.allAnnotations)
        FirstViewController.annotations.removeAll()
        let basicQuery = Firestore.firestore().collection("Bars").limit(to: 50)
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allBars = snapshot.documents
            for barDocument in allBars {
                let amntPeople = barDocument.data()["amountPeople"] as? Int
                let name = barDocument.data()["name"] as? String
                let latitude = barDocument.data()["latitude"] as? Double
                let longitude = barDocument.data()["longitude"] as? Double
                let imageURL = barDocument.data()["imageURL"] as? String
                let url = barDocument.data()["url"] as? String
                let street = barDocument.data()["street"] as? String
                let city = barDocument.data()["city"] as? String
                let state = barDocument.data()["state"] as? String
                let country = barDocument.data()["country"] as? String
                let zipcode = barDocument.data()["zipcode"] as? String
                let phone = barDocument.data()["phone"] as? String
                let price = barDocument.data()["price"] as? String
                
                let bar = CustomBarAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
                bar.title = NSLocalizedString(name!, comment: name!)
                bar.imageName = imageURL!
                bar.amntPeople = amntPeople
                bar.url = url
                bar.street = street
                bar.city = city
                bar.state = state
                bar.country = country
                bar.zipcode = zipcode
                bar.phone = phone
                bar.price = price
                
                bar.image = UIImageView()
                
                bar.image!.kf.setImage(with: URL(string: imageURL!))

                //print(bar.imageName as Any)
                //print(bar)
                FirstViewController.allBars.append(bar)
                //print(allBars)
                FirstViewController.allAnnotations.append(bar)
                FirstViewController.annotations.append(bar)
                print(FirstViewController.annotations)
                self.myMapView.addAnnotation(bar)
            }
        }
        completion(true)
    }
    
    @objc func exitBarDetails(){
        UIView.animate(withDuration: 0.5) {
            FirstViewController.centerConstraint.constant = -85
            self.view.layoutIfNeeded()
            self.barDetails.layoutIfNeeded()
        }
    }
    
    @objc func openLink(sender: URLButton){
        showLink(for: sender.link!)
        
    }
    
    func showLink(for url: String){
        guard let url = URL(string: url) else {
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    @objc func centerLocation(){
        if let coor = myMapView.userLocation.location?.coordinate{
            myMapView.setCenter(coor, animated: true)
        }
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            myMapView.setRegion(viewRegion, animated: false)
        }
    }
    
    static func getAnnotation(title: String) -> MKAnnotation{
        for annotation in FirstViewController.annotations {
            if (annotation.title == title){
                FirstViewController.currentAnnotation = annotation
                return annotation
            }
        }
        return FirstViewController.currentAnnotation
    }
    
    
    @IBAction func viewFriendsBtnClicked(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let listVC = storyBoard.instantiateViewController(withIdentifier: "friendsGoingList") as! FriendsGoingListVC
        listVC.isFollowers = false
        listVC.friendsGoingList = self.friendsGoingList
        listVC.nonUser = AppDelegate.user
        listVC.bar = barDetailsTitle.text
        self.navigationController?.pushViewController(listVC, animated:true)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(allPosts.count == 0){
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Posts"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont(name: "Roboto-Thin", size: 20)
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
            return 0
        }
        else {
            if (allPosts.count < 20){
                tableView.backgroundView = nil
                return allPosts.count
            }
            else{
                return 20
            }
        }
    }
    
    var liked: Bool!
    var disliked: Bool!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        
        cell.messageText.text = allPosts[indexPath.row].message
        if let likes = allPosts[indexPath.row].likes
        {
            cell.amntLikes.text = "\(likes)"
        }
        
        liked = false
        disliked = false
        
        cell.likeBtn.setImage(UIImage(named: "up30"), for: .normal)
        cell.dislikeBtn.setImage(UIImage(named: "down30"), for: .normal)
        
        for s in allPosts[indexPath.row].likedBy {
            if (s == AppDelegate.user?.uid){
                cell.likeBtn.setImage(UIImage(named: "grayup30"), for: .normal)
                cell.dislikeBtn.setImage(UIImage(named: "down30"), for: .normal)
            }
        }
        
        for p in allPosts[indexPath.row].dislikedBy {
            if (p == AppDelegate.user?.uid) {
                cell.likeBtn.setImage(UIImage(named: "up30"), for: .normal)
                cell.dislikeBtn.setImage(UIImage(named: "graydown30"), for: .normal)
            }
        }
        
        cell.likeBtn.amountPeople = allPosts[indexPath.row].likes
        cell.dislikeBtn.amountPeople = allPosts[indexPath.row].likes
        
        cell.likeBtn.title = currentBarName
        cell.dislikeBtn.title = currentBarName
        
        cell.likeBtn.uid = allPosts[indexPath.row].uid
        cell.dislikeBtn.uid = allPosts[indexPath.row].uid
        
        cell.likeBtn.cell = cell
        cell.dislikeBtn.cell = cell
        
        cell.likeBtn.addTarget(self, action: #selector(self.likeBtnClicked(_:)), for: .touchUpInside)
        cell.dislikeBtn.addTarget(self, action: #selector(self.dislikeBtnClicked(_:)), for: .touchUpInside)
        
        globalLiked.removeAll()
        globalDisliked.removeAll()
        
//        getPost(post: allPosts[indexPath.row]) { (success) in
//            if (success){
//                for s in self.globalLiked {
//                    if (s == AppDelegate.user?.uid){
//                        self.liked = true
//                        self.disliked = false
//                    }
//                }
//
//                for p in self.globalDisliked {
//                    if (p == AppDelegate.user?.uid){
//                        self.disliked = true
//                        self.liked = false
//                    }
//                }
//
//                print("liked ", self.liked)
//                print("disliked ", self.disliked)
//                print("-------------------------")
//
//                if (self.liked == true){
//                    DispatchQueue.main.async {
//                        cell.likeBtn.setImage(UIImage(named: "grayup30"), for: .normal)
//                        cell.dislikeBtn.setImage(UIImage(named: "down30"), for: .normal)
//                    }
//                }
//                else if (self.disliked == true){
//                    DispatchQueue.main.async {
//                        cell.dislikeBtn.setImage(UIImage(named: "graydown30"), for: .normal)
//                        cell.likeBtn.setImage(UIImage(named: "up30"), for: .normal)
//                    }
//                }
//                else {
//                    DispatchQueue.main.async {
//                        cell.likeBtn.setImage(UIImage(named: "up30"), for: .normal)
//                        cell.dislikeBtn.setImage(UIImage(named: "down30"), for: .normal)
//                    }
//                }
//            }
//        }
        
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.black.cgColor
        
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    public var globalLiked = [String]()
    public var globalDisliked = [String]()
    
    func getPost(post: Post, completion: @escaping (_ success: Bool) -> Void){
        globalDisliked.removeAll()
        globalLiked.removeAll()
        
        let db = Firestore.firestore()
        let docRef = db.collection("Bar Feeds").document("\(currentBarName!)").collection("feed").document("\(post.uid!)")
        
        docRef.getDocument(source: .cache) { (document, error) in
            if(error == nil) {
                let likedArray = ((document!.get("likedBy")) as! [String])
                let dislikedArray = ((document!.get("dislikedBy")) as! [String])
                
                self.globalLiked = likedArray
                self.globalDisliked = dislikedArray
            }
            completion(true)
        }
    }
    
    func getPosts(barName: String, completion: @escaping (_ success: Bool) -> Void){
        print(barName)
        let basicQuery = Firestore.firestore().collection("Bar Feeds").document("\(barName)").collection("feed").limit(to: 50)
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allPost = snapshot.documents
            for postDocument in allPost {
                
                let post = Post()
                let message = postDocument.data()["message"] as? String
                let likes = postDocument.data()["likes"] as? Int
                let uid = postDocument.documentID
                let likedBy = postDocument.data()["likedBy"] as? [String]
                let dislikedBy = postDocument.data()["dislikedBy"] as? [String]
                
                post.message = message
                post.likes = likes
                post.uid = uid
                post.likedBy = likedBy!
                post.dislikedBy = dislikedBy!
                
                //self.allPosts.append(post)
                self.allPosts.insert(post, at: 0)
                
                //completion(true)
            }
            completion(true)
        }
        
    }
    
    @IBAction func likeBtnClicked(_ sender: CheckClicked!) {
        var newAmount = 0
        let db = Firestore.firestore()
        let sfReference = db.collection("Bar Feeds").document("\(sender.title!)").collection("feed").document("\(sender.uid!)")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let likedBy = sfDocument.data()?["likedBy"] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from likedBy \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            guard let dislikedBy = sfDocument.data()?["dislikedBy"] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from dislikedBy \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            var likedArray = [String]()
            likedArray = likedBy
            
            var dislikedArray = [String]()
            dislikedArray = dislikedBy
            
            for s in likedBy {
                if (s == AppDelegate.user?.uid){
                    if likedArray.contains(AppDelegate.user!.uid!){
                        let index = likedArray.firstIndex(of: AppDelegate.user!.uid!)
                        likedArray.remove(at: index!)
                    }
                    transaction.updateData(["dislikedBy" : dislikedArray], forDocument: sfReference)
                    transaction.updateData(["likedBy" : likedArray], forDocument: sfReference)
                    transaction.updateData(["likes": likedArray.count - dislikedArray.count], forDocument: sfReference)
                    
                    for p in self.allPosts{
                        if p.uid == sender.uid {
                            p.likes = likedArray.count - dislikedArray.count
                            if p.likedBy.contains(AppDelegate.user!.uid!){
                                let index = p.likedBy.firstIndex(of: AppDelegate.user!.uid!)
                                p.likedBy.remove(at: index!)
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                    return nil
                }
            }
            
            for i in 0 ..< dislikedArray.count {
                if (dislikedArray[i] == AppDelegate.user?.uid) {
                    dislikedArray.remove(at: i)
                }
            }
            
            likedArray.append(AppDelegate.user!.uid!)
            transaction.updateData(["dislikedBy" : dislikedArray], forDocument: sfReference)
            transaction.updateData(["likedBy" : likedArray], forDocument: sfReference)
            transaction.updateData(["likes": likedArray.count - dislikedArray.count], forDocument: sfReference)
            
            for p in self.allPosts{
                if p.uid == sender.uid {
                    p.likes = likedArray.count - dislikedArray.count
                    p.likedBy.append(AppDelegate.user!.uid!)
                    if p.dislikedBy.contains(AppDelegate.user!.uid!){
                        let index = p.dislikedBy.firstIndex(of: AppDelegate.user!.uid!)
                        p.dislikedBy.remove(at: index!)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                sender.cell.likeBtn.setImage(UIImage(named: "grayup30"), for: .normal)
                sender.cell.dislikeBtn.setImage(UIImage(named: "down30"), for: .normal)
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
        
    }
    
    @IBAction func dislikeBtnClicked(_ sender: CheckClicked!) {
        var newAmount = 0
        let db = Firestore.firestore()
        let sfReference = db.collection("Bar Feeds").document("\(sender.title!)").collection("feed").document("\(sender.uid!)")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let likedBy = sfDocument.data()?["likedBy"] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from likedBy \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            guard let dislikedBy = sfDocument.data()?["dislikedBy"] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from dislikedBy \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            var dislikedArray = [String]()
            dislikedArray = dislikedBy
            
            var likedArray = [String]()
            likedArray = likedBy
            
            for s in dislikedBy {
                if (s == AppDelegate.user?.uid){
                    if dislikedArray.contains(AppDelegate.user!.uid!){
                        let index = dislikedArray.firstIndex(of: AppDelegate.user!.uid!)
                        dislikedArray.remove(at: index!)
                    }
                    transaction.updateData(["dislikedBy" : dislikedArray], forDocument: sfReference)
                    transaction.updateData(["likedBy" : likedArray], forDocument: sfReference)
                    transaction.updateData(["likes": likedArray.count - dislikedArray.count], forDocument: sfReference)
                    
                    for p in self.allPosts{
                        if p.uid == sender.uid {
                            p.likes = likedArray.count - dislikedArray.count
                            if p.dislikedBy.contains(AppDelegate.user!.uid!){
                                let index = p.dislikedBy.firstIndex(of: AppDelegate.user!.uid!)
                                p.dislikedBy.remove(at: index!)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                }
                return nil
            }
            
            for i in 0 ..< likedArray.count {
                if (likedArray[i] == AppDelegate.user?.uid) {
                    likedArray.remove(at: i)
                }
            }
            
            dislikedArray.append(AppDelegate.user!.uid!)
            
            transaction.updateData(["dislikedBy" : dislikedArray], forDocument: sfReference)
            transaction.updateData(["likedBy" : likedArray], forDocument: sfReference)
            transaction.updateData(["likes": likedArray.count - dislikedArray.count], forDocument: sfReference)
            
            for p in self.allPosts{
                if p.uid == sender.uid {
                    p.likes = likedArray.count - dislikedArray.count
                    p.dislikedBy.append(AppDelegate.user!.uid!)
                    if p.likedBy.contains(AppDelegate.user!.uid!){
                        let index = p.likedBy.firstIndex(of: AppDelegate.user!.uid!)
                        p.likedBy.remove(at: index!)
                    }
                }
            }
            
            DispatchQueue.main.async {
                sender.cell.dislikeBtn.setImage(UIImage(named: "graydown30"), for: .normal)
                sender.cell.likeBtn.setImage(UIImage(named: "up30"), for: .normal)
                self.tableView?.reloadData()
            }
            
//            DispatchQueue.main.async {
//                self.tableView?.reloadData()
//                sender.cell.dislikeBtn.setImage(UIImage(named: "graydown30"), for: .normal)
//                sender.cell.likeBtn.setImage(UIImage(named: "up30"), for: .normal)
//            }
                
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
        
    }
    
    var blurEffect: UIBlurEffect!
    var blurEffectView: UIVisualEffectView!
    
    @IBAction func addPostBtnClicked(_ sender: Any) {
        blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.view.addSubview(self.newPost)
            self.newPost.alpha = 1;
        })
    }
    
    func textViewDidBeginEditing(_ postTxtView: UITextView) {
        if postTxtView.textColor == UIColor.lightGray {
            postTxtView.text = nil
            postTxtView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ postTxtView: UITextView) {
        if postTxtView.text.isEmpty {
            postTxtView.text = "Enter Text"
            postTxtView.textColor = UIColor.lightGray
        }
    }

    @IBAction func postBtnClicked(_ sender: Any) {
        var message: String!
        if postTxtView.text.isEmpty || postTxtView.text == "Enter Text" {
            let alert = UIAlertController(title: "Error", message: "Post can not be empty.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            message = postTxtView.text
        }
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("Bar Feeds").document("\(currentBarName!)").collection("feed").addDocument(data: [
            "message" : "\(message!)",
            "likes" : 0,
            "likedBy" : [String](),
            "dislikedBy" : [String]()
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
        let post = Post()
        post.message = message!
        post.likes = 0
        post.uid = ref!.documentID
        
        self.allPosts.insert(post, at: 0)
        
        self.tableView?.reloadData()
        
        postTxtView.text = "Enter Text"
            postTxtView.textColor = UIColor.lightGray
            
        UIView.animate(withDuration: 0.2, animations: {
            self.newPost.alpha = 0
        }) { _ in
            self.newPost.removeFromSuperview()
        }
        self.blurEffectView.removeFromSuperview()
        
        
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        postTxtView.text = "Enter Text"
        postTxtView.textColor = UIColor.lightGray
        
        UIView.animate(withDuration: 0.2, animations: {
            self.newPost.alpha = 0
        }) { _ in
            self.newPost.removeFromSuperview()
        }
        self.blurEffectView.removeFromSuperview()
    }
}
