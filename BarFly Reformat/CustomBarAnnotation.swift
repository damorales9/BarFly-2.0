//
//  CustomBarAnnotation.swift
//  BarFly Reformat
//
//  Created by Derek Morales on 11/1/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import FirebaseStorage

class CustomBarAnnotation: NSObject, MKAnnotation {
    //@objc dynamic var coordinate = CLLocationCoordinate2D()
    
    //var coordinate = CLLocationCoordinate2D()
    
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    //@objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    //@objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 54.9792, longitude: 1.6147)
    
    //@objc dynamic var coordinates: CLLocationCoordinate2D?
    //var barName: String?
    //var title: String? = NSLocalizedString("The Charles", comment: "The Charles")
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    var view: CustomCallout?
    
    //var subtitle: String?
    
    var imageName: String?
    
    var amntPeople: Int?
    
    var descript: String?
    
    var url: String?
    
    var street: String?
    
    var city: String?
    
    var state: String?
    
    var country: String?
    
    var zipcode: String?
    
    var phone: String?
    
    var price: String?
    
    var image: UIImageView?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    
    static func getBar(name: String, setFunction: @escaping (_ bar: inout CustomBarAnnotation?) -> Void) {
        
        var bar: CustomBarAnnotation?
        
        let firestore = Firestore.firestore()
        let userRef = firestore.collection("Bars")
        let docRef = userRef.document("\(name)")
        docRef.getDocument { (document, error) in
                
            if(error == nil) {
    
                let amntPeople = document!.data()!["amountPeople"] as? Int
                let name = document!.data()!["name"] as? String
                let latitude = document!.data()!["latitude"] as? Double
                let longitude = document!.data()!["longitude"] as? Double
                let imageURL = document!.data()!["imageURL"] as? String
                let url = document!.data()!["url"] as? String
                let street = document!.data()!["street"] as? String
                let city = document!.data()!["city"] as? String
                let state = document!.data()!["state"] as? String
                let country = document!.data()!["country"] as? String
                let zipcode = document!.data()!["zipcode"] as? String
                let phone = document!.data()!["phone"] as? String
                let price = document!.data()!["price"] as? String
                
                bar = CustomBarAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
                bar!.title = NSLocalizedString(name!, comment: name!)
                bar!.imageName = imageURL!
                bar!.amntPeople = amntPeople
                bar!.url = url
                bar!.street = street
                bar!.city = city
                bar!.state = state
                bar!.country = country
                bar!.zipcode = zipcode
                bar!.phone = phone
                bar!.price = price
                
                bar!.image = UIImageView()
                
                UIImageView.downloadImage(from: URL(string: imageURL!)!, completion: { (image) in
                    bar!.image = UIImageView(image: image)
                }) {
                    print("no image")
                }
                
                setFunction(&bar)
                
            }
                
        }
    }
}
