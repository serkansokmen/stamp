//
//  Models.swift
//  stamp
//
//  Created by Serkan Sokmen on 22/01/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import Gloss


struct Photo: Glossy {
    
    let uuid: String?
    let imageUrl: String?
    let latitude: Double?
    let longitude: Double?
    
    init?(json: JSON) {
        self.uuid = "uuid" <~~ json
        self.imageUrl = "image_url" <~~ json
        self.latitude = "latitude" <~~ json
        self.longitude = "longitude" <~~ json
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
