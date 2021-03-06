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
    
    @IBAction func editModeTapped(sender: AnyObject) {
        if let buttonItem = sender as? UIBarButtonItem {
            if tableView.editing {
                buttonItem.title = "Edit"
            }
            else {
                buttonItem.title = "Done"
            }
            
            tableView.setEditing(!tableView.editing, animated: true)
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController!
    
    // MARK: Public Methods
    
    func switchValueChanged(notification: NSNotification) {
        if let cell = notification.object as? ReminderCell {
            if let indexPath = tableView.indexPathForCell(cell) {
                if let reminder = fetchedResultsController.fetchedObjects?[indexPath.row] as? Reminder {
                    reminder.enabled = NSNumber(bool: cell.switchEnabled.on)
                    CoreDataManager.manager.saveContext()
                    NSNotificationCenter.defaultCenter().postNotificationName(kNotificationCollocationStorageChanged, object: nil)
                }
            }
        }
    }
    
    func cloudChangesReceived(notification: NSNotification)
    {
        println("cloudChangesReceived")
        CoreDataManager.manager.managedObjectContext!.mergeChangesFromContextDidSaveNotification(notification)
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationCollocationMustUpdateMap, object: nil)
    }
    
    // MARK: UITableView Delegates Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("REMINDER_CELL") as ReminderCell
        
        let reminder = fetchedResultsController.fetchedObjects?[indexPath.row] as Reminder
        cell.nameLabel.text = reminder.name
        cell.radiusLabel.text = NSString(format: "%.01f m", reminder.radius.floatValue)
        cell.coordinateLabel.text = NSString(format: "%.06f; %.06f", reminder.latitude.floatValue, reminder.longitude.floatValue)
        cell.switchEnabled.on = reminder.enabled.boolValue
        cell.containerView.alpha = cell.switchEnabled.on ? 1 : 0.3
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let reminder = fetchedResultsController.fetchedObjects?[indexPath.row] as? Reminder {
                CoreDataManager.manager.deleteObject(reminder)
                CoreDataManager.manager.saveContext()
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationCollocationStorageChanged, object: nil)
            }
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            return
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchValueChanged:", name: kNotificationCollocationReminderCellSwitchValueChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cloudChangesReceived:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: CoreDataManager.manager.persistentStoreCoordinator)
        
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


}

