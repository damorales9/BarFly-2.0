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

class FirstViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBAction func segue(_ sender: Any) {
        BarDetailsVC.delegate = self
        self.performSegue(withIdentifier: "showBarList", sender: self.navigationController)
    }
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
    
    @IBOutlet var exitImGoing: UIView!
    @IBOutlet var checkImGoing: UIView!
    
    @IBOutlet var checkBtn: CheckClicked!
    @IBOutlet var cancelBtn: CheckClicked!
    
    var confirmChangeBar = false
    
    var checkBtnWidth: NSLayoutConstraint!
    var goingBtnConstraint: NSLayoutConstraint!
    var cancelBtnWidth: NSLayoutConstraint!
    
    
    static var currentAnnotation: MKAnnotation!
    static var annotations = [MKAnnotation]()
    
    var barDetailsTop: NSLayoutConstraint?
    var barDetailsBottom: NSLayoutConstraint?
    static var centerConstraint: NSLayoutConstraint!
    
    static var startingConstant: CGFloat  = -85
    
    var user: User?
    
    var timer = Timer()
    var barTimer = BarTimer()
    
    
    
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
        
        goingBtnConstraint = NSLayoutConstraint(item: imGoingView!, attribute: .trailing, relatedBy: .equal, toItem: barDetails, attribute: .trailing, multiplier: 1, constant: -50)
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
        
        
        let storage = Storage.storage()
        let httpsReference = storage.reference(forURL: barAnnotation.imageName!)
        var placeholder: UIImage?
        if #available(iOS 13.0, *) {
            placeholder = UIImage(systemName: "questionmark")
        } else {
            // Fallback on earlier versions
            placeholder = UIImage(named: "profile")
        }
        calloutView.image.setFirebaseImage(ref: httpsReference, placeholder: placeholder!, maxMB: 6)
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
        let gesture = BarTapGesture(target: self, action: #selector(barTapped))
        gesture.bar = barAnnotation
        calloutView.amntPeople.text = "\(barAnnotation.amntPeople ?? 2) "
        
        barAnnotation.view = calloutView
        
        calloutView.view.addGestureRecognizer(gesture)
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.30)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
        barDetailsTitle.text = barAnnotation.title!
        barDetailsTitle.layer.cornerRadius = 15
        barDetailsImage.setFirebaseImage(ref: httpsReference, placeholder: placeholder!, maxMB: 6)
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
        
        imGoingBtn.passedData = barAnnotation
        imGoingBtn.passedAnnotation = view
        imGoingBtn.passedCallout = calloutView
        imGoingBtn.addTarget(self, action: #selector(amntPeoplebtnAction(sender: )), for: .touchUpInside)
        
        imGoingView.layer.cornerRadius = 10
        viewFriendsView.layer.cornerRadius = 10
        
        guestView.layer.borderWidth = 3
        guestView.layer.borderColor = color.cgColor
        guestView.layer.cornerRadius = 8
        
        barImageBckg.layer.cornerRadius = 10
        
        if (barAnnotation.url == "nil"){
            linkBtn.link = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
            let mySelectedAttributedTitle = NSAttributedString(string: "\(barAnnotation.title!).com",
                                                               attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
            linkBtn.setAttributedTitle(mySelectedAttributedTitle, for: .selected)

            // .Normal
            let myNormalAttributedTitle = NSAttributedString(string: "\(barAnnotation.title!).com",
                                                             attributes: [NSAttributedString.Key.foregroundColor : UIColor.blue])
            linkBtn.setAttributedTitle(myNormalAttributedTitle, for: .normal)
        }
        else{
            linkBtn.link = barAnnotation.url
        
            let mySelectedAttributedTitle = NSAttributedString(string: "\(barAnnotation.url!)",
                                                               attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
            linkBtn.setAttributedTitle(mySelectedAttributedTitle, for: .selected)

            // .Normal
            let myNormalAttributedTitle = NSAttributedString(string: "\(barAnnotation.url!)",
                                                             attributes: [NSAttributedString.Key.foregroundColor : UIColor.blue])
            linkBtn.setAttributedTitle(myNormalAttributedTitle, for: .normal)
        }
        
        linkBtn.addTarget(self, action: #selector(openLink(sender:)), for: .touchUpInside)
        
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
                if(FirstViewController.centerConstraint.constant < -400) {
                    
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
                    self.cancelBtn.addTarget(self, action: #selector(self.cancelButtonClicked(sender:)), for: .touchUpInside)
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
                        self.goingBtnConstraint.constant = -50
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
                        self.goingBtnConstraint.constant = -50
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
                        self.goingBtnConstraint.constant = -50
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
                            self.goingBtnConstraint.constant = -50
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
                            self.goingBtnConstraint.constant = -50
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
                        self.goingBtnConstraint.constant = -50
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
                
                let bar = CustomBarAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
                bar.title = NSLocalizedString(name!, comment: name!)
                bar.imageName = imageURL!
                bar.amntPeople = amntPeople
                bar.url = url
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


}
