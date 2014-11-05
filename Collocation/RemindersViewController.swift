//
//  SecondViewController.swift
//  Collocation
//
//  Created by Alex G on 03.11.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit
import CoreData

class RemindersViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController!
    
    // MARK: UITableView Delegates Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("REMINDER_CELL") as ReminderCell
        
        let reminder = fetchedResultsController.fetchedObjects?[indexPath.row] as Reminder
        cell.nameLabel.text = reminder.name
        cell.radiusLabel.text = NSString(format: "%.01f", reminder.radius.floatValue)
        cell.coordinateLabel.text = NSString(format: "%.06f; %.06f", reminder.latitude.floatValue, reminder.longitude.floatValue)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(fetchedResultsController.fetchedObjects?.count)
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56
    }
    
    // MARK: NSFetchedResultsControllerDelegate Methods
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerNib(UINib(nibName: "ReminderCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "REMINDER_CELL")
        
        let request = NSFetchRequest(entityName: CoreDataManager.entityNameFromClass(Reminder)!)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.manager.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        if error != nil {
            println(error?.localizedDescription)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

