//
//  FirstViewController.swift
//  Collocation
//
//  Created by Alex G on 03.11.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Public Methods
    func longPressFired(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .Began {
            let coordinate = mapView.convertPoint(gesture.locationInView(mapView), toCoordinateFromView: mapView)
            let annotation = Annotation(coordinate: coordinate)
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "longPressFired:")
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

