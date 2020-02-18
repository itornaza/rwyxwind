//
//  FavoritesViewController.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 26/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController:  UIViewController {
    
    // MARK: - Properties
    
    let sortingKey = "sorting_key"
    
    // MARK: Core data properties
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Runway> = {
        let fetchRequest = NSFetchRequest<Runway>(entityName: "Runway")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: self.getShortDescriptor(), ascending: true),
            NSSortDescriptor(key: Runway.Keys.ShortDescriptor.Hdg, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
        }()
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.deconfigureFetch()
    }
    
    // MARK: - Actions
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        if self.tableView.isEditing {
            // If in Edit mode, switch to normal mode
            self.tableView.setEditing(false, animated: true)
            self.tableView.isEditing = false
            self.editButton.title = "Edit"
        } else {
            // If in Normal mode, switch to editing mode
            self.tableView.setEditing(true, animated: true)
            self.tableView.isEditing = true
            self.editButton.title = "Done"
        }
    }
    
    @IBAction func sort(_ sender: UIBarButtonItem) {
        self.sortButton.title = (self.sortButton.title == "Sort by IATA") ? "Sort by ICAO" : "Sort by IATA"
        self.toggleShortDescriptor()
        
        // 1. Set the fetch request
        fetchedResultsController.fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: self.getShortDescriptor(), ascending: true),
            NSSortDescriptor(key: Runway.Keys.ShortDescriptor.Hdg, ascending: true)
        ]
        
        // 2. Perform fetch
        do {
            try fetchedResultsController.performFetch()
        } catch {
            self.alertView("Internal error", message: "Could not get bookmarks")
        }
        
        // 3. Reorder table rows
        tableView.reloadData()
    }
    
    // MARK: - Helpers
    
    /// The active runway is in the form of 2 digits
    func rwyFromHeading(_ runwayHeading: Double) -> String {
        let rwy = Int(round(runwayHeading/10))
        return String(format: "%02d", rwy)
    }
    
    /// Short getter for user defaults
    func sortIsIcao() -> Bool {
        if UserDefaults.standard.string(forKey: self.sortingKey)! == Runway.Keys.ShortDescriptor.ICAOCode {
            return true
        } else {
            return false
        }
    }
    
    func getShortDescriptor() -> String {
        if UserDefaults.standard.string(forKey: self.sortingKey)! == Runway.Keys.ShortDescriptor.ICAOCode {
            return Runway.Keys.ShortDescriptor.ICAOCode
        } else {
            return Runway.Keys.ShortDescriptor.IATACode
        }
    }
    
    func toggleShortDescriptor() {
        if UserDefaults.standard.string(forKey: self.sortingKey)! == Runway.Keys.ShortDescriptor.ICAOCode {
            UserDefaults.standard.set(Runway.Keys.ShortDescriptor.IATACode, forKey: self.sortingKey)
        } else {
            UserDefaults.standard.set(Runway.Keys.ShortDescriptor.ICAOCode, forKey: self.sortingKey)
        }
    }
    
    func configureFetch() {
        // Make the sorting option persistent
        if (UserDefaults.standard.string(forKey: self.sortingKey) == nil) {
            UserDefaults.standard.set(Runway.Keys.ShortDescriptor.ICAOCode, forKey: self.sortingKey)
        }
        
        fetchedResultsController.delegate = self
        
        // 1. Set the fetch request
        fetchedResultsController.fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: self.getShortDescriptor(), ascending: true),
            NSSortDescriptor(key: Runway.Keys.ShortDescriptor.Hdg, ascending: true)
        ]
        
        // 2. Perform Fetch
        do {
            try fetchedResultsController.performFetch()
        } catch {
            self.alertView("Internal error", message: "Could not get bookmarks")
        }
        
        // 3. Reordering of table rows is done in the configureUI()
    }
    
    func configureSortButton() {
        if UserDefaults.standard.string(forKey: self.sortingKey)! == Runway.Keys.ShortDescriptor.ICAOCode {
            self.sortButton.title = "Sort by IATA"
        } else {
            self.sortButton.title = "Sort by ICAO"
        }
    }
    
    func configureUI() {
        self.view.backgroundColor = Theme.sharedInstance().darkGray
        self.navigationBar.barTintColor = Theme.sharedInstance().darkGray
        self.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(
            [NSAttributedString.Key.foregroundColor.rawValue: Theme.sharedInstance().yellow])
        
        self.editButton.tintColor = Theme.sharedInstance().yellow
        self.sortButton.tintColor = Theme.sharedInstance().yellow
        self.configureSortButton()
        self.tableView.backgroundColor = Theme.sharedInstance().darkGray
        self.tableView.reloadData()
    }
    
    func deconfigureFetch() {
        self.fetchedResultsController.delegate = nil
    }
    
    func configureRwyTitle(runway: Runway) -> String {
        return runway.icaoCode + " (" + runway.iataCode + ") " + self.rwyFromHeading(runway.hdg) + ": " + runway.name
    }
    
    // MARK: - Alerts
    
    func alertView(_ title: String, message: String) {
        OperationQueue.main.addOperation {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(dismiss)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
    
extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell from the table, using the reuse identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "RunwayCell")

        // Configure row appearance
        cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell!.selectionStyle = UITableViewCell.SelectionStyle.none
        
        // Find the model object that corresponds to that row
        let runway = fetchedResultsController.object(at: indexPath)
        
        // Set the label in the cell with the data from the model object
        cell!.textLabel?.text = self.configureRwyTitle(runway: runway)
        
        // return the cell
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the wind view controller from storyboard
        let windVC = self.storyboard!.instantiateViewController(withIdentifier: "WindViewController")
            as! WindViewController
        
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
            switch (editingStyle) {
            case .delete:
                let runway = fetchedResultsController.object(at: indexPath)
                sharedContext.delete(runway)
                CoreDataStackManager.sharedInstance().saveContext()
            default:
                break
            }
    }
    
    /// Cell color theme
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Theme.sharedInstance().darkGray
        cell.textLabel?.textColor = Theme.sharedInstance().green
    }
}

extension FavoritesViewController: NSFetchedResultsControllerDelegate {
    
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
            break
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
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) ->
    [NSAttributedString.Key: Any]? {
        
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
