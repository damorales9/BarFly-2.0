//
//  File.swift
//  BarFly Reformat
//
//  Created by Derek Morales on 11/21/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import MapKit

//  MARK: Battle Rapper View
internal final class CustomMarker: MKMarkerAnnotationView {
    //  MARK: Properties
    internal override var annotation: MKAnnotation? { willSet { newValue.flatMap(configure(with:)) } }
}
//  MARK: Configuration
private extension CustomMarker {
    func configure(with annotation: MKAnnotation) {
        //guard annotation is MKAnnotation else { fatalError("Unexpected annotation type: \(annotation)") }
        markerTintColor = .purple
        glyphImage = #imageLiteral(resourceName: "logo.noborder")
    }
}
