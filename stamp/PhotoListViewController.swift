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


extension UIViewController {
    var userRef: FIRDatabaseReference? {
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return nil }
        
        return FIRDatabase.database().reference().child("users").child(userID)
    }
}

struct Photo {
    let thumb: String
}

class PhotoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addPhotoTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    var photos: [Photo] = []
    let imagePicker = UIImagePickerController()
    var refHandle: FIRDatabaseHandle!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photos"
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        ref = userRef?.child("photos")
        refHandle = ref.observe(.value, with: { snapshot in
            
            self.photos.removeAll()
            for (_, photoSnapshot) in snapshot.children.enumerated() {
                guard let value = (photoSnapshot as? FIRDataSnapshot)?.value as? String else { return }
                self.photos.append(Photo(thumb: value))
            }
            self.tableView.reloadData()
        })
    }
    
    deinit {
        ref.removeObserver(withHandle: refHandle)
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
        
        cell.labelField.text = self.photos[indexPath.row].thumb
        
        return cell
        
    }
}

//MARK: Picker Delegate
extension PhotoListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
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
                            self.userRef?.child("photos").child(uuid).setValue(url?.absoluteString)
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
        
        dismiss(animated: true, completion: nil)
    }
}
