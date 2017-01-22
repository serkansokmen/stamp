//
//  Extensions.swift
//  stamp
//
//  Created by Serkan Sokmen on 22/01/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

extension UIViewController {
    var userRef: FIRDatabaseReference? {
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return nil }
        
        return FIRDatabase.database().reference().child("users").child(userID)
    }
}
