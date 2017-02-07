//
//  StampsViewController.swift
//  stamp
//
//  Created by Serkan Sokmen on 22/01/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SwiftyCam
import Kingfisher
import Mapbox
import HDAugmentedReality


class StampsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBAction func addPhotoTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: Constants.stampsToCapture, sender: self)
    }
    
    @IBAction func showARController(_ sender: UIButton) {
        
        var annotations: [ARAnnotation] = []
        ref.observeSingleEvent(of: .value, with: { [unowned self] snapshot in
            for (_, photoSnapshot) in snapshot.children.enumerated() {
                guard let value = (photoSnapshot as? FIRDataSnapshot)?.value as? [String:Any] else { return }
                guard let photo = Photo(json: value) else { return }
                
                let annotation = PhotoAnnotation(photo)
                
                annotation.title = photo.uuid
                annotations.append(annotation)
            }
            self.arViewController = ARViewController()
            
            self.arViewController.dataSource = self
            
            self.arViewController.maxVisibleAnnotations = 30
            self.arViewController.headingSmoothingFactor = 0.05
            
            self.arViewController.setAnnotations(annotations)
            
            self.present(self.arViewController, animated: true, completion: nil)
        })
    }
    
    var annotations: [MGLPointAnnotation] = []
    let locationManager = CLLocationManager()
    var ref: FIRDatabaseReference!
    
    fileprivate var arViewController: ARViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photos"
        
//        mapView.userTrackingMode = .none
        mapView.delegate = self
        
//        locationManager.delegate = self
//        locationManager.requestLocation()
        
        ref = userRef?.child("photos")
        isHeroEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.stampsToCapture {
            let vc = segue.destination as! CaptureViewController
            vc.cameraDelegate = self
        }
    }
}

//MARK: Location Manager
extension StampsViewController: MGLMapViewDelegate, CLLocationManagerDelegate {
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always try to show a callout when an annotation is tapped.
        return true
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        self.mapView.removeAnnotations(self.annotations)
        self.annotations.removeAll()
        ref.observeSingleEvent(of: .value, with: { snapshot in
            for (_, photoSnapshot) in snapshot.children.enumerated() {
                guard let value = (photoSnapshot as? FIRDataSnapshot)?.value as? [String:Any] else { return }
                guard let photo = Photo(json: value) else { return }
                
                let annotation = MGLPointAnnotation()
                annotation.coordinate = photo.coordinate
                annotation.title = photo.uuid
                annotation.subtitle = photo.imageUrl
                self.annotations.append(annotation)
            }
            self.mapView.addAnnotations(self.annotations)
        })
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        guard let url = annotation.subtitle else { return nil }
        
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "photo")

        if annotationImage == nil {
            
            KingfisherManager.shared.retrieveImage(with: URL(string: url!)!, options: [], progressBlock: nil, completionHandler: { image, error, cacheType, imageUrl in
                guard var pinImage = image?.kf.image(withRoundRadius: 2.0, fit: CGSize(width: 25, height: 25)) else { return }
                
                pinImage = pinImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: pinImage.size.height/2, right: 0))
                annotationImage = MGLAnnotationImage(image: pinImage, reuseIdentifier: "photo")
            })
        }
        
        return annotationImage
    }
}

//MARK: SwiftyCam
extension StampsViewController: SwiftyCamViewControllerDelegate {
    func SwiftyCamDidTakePhoto(_ photo: UIImage) {
        _ = navigationController?.popViewController(animated: true)
        self.upload(photo, with: self.mapView.userLocation?.coordinate)
    }
}

//MARK: ARAnnotation

extension StampsViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return annotationView
    }
}

extension StampsViewController: AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView) {
        print("Tapped view for POI: \(annotationView.titleLabel?.text)")
    }
}
