//
//  ViewController.swift
//  stamp
//
//  Created by Serkan Sokmen on 02/01/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftyCam
import Hero
import CoreLocation


class PhotoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addPhotoTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ToCapture", sender: self)
    }
    
    var photos: [Photo] = []
    var refHandle: FIRDatabaseHandle!
    var ref: FIRDatabaseReference!
    var locationManager: CLLocationManager!
    var currentLatitude: CLLocationDistance?
    var currentLongitude: CLLocationDistance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1.0
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        title = "Photos"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        ref = userRef?.child("photos")
        refHandle = ref.observe(.value, with: { snapshot in
            
            self.photos.removeAll()
            for (_, photoSnapshot) in snapshot.children.enumerated() {
                guard let value = (photoSnapshot as? FIRDataSnapshot)?.value as? [String:Any] else { return }
                guard let photo = Photo(json: value) else { return }
                self.photos.append(photo)
            }
            self.tableView.reloadData()
        })
        
        isHeroEnabled = true
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        ref.removeObserver(withHandle: refHandle)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToCapture" {
            let vc = segue.destination as! CaptureViewController
            vc.cameraDelegate = self
        }
    }
}

//MARK: Location Manager
extension PhotoListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLatitude = locations.first?.coordinate.latitude
        currentLongitude = locations.first?.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

//MARK: Table View
extension PhotoListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoListCell", for: indexPath) as! PhotoListCell
        cell.labelField.text = self.photos[indexPath.row].imageUrl
        
//        let httpsReference = storage.reference(forURL: imageURL)
//        cell.thumbView.image
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let photo = photos[indexPath.row]
            ref.child(photo.uuid!).removeValue()
            let storageRef = FIRStorage.storage().reference()
            let photoRef = storageRef.child("images/\(FIRAuth.auth()!.currentUser!.uid)/\(photo.uuid).jpg")
            photoRef.delete(completion: { error in
                if error != nil {
                    print(error!.localizedDescription)
                }
            })
            
        default:
            break
        }
    }
}

//MARK: SwiftyCam
extension PhotoListViewController: SwiftyCamViewControllerDelegate {
    func SwiftyCamDidTakePhoto(_ photo: UIImage) {
        _ = navigationController?.popViewController(animated: true)
        self.upload(photo)
    }
}


// Upload
extension PhotoListViewController {
    
    func upload(_ image: UIImage) {
        var data: Data! = Data()
        data = UIImageJPEGRepresentation(image, 0.95)!
        
        let storageRef = FIRStorage.storage().reference()
        let uuid = UUID().uuidString
        let photoRef = storageRef.child("images/\(FIRAuth.auth()!.currentUser!.uid)/\(uuid).jpg")
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = photoRef.put(data, metadata: metadata) { data, error in
            
            if error == nil {
                photoRef.downloadURL { url, error in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        let photo = Photo(json: [
                            "uuid": uuid,
                            "image_url": url!.absoluteString,
                            "latitude": self.locationManager.location?.coordinate.latitude ?? 0.0,
                            "longitude": self.locationManager.location?.coordinate.longitude ?? 0.0,
                        ])
                        self.userRef?.child("photos").child(uuid).setValue(photo?.toJSON())
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            self.title = "%\(percentComplete)"
        }
        uploadTask.observe(.success, handler: { storageSnapshot in
            self.title = "Photos"
        })
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as? NSError {
                switch (FIRStorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    break
                case .cancelled:
                    // User canceled the upload
                    break
                    
                    /* ... */
                    
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    break
                }
            }
        }
    }
}
