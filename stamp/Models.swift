//
//  Models.swift
//  stamp
//
//  Created by Serkan Sokmen on 22/01/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import UIKit
import Gloss
import MapKit
import HDAugmentedReality

class Photo: Glossy {
    
    let uuid: String
    let imageUrl: String?
    let latitude: Double
    let longitude: Double
    
    required init?(json: JSON) {
        
        guard let latitude: Double = "latitude" <~~ json else { return nil }
        guard let longitude: Double = "longitude" <~~ json else { return nil }
        
        self.uuid = "uuid" <~~ json ?? UUID().uuidString
        self.imageUrl = "image_url" <~~ json
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "uuid" ~~> self.uuid,
            "image_url" ~~> self.imageUrl,
            "latitude" ~~> self.latitude,
            "longitude" ~~> self.longitude
        ])
    }
}

extension Photo {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}


class PhotoAnnotation: ARAnnotation {
    
    let photo: Photo
    
    init(_ photo: Photo) {
        self.photo = photo
        
        super.init()
        
        self.location = CLLocation(latitude: photo.coordinate.latitude,
                                   longitude: photo.coordinate.longitude)
    }
    
    override var description: String {
        return photo.uuid
    }
}
