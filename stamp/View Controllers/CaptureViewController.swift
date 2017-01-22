//
//  CaptureViewController.swift
//  stamp
//
//  Created by Serkan Sokmen on 15/01/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import SwiftyCam

class CaptureViewController: SwiftyCamViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done,
                                      target: self,
                                      action: #selector(CaptureViewController.capture as (CaptureViewController) -> () -> ()))
        navigationItem.rightBarButtonItem = doneBtn
    }
    
    func capture() {
        self.takePhoto()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
