//
//  AnnotationView.swift
//  stamp
//
//  Created by Serkan Sokmen on 07/02/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import HDAugmentedReality
import Kingfisher

protocol AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView)
}

class AnnotationView: ARAnnotationView {
    
    var titleLabel: UILabel?
    var distanceLabel: UILabel?
    var imageView: UIImageView?
    var delegate: AnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.layer.cornerRadius = 5.0
        loadUI()
    }
    
    func loadUI() {
        titleLabel?.removeFromSuperview()
        distanceLabel?.removeFromSuperview()
        imageView?.removeFromSuperview()
        
        let imgView = UIImageView(frame: CGRect(x: 10, y: 50, width: self.frame.size.width, height: self.frame.size.width))
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        self.addSubview(imgView)
        self.imageView = imgView
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30))
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        distanceLabel = UILabel(frame: CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20))
        distanceLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        distanceLabel?.textColor = UIColor.green
        distanceLabel?.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(distanceLabel!)
        
        if let annotation = annotation as? PhotoAnnotation {
            titleLabel?.text = annotation.photo.uuid
            distanceLabel?.text = String(format: "%.2f km", annotation.distanceFromUser / 1000)
            
            imgView.kf.setImage(with: URL(string: annotation.photo.imageUrl!))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30)
        distanceLabel?.frame = CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouch(annotationView: self)
    }

}
