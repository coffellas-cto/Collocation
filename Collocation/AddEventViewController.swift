//
//  AddEventViewController.swift
//  Collocation
//
//  Created by Alex G on 03.11.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit
import MapKit

let kRadiusCellID = "RADIUS_CELL"
let kEventNameCellID = "EVENT_NAME_CELL"
class AddEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var coordinate: CLLocationCoordinate2D!
    
    let kDefaultHeaderMapYOffset: CGFloat = -32
    var headerImageYOffset: CGFloat = -32
    var oldScrollViewY: CGFloat = 0
    private var circleOverlay: MKCircle!
    
    // MARK: Outlets & Actions
    weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Private Methods
    
    private func radius() -> Float {
        return (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as RadiusCell!).slider.value
    }
    
    // MARK: Public Methods
    
    func addReminderTapped() {
        
        //let newReminder = CoreDataManager.manager.
        let newReminder = CoreDataManager.manager.newObjectForEntityClass(Reminder) as Reminder
        newReminder.latitude = coordinate.latitude
        newReminder.longitude = coordinate.longitude
        newReminder.radius = radius()
        newReminder.name = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as EventNameCell!).textField.text
        newReminder.date = NSDate()
        
        CoreDataManager.manager.saveContext()
        
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationCollocationReminderAdded, object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func radiusChanged(notification: NSNotification) {
        if let slider = notification.object as? UISlider {
            mapView.removeOverlay(circleOverlay)
            circleOverlay = MKCircle(centerCoordinate: coordinate, radius: CLLocationDistance(radius()))
            self.mapView.addOverlay(circleOverlay)
        }
    }
    
    // MARK: UITableView Delegates Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(kRadiusCellID, forIndexPath: indexPath) as RadiusCell
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(kEventNameCellID, forIndexPath: indexPath) as EventNameCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = NSBundle.mainBundle().loadNibNamed("NewEventFooterView", owner: self, options: nil).first as? NewEventFooterView
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.frame.height - 100 * 2 - tableView.tableHeaderView!.frame.height
    }
    
    // MARK: MKMapView Delegate Methods
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.redColor().colorWithAlphaComponent(0.20)
        
        return renderer
    }
    
    // MARK: UIScrollView Delegate Methods
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y;
        if scrollOffset < 0 {
            // Adjust image proportionally
            if -scrollOffset >= mapView.frame.height + kDefaultHeaderMapYOffset * 2 - 20 {
                scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, oldScrollViewY), animated: false)
                return
            }
            
            oldScrollViewY = scrollOffset
            mapView.frame.origin.y = headerImageYOffset - ((scrollOffset / 2));
        } else {
            mapView.frame.origin.y = headerImageYOffset - scrollOffset;
        }
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addReminderTapped", name: kNotificationCollocationAddReminder, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "radiusChanged:", name: kNotificationCollocationRadiusChanged, object: nil)
        
        mapView = MKMapView(frame: CGRect(x: 0, y: headerImageYOffset, width: self.view.frame.width, height: self.view.frame.height / 2.5 + 15))
        mapView.contentMode = .ScaleAspectFill
        mapView.autoresizingMask = .FlexibleWidth
        mapView.delegate = self
        self.view.insertSubview(mapView, belowSubview: tableView)
                
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: mapView.frame.width, height: mapView.frame.height + kDefaultHeaderMapYOffset * 2))
        tableView.registerNib(UINib(nibName: "RadiusCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: kRadiusCellID)
        tableView.registerNib(UINib(nibName: "EventNameCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: kEventNameCellID)
        
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        mapView.setRegion(region, animated: false)
        
        let annotation = Annotation(coordinate: coordinate)
        mapView.addAnnotation(annotation)
        
        circleOverlay = MKCircle(centerCoordinate: coordinate, radius: CLLocationDistance(1))
        self.mapView.addOverlay(circleOverlay)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if coordinate == nil {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                UIAlertView(title: "Error", message: "Zero coordinate!", delegate: nil, cancelButtonTitle: "OK").show()
            })
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
