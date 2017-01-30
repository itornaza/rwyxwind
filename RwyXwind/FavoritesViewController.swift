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
    
    //-------------------------------
    // MARK: - Core data properties
    //-------------------------------
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Runway> = {
        let fetchRequest = NSFetchRequest<Runway>(entityName: "Runway")
        fetchRequest.sortDescriptors = []
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
        }()
    
    //----------------------
    // MARK: - Outlets
    //----------------------
    
    @IBOutlet weak var tableView: UITableView!
    
    //----------------------
    // MARK: - Lifecycle
    //----------------------
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureUI()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clear leftovers
        self.fetchedResultsController.delegate = nil
    }
    
    //-------------------------------
    // MARK: - UITableView delegate
    //-------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell from the table, using the reuse identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "RunwayCell")
        
        // Show the little arrow on the right hand side of the row
        cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        // Find the model object that corresponds to that row
        let runway = fetchedResultsController.object(at: indexPath) 
        
        // Set the label in the cell with the data from the model object
        cell!.textLabel?.text = runway.iataCode + " rwy " + self.rwyFromHeading(runway.hdg) + ": " + runway.name
        
        // return the cell.
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the wind view controller from storyboard
        let windVC = self.storyboard!.instantiateViewController(withIdentifier: "WindViewController") as! WindViewController
        
        // Get the favorite runway from core data
        let runway = self.fetchedResultsController.object(at: indexPath) 
        windVC.runway = runway
        
        // Get the weather from the weather client
        WeatherClient.sharedInstance().getWeatherByCoordinates(runway.lat, long: runway.long) { weather, error in
            if error != nil {
                self.alertView("Weather service error", message: error!)
            } else {
                windVC.weather = weather!
                
                // Trigger the segue on the main queue
                OperationQueue.main.addOperation {
                    self.present(windVC, animated: false, completion: nil)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
            switch (editingStyle) {
            case .delete:
                let runway = fetchedResultsController.object(at: indexPath) 
                sharedContext.delete(runway)
                CoreDataStackManager.sharedInstance().saveContext()
            default:
                break
            }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType) {
            
            switch type {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
                
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                
            default:
                return
            }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
            
            switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
                
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
                
            default:
                return
            }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    /// Cell color theme
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Theme.sharedInstance().darkGray
        cell.textLabel?.textColor = Theme.sharedInstance().green
    }
    
    //----------------------
    // MARK: - Helpers
    //----------------------
    
    /// The active runway is in the form of 2 digits
    func rwyFromHeading(_ runwayHeading: Double) -> String {
        let rwy = Int(round(runwayHeading/10))
        return String(format: "%02d", rwy)
    }
    
    func configureUI() {
        self.tableView.backgroundColor = Theme.sharedInstance().darkGray
    }
    
    //----------------------
    // MARK: - Alerts
    //----------------------
    
    func alertView(_ title: String, message: String) {
        OperationQueue.main.addOperation {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(dismiss)
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
