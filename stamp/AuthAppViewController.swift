//
//  AuthAppViewController.swift
//  stamp
//
//  Created by Serkan Sokmen on 02/01/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthAppViewController: UIViewController {

    @IBOutlet weak var vCenterConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vCenterConstraint.constant = self.view.frame.height
        
        let anim = UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.35) {
            self.vCenterConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        anim.startAnimation()
    }
    
    
    @IBAction func loginTapped(_ sender: UIButton) {
        FIRAuth.auth()?.signInAnonymously { user, error in
            if error == nil && user != nil {
                self.performSegue(withIdentifier: "ToPhotoListSegue", sender: self)
//                self.performSegue(withIdentifier: "ToCapture", sender: self)
            }
        }
    }
    
}
