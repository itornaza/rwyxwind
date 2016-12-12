//
//  FavoritesViewController.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 26/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class FavoritesViewController:  UIViewController,
                                UITableViewDelegate,
                                UITableViewDataSource,
                                NSFetchedResultsControllerDelegate {
    
    // MARK: - Core data properties
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Runway")
        fetchRequest.sortDescriptors = []
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
        }()
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up fetched results controller
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            self.alertView("Internal error", message: "Could not get bookmarks")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.configureUI()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clear leftovers
        self.fetchedResultsController.delegate = nil
    }
    
    // Mark: UITableView delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Dequeue a reusable cell from the table, using the reuse identifier
        let cell = tableView.dequeueReusableCellWithIdentifier("RunwayCell")
        
        // Show the little arrow on the right hand side of the row
        cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        // Find the model object that corresponds to that row
        let runway = fetchedResultsController.objectAtIndexPath(indexPath) as! Runway
        
        // Set the label in the cell with the data from the model object
        cell!.textLabel?.text = runway.iataCode + " rwy " + self.rwyFromHeading(runway.hdg) + ": " + runway.name
        
        // return the cell.
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Get the wind view controller from storyboard
        let windVC = self.storyboard!.instantiateViewControllerWithIdentifier("WindViewController") as! WindViewController
        
        // Get the favorite runway from core data
        let runway = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Runway
        windVC.runway = runway
        
        // Get the weather from the weather client
        WeatherClient.sharedInstance().getWeatherByCoordinates(runway.lat, long: runway.long) { weather, error in
            if error != nil {
                self.alertView("Weather service error", message: error!)
            } else {
                windVC.weather = weather!
                
                // Trigger the segue on the main queue
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(windVC, animated: false, completion: nil)
                }
            }
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
            switch (editingStyle) {
            case .Delete:
                let runway = fetchedResultsController.objectAtIndexPath(indexPath) as! Runway
                sharedContext.deleteObject(runway)
                CoreDataStackManager.sharedInstance().saveContext()
            default:
                break
            }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                return
            }
    }

    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    /**
        Cell color theme
    */
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = Theme.sharedInstance().darkGray
        cell.textLabel?.textColor = Theme.sharedInstance().green
    }
    
    // MARK: - Helpers
    
    /**
        The active runway is in the form of 2 digits
    */
    func rwyFromHeading(runwayHeading: Double) -> String {
        let rwy = Int(round(runwayHeading/10))
        return String(format: "%02d", rwy)
    }
    
    func configureUI() {
        self.tableView.backgroundColor = Theme.sharedInstance().darkGray
    }
    
    // MARK: - Alerts
    
    func alertView(title: String, message: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let dismiss = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(dismiss)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

}
