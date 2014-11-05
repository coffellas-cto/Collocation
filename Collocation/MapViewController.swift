//
//  FirstViewController.swift
//  Collocation
//
//  Created by Alex G on 03.11.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit
import MapKit

let kAnnotationReuseID = "ANNOTATION_ID"
let kSegueIDAddEvent = "SHOW_ADD_EVENT_VC"

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var lastAnnotation: Annotation!
    
    var selectedCoordinate: CLLocationCoordinate2D!
    
    // MARK: Public Methods
    func longPressFired(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .Began {
            
            if lastAnnotation != nil {
                mapView.removeAnnotations([lastAnnotation])
            }
            
            let coordinate = mapView.convertPoint(gesture.locationInView(mapView), toCoordinateFromView: mapView)
            let annotation = Annotation(coordinate: coordinate)
            annotation.title = "Add reminder"
            mapView.addAnnotation(annotation)
            lastAnnotation = annotation
        }
    }
    
    func addReminderTapped() {
        if lastAnnotation != nil {
            mapView.removeAnnotations([lastAnnotation])
            lastAnnotation = nil
        }
        
        reloadMapView()
    }
    
    // MARK: Private Methods
    private func reloadMapView() {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let remindersArray = CoreDataManager.manager.fetchObjectsWithEntityClass(Reminder) as [Reminder]
        var annotationsArray = [Annotation]()
        for reminder in remindersArray {
            let annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: reminder.latitude.doubleValue, longitude: reminder.longitude.doubleValue))
            annotation.title = reminder.name
            annotation.isReminder = true
            annotationsArray.append(annotation)
        }
        
        mapView.addAnnotations(annotationsArray)
    }
    
    // MARK: MKMapViewDelegate Methods
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(kAnnotationReuseID) as MKPinAnnotationView?
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: kAnnotationReuseID)
            annotationView?.canShowCallout = true
        }
        
        if let annotation = annotation as? Annotation {
            annotationView?.rightCalloutAccessoryView = UIButton.buttonWithType(annotation.isReminder ? .InfoLight : .ContactAdd) as UIView
        }
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let annotation = view.annotation as? Annotation {
            if !annotation.isReminder {
                selectedCoordinate = view.annotation.coordinate
                self.performSegueWithIdentifier(kSegueIDAddEvent, sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kSegueIDAddEvent {
            if let toVC = segue.destinationViewController as? AddEventViewController {
                toVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                toVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                toVC.modalInPopover = true
                toVC.coordinate = selectedCoordinate
            }
        }
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addReminderTapped", name: kNotificationCollocationReminderAdded, object: nil)
        
        mapView.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "longPressFired:")
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
        
        reloadMapView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

