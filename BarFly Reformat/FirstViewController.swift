//
//  FirstViewController.swift
//  BarFly Reformat
//
//  Created by Derek Morales on 10/31/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import MapKit
import UIKit
import CoreLocation
import GoogleMapsTileOverlay
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import SafariServices

class FirstViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

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
    
    
    var barDetailsTop: NSLayoutConstraint?
    var barDetailsBottom: NSLayoutConstraint?
    var centerConstraint: NSLayoutConstraint!
    
    var startingConstant: CGFloat  = -85
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barDetails.layer.cornerRadius = 30
        barDetails.layer.borderWidth = 4
        let color = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
        barDetails.layer.borderColor = color.cgColor
        barDetails.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
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
        
        
        let theCharles = CustomBarAnnotation(coordinate: CLLocationCoordinate2D(latitude: 51.531190, longitude: -1.235914))
        theCharles.title = NSLocalizedString("The Charles", comment: "The Charles")
        theCharles.imageName = "logo"
        
        
        FirstViewController.allAnnotations.append(theCharles)
        
        
        print(FirstViewController.allAnnotations)
        
        //barDetailsTop = NSLayoutConstraint(item: barDetails as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -85)
        //view.addConstraint(barDetailsTop!)
        
        self.centerConstraint = barDetails.topAnchor.constraint(equalTo: view.bottomAnchor)
        self.centerConstraint.constant = startingConstant
        self.centerConstraint.isActive = true
        
        exitDetails.addTarget(self, action: #selector(exitBarDetails), for: .touchUpInside)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        barDetails.addGestureRecognizer(gesture)
        barDetails.isUserInteractionEnabled = true
        
        showAllAnnotations(self)
        addCustomOverlay()
        
        //scheduledTimerWithTimeInterval()
        
        
        if let coor = myMapView.userLocation.location?.coordinate{
            myMapView.setCenter(coor, animated: true)
        }
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 3500, longitudinalMeters: 3500)
            myMapView.setRegion(viewRegion, animated: false)
        }

        //self.locationManager = locationManager

        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    
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
        /*
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        */
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? CustomBarAnnotation {
            
            annotationView = setupBarAnnotationView(for: annotation, on: mapView)
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
        let placeholder = UIImage( named: "profile_picture_placeholder.png")
        calloutView.image.sd_setImage(with: httpsReference, placeholderImage: placeholder)
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
        barDetailsImage.sd_setImage(with: httpsReference, placeholderImage: placeholder)
        barDetailsImage.layer.cornerRadius = 35
        amntPeople.text = "\(barAnnotation.amntPeople ?? 2) "
        amntPeople.layer.cornerRadius = 15
        dragButton.layer.cornerRadius = 5
        imGoingBtn.layer.cornerRadius = 10
        imGoingBtn.layer.borderWidth = 4
        imGoingBtn.layer.borderColor = UIColor.black.cgColor
        viewFriendsBtn.layer.cornerRadius = 5
        viewFriendsBtn.layer.borderWidth = 4
        viewFriendsBtn.layer.borderColor = color.cgColor
        
        imGoingBtn.passedData = barAnnotation
        imGoingBtn.passedAnnotation = view
        imGoingBtn.passedCallout = calloutView
        imGoingBtn.addTarget(self, action: #selector(amntPeoplebtnAction(sender: )), for: .touchUpInside)
        
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
            self.centerConstraint.constant = -300
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
                self.centerConstraint.constant = -85
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
            markerAnnotationView.glyphTintColor = UIColor.black
            markerAnnotationView.markerTintColor = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
            

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
                self.startingConstant = self.centerConstraint.constant
            case .changed:
                let translation = gestureRecognizer.translation(in: self.view)
                self.centerConstraint.constant = self.startingConstant + translation.y
            case .ended:
                if(self.centerConstraint.constant < -400) {
                    
                    print("high enough")
                    
                    UIView.animate(withDuration: 0.5) {
                        self.centerConstraint.constant = -800
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
                        self.startingConstant = -300
                        self.centerConstraint.constant = self.startingConstant
                        self.view.layoutIfNeeded()
                        //self.edit.isHidden = true
                    }
                }
            default:
                break
            }


        }
    
    func getUserBarChoice(passedData: CustomBarAnnotation){
        let db = Firestore.firestore()
        
        let ui = db.collection("User Info").document("\(Auth.auth().currentUser!.uid)")
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let uiDocument: DocumentSnapshot
            do {
                try uiDocument = transaction.getDocument(ui)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
           
            guard let userBarChoice = uiDocument.data()?["bar"] as? String else {
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
                if (userBarChoice == "nil"){
                    // SHOULD JUST CALL ONCE AT END transaction.updateData(["bar": "nil"], forDocument: ui)
                        self.imGoingBtn.setTitle("I'm Going!", for: UIControl.State.normal)
                        self.imGoingBtn.backgroundColor = UIColor(red:0.27, green:0.40, blue:1.00, alpha:1.0)
                }
                else if (userBarChoice == passedData.title){
                        self.imGoingBtn.setTitle("You're Going!", for: UIControl.State.normal)
                        self.imGoingBtn.backgroundColor = UIColor.gray
                }
                else{
                        let alert = UIAlertController(title: "You're already going somewhere!", message: "You're already going to \(userBarChoice)! Would you like to remove your old choice?", preferredStyle: .alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "Remove", style: UIAlertAction.Style.default, handler: { action in
                            // SHOULD ONLY DO ONCE transaction.updateData(["bar": "nil"], forDocument: ui)
                            db.collection("User Info").document((Auth.auth().currentUser?.uid)!).updateData([
                                "bar":"nil"]) { err in
                                    if let err = err {
                                        print(err.localizedDescription)
                                    }
                            }
                            let doc = db.collection("Bars").document(userBarChoice)
                            doc.getDocument(completion: { (document, error) in
                                let amnt = document!.get("amountPeople")
                                doc.updateData(["amountPeople":((amnt as! Int)-1)])
                                { err in
                                    if let err = err {
                                        print(err.localizedDescription)
                                    }
                                }
                                
                            })
                       
                            self.imGoingBtn.setTitle("I'm Going!", for: UIControl.State.normal)
                            self.imGoingBtn.backgroundColor = UIColor(red:0.27, green:0.40, blue:1.00, alpha:1.0)
                            
                            self.dismiss(animated: true, completion: nil)
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: "View Bar", style: .cancel, handler: {action in
                          //  self.dismiss(animated: true, completion: nil)
                        }))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                        
                        
                        self.imGoingBtn.setTitle("Not Going", for: UIControl.State.normal)
                        self.imGoingBtn.backgroundColor = UIColor.gray
                }
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("User Bar Transaction failed: \(error)")
            } else {
                print("Successfully got user bar choice!")
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
                transaction.updateData(["bar": sender.passedData!.title!], forDocument: ui)
                transaction.updateData(["amountPeople": newAmount], forDocument: sfReference)
                DispatchQueue.main.async {
                    self.amntPeople.text = "\(newAmount)"
                    barAnnotation.amntPeople = newAmount
                    sender.passedCallout!.amntPeople.text = "\(newAmount)"
                    self.imGoingBtn.setTitle("You're Going!", for: UIControl.State.normal)
                    self.imGoingBtn.backgroundColor = UIColor.gray
                }
            }
            else if (barChoice == sender.passedData!.title){
                subtractOne = oldAmount - 1
                transaction.updateData(["bar": "nil"], forDocument: ui)
                transaction.updateData(["amountPeople": subtractOne], forDocument: sfReference)
                DispatchQueue.main.async {
                    self.amntPeople.text = "\(subtractOne)"
                    sender.passedCallout!.amntPeople.text = "\(subtractOne)"
                    self.imGoingBtn.setTitle("I'm Going!", for: UIControl.State.normal)
                    self.imGoingBtn.backgroundColor = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
                }
            }
            else{
                transaction.updateData(["bar": barChoice], forDocument: ui)
                transaction.updateData(["amountPeople": oldAmount], forDocument: sfReference)
                DispatchQueue.main.async {
                    self.amntPeople.text = "\(oldAmount)"
                    sender.passedCallout!.amntPeople.text = "\(oldAmount)"
                    self.imGoingBtn.setTitle("You're Going!", for: UIControl.State.normal)
                    self.imGoingBtn.backgroundColor = UIColor.gray
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
                       print(name)
                       print(amntPeople as Any)
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
    
    @objc func refreshButtonAction(passedData: CustomBarAnnotation){
        var oldAmount = 0;
        let db = Firestore.firestore()
        //for i in 0..<bars.endIndex {
        oldAmount = passedData.amntPeople!
        let sfReference = db.collection("Bars").document("\(passedData.title ?? "nil")")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let newAmount = sfDocument.data()?["amountPeople"] as? Int else {
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
            if (oldAmount != newAmount){
                passedData.amntPeople = newAmount
                DispatchQueue.main.async {
                    self.amntPeople.text = "\(passedData.amntPeople ?? 2)"
                }
            }
            transaction.updateData(["amountPeople": newAmount], forDocument: sfReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Successfully updated amount people!")
                
            }
        }
        //}
    }
    
    @objc func exitBarDetails(){
        UIView.animate(withDuration: 0.5) {
            self.centerConstraint.constant = -85
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


}

