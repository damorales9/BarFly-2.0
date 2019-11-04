//
//  CustomBarAnnotation.swift
//  BarFly Reformat
//
//  Created by Derek Morales on 11/1/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import MapKit

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
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
