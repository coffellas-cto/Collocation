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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var lastAnnotation: Annotation!
    private let locationManager = CLLocationManager()
    private var mustReloadMapView = true
    private var zoomedOnFirstUserLocationUpdate = false

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
    
    func reminderAdded(notificiation: NSNotification) {
        // Check if user has already seen the permission alrt for notifications
        if NSUserDefaults.standardUserDefaults().objectForKey(kCollocationLocalNotificationsPermissionAlertShownKey) == nil {
            let types: UIUserNotificationType = .Alert | .Badge | .Sound
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: types, categories: nil))
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: kCollocationLocalNotificationsPermissionAlertShownKey)
        }
        
        println("Reminder added:")
        if let reminder = notificiation.userInfo?[kNotificationCollocationReminderAddedRiminderKey] as? Reminder {
            println("\(reminder.latitude); \(reminder.longitude)")
        }
        
        if lastAnnotation != nil {
            mapView.removeAnnotations([lastAnnotation])
            lastAnnotation = nil
        }
        
        reloadMapView()
    }
    
    func storageChanged() {
        mustReloadMapView = true
    }
    
    // MARK: Private Methods
    private func startMonitoringRegionsWithReminders(reminders: [Reminder]) {
        let activeRegions = locationManager.monitoredRegions
        for region in activeRegions {
            locationManager.stopMonitoringForRegion(region as? CLRegion)
        }
        
        for reminder in reminders {
            var geoRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: reminder.latitude.doubleValue, longitude: reminder.longitude.doubleValue), radius: CLLocationDistance(reminder.radius.doubleValue), identifier: "\(reminder.regionID)")
            self.locationManager.startMonitoringForRegion(geoRegion)
        }
    }
    
    private func reloadMapView() {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        let remindersArray = CoreDataManager.manager.fetchObjectsWithEntityClass(Reminder) as [Reminder]
        startMonitoringRegionsWithReminders(remindersArray)
        var annotationsArray = [Annotation]()
        var overlaysArray = [MKCircle]()
        for reminder in remindersArray {
            let coordinate = CLLocationCoordinate2D(latitude: reminder.latitude.doubleValue, longitude: reminder.longitude.doubleValue)
            let annotation = Annotation(coordinate: coordinate)
            annotation.title = reminder.name
            annotation.isReminder = true
            annotationsArray.append(annotation)
            
            let circleOverlay = MKCircle(centerCoordinate: coordinate, radius: CLLocationDistance(reminder.radius.doubleValue))
            circleOverlay.title = reminder.enabled.boolValue ? nil : "0"
            overlaysArray.append(circleOverlay)
        }
        
        mapView.addAnnotations(annotationsArray)
        mapView.addOverlays(overlaysArray)
    }
    
    // MARK: MKMapViewDelegate Methods
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
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
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        if !zoomedOnFirstUserLocationUpdate {
            let mapRegion = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(mapRegion, animated: true)
            zoomedOnFirstUserLocationUpdate = false
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = overlay.title? == "0" ? UIColor.blackColor().colorWithAlphaComponent(0.05) : UIColor.redColor().colorWithAlphaComponent(0.2)
        return renderer
    }
    
    // MARK: CLLocationManagerDelegate Methods
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("Entered region: \(region.identifier)")
        
        if let reminder = CoreDataManager.manager.fetchObjectsWithEntityClass(Reminder.classForCoder(), predicateFormat: "regionID == %@", region.identifier)?.first as? Reminder {
            if reminder.enabled.boolValue {
                println("Reminder: \(reminder.name)")
                
                let alertBody = "Entered region: \(reminder.name)"
                // Send notification if in background
                if UIApplication.sharedApplication().applicationState != UIApplicationState.Active {
                    let localNotification = UILocalNotification()
                    localNotification.fireDate = NSDate()
                    localNotification.alertBody = alertBody
                    localNotification.soundName = UILocalNotificationDefaultSoundName
                    localNotification.alertAction = "Show"
                    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                }
                else {
                    UIAlertView(title: "Reminder", message: alertBody, delegate: nil, cancelButtonTitle: "OK").show()
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("Left region: \(region.identifier)")
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized:
            //locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        case .Denied, .Restricted:
            UIAlertView(title: "Alert", message: "In order to get all features of application working you must turn on location services for it.", delegate: nil, cancelButtonTitle: "OK").show()
        default:
            break
        }
        
        println("didChangeAuthorizationStatus: \(status.rawValue)")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            println(location.coordinate.latitude)
        }
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reminderAdded:", name: kNotificationCollocationReminderAdded, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "storageChanged", name: kNotificationCollocationStorageChanged, object: nil)
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "longPressFired:")
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
        
        if let status = CLLocationManager.authorizationStatus() as CLAuthorizationStatus? {
            if status == .NotDetermined {
                locationManager.requestAlwaysAuthorization()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if mustReloadMapView {
            reloadMapView()
            mustReloadMapView = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Segues
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
}

