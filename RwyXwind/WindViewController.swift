//
//  WindViewController.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 25/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class WindViewController: UIViewController, UITabBarControllerDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    // Transfered from FindViewController
    var runway: Runway?
    var weather: Weather?
    
    // MARK: Constants
    
    enum TabItemIndex: Int {
        case find = 0
        case favorites = 1
    }
    
    // MARK: Core data properties
    
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
    
    // MARK: - Outlets
    
    @IBOutlet weak var headwind: UILabel!
    @IBOutlet weak var tailwind: UILabel!
    @IBOutlet weak var rhCrosswind: UILabel!
    @IBOutlet weak var lhCrosswind: UILabel!
    @IBOutlet weak var headwindArrow: UIImageView!
    @IBOutlet weak var tailwindArrow: UIImageView!
    @IBOutlet weak var rhCrosswindArrow: UIImageView!
    @IBOutlet weak var lhCrosswindArrow: UIImageView!
    @IBOutlet weak var headwindArrowAlert: UIImageView!
    @IBOutlet weak var tailwindArrowAlert: UIImageView!
    @IBOutlet weak var rhCrosswindArrowAlert: UIImageView!
    @IBOutlet weak var lhCrosswindArrowAlert: UIImageView!
    @IBOutlet weak var airportName: UILabel!
    @IBOutlet weak var weatherStationName: UILabel!
    @IBOutlet weak var actualWind: UILabel!
    @IBOutlet weak var runwayDigits: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResultsController.delegate = self
        self.fetchRunways()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Local variables
        let crossWind: Double
        let headWind: Double
        let runwayHeading = runway!.hdg
        let windSpeed = weather!.speed
        let windDirection = weather!.direction
        
        // Get and display the wind components
        self.setHeaderLabels(windSpeed, windDirection: windDirection)
        (crossWind, headWind) = self.calculateXwind(windSpeed, windDirection: windDirection,
                                                    runwayHeading: runwayHeading)
        
        self.displayWind(headWind, crossWind: crossWind)
        
        // With animations
        self.animateHeadwind()
        self.animateTailWind()
        self.animateLhCrosswind()
        self.animateRhCrosswind()
    }
    
    // MARK: - Actions
    
    @IBAction func FindButtonTouchUp(_ sender: AnyObject) {
        segueToTabBarController(TabItemIndex.find.rawValue)
    }
    
    @IBAction func FavoritesButtonTouchUp(_ sender: AnyObject) {
        segueToTabBarController(TabItemIndex.favorites.rawValue)
    }
    
    @IBAction func AddButtonTouchUp(_ sender: AnyObject) {
        var addToFavorites: Bool = true
        var message = String()
        
        // Check if runway already exists before adding to bookmarks
        let runways = self.fetchedResultsController.fetchedObjects!
        for storedRunway in runways {
            if  self.runway?.iataCode == storedRunway.iataCode && self.runway?.hdg == storedRunway.hdg {
                    addToFavorites = false
                    message = "Already in bookmarks"
            }
        }

        // If the runway is not yet in the bookmarks, go ahead and add it!
        if addToFavorites == true {
            let iataCode: String = (self.runway?.iataCode)!
            let icaoCode: String = (self.runway?.icaoCode)!
            let name: String = (self.runway?.name)!
            let lat: String = "\((self.runway?.lat)!)"
            let long: String = "\((self.runway?.long)!)"

            // Set up the dictionary to create the runway
            let dictionary: [String : AnyObject] = [
                Runway.Keys.IATACode: iataCode as AnyObject,
                Runway.Keys.ICAOCode: icaoCode as AnyObject,
                Runway.Keys.Name    : name as AnyObject,
                Runway.Keys.Lat     : lat as AnyObject,
                Runway.Keys.Long    : long as AnyObject
            ]
            
            // Initialize the runway using core data constructor
            let runwayToAdd = Runway(dictionary: dictionary, context: self.sharedContext)
            runwayToAdd.hdg = (self.runway?.hdg)!
            
            // Save the runway to core data stack
            CoreDataStackManager.sharedInstance().saveContext()
            message = "Added to bookmarks"
            
            // fetch the updated bookmarks to include this last addition
            // and prevent the runway to be added in bookmarks multiple times
            self.fetchRunways()
        }
        
        // Inform the user on the bookmark
        self.alertView((self.runway?.name)! + ", RWY: " + self.rwyFromHeading((self.runway?.hdg)!), message: message)
    }
    
    // MARK: - Helpers
    
    /// Fetch all runway objects from core data and report on error
    func fetchRunways() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            self.alertView("Internal error", message: "Could not get bookmarks")
        }
    }
    
    func setHeaderLabels(_ windSpeed: Double, windDirection: Double) {
        // Airport name
        self.airportName.text = runway!.icaoCode + " (" + runway!.iataCode + "): " + runway!.name
        self.airportName.adjustsFontSizeToFitWidth = true
        self.airportName.minimumScaleFactor = 0.5
        
        // Weather station
        self.weatherStationName.text = weather!.station + " weather station:"
        self.weatherStationName.adjustsFontSizeToFitWidth = true
        self.airportName.minimumScaleFactor = 0.5
        
        // Weather report
        var descriptionWrapper = weather!.weatherDescription
        if descriptionWrapper != "" {
            descriptionWrapper = "with " + descriptionWrapper
        }
        let direction = String(Int(windDirection))
        let speed = String(round(10 * windSpeed) / 10)
        self.actualWind.text = "\"wind from " + direction + " degrees " + speed + " knots " + descriptionWrapper + "\""
        self.actualWind.adjustsFontSizeToFitWidth = true
        self.actualWind.minimumScaleFactor = 0.5
        
        // Runway
        self.runwayDigits.text = self.rwyFromHeading(runway!.hdg)
    }
    
    /// Convert the runway heading (3 digits) to the runway number (2 digits)
    func rwyFromHeading(_ runwayHeading: Double) -> String {
        let rwy = Int(round(runwayHeading/10))
        return String(format: "%02d", rwy)
    }
    
    /**
     * Crosswind calculations
     *
     * crossWind + : wind from the right hand side
     * crosswind - : wind from the left hand side
     * headwind  + : wind head on
     * headWind  - : wind tail on
     */
    func calculateXwind(_ windSpeed: Double, windDirection: Double, runwayHeading: Double) ->
        (crossWind: Double, headWind: Double) {
        
        // Get the relative angle between the runway heading and the actual wind
        // in radiants (π radiants = 180 degrees)
        let relativeAngle = (Double.pi * (windDirection - runwayHeading)) / 180
        
        // Get the wind components
        let crossWind = windSpeed * sin(relativeAngle)
        let headWind  = windSpeed * cos(relativeAngle)
        
        // Return the taple with the wind components
        return (crossWind, headWind)
    }
    
    /// Configure the UI upon load to hide and zeroise wind elements
    func configureUI() {
        self.setLabelColors()
        self.runwayDigitsResize()
        self.windComponentsResize()
        
        // LH Crosswind
        self.lhCrosswind.text = ""
        self.lhCrosswind.isHidden = true
        self.lhCrosswindArrow.isHidden = true
        self.lhCrosswindArrowAlert.isHidden = true
        
        // RH Crosswind
        self.rhCrosswind.text = ""
        self.rhCrosswind.isHidden = true
        self.rhCrosswindArrow.isHidden = true
        self.rhCrosswindArrowAlert.isHidden = true
        
        // Tailwind
        self.tailwind.text = ""
        self.tailwind.isHidden = true
        self.tailwindArrow.isHidden = true
        self.tailwindArrowAlert.isHidden = true
        
        // Headwind
        self.headwind.text = ""
        self.headwind.isHidden = true
        self.headwindArrow.isHidden = true
        self.headwindArrowAlert.isHidden = true
    }
    
    func runwayDigitsResize() {
        self.runwayDigits.adjustsFontSizeToFitWidth = true
        self.runwayDigits.numberOfLines = 0
    }
    
    func windComponentsResize() {
        self.rhCrosswind.adjustsFontSizeToFitWidth = true
        self.rhCrosswind.numberOfLines = 0
        self.lhCrosswind.adjustsFontSizeToFitWidth = true
        self.lhCrosswind.numberOfLines = 0
        self.headwind.adjustsFontSizeToFitWidth = true
        self.headwind.numberOfLines = 0
        self.tailwind.adjustsFontSizeToFitWidth = true
        self.tailwind.numberOfLines = 0
    }
    
    func setLabelColors() {
        self.airportName.textColor = Theme.sharedInstance().yellow
        self.weatherStationName.textColor = Theme.sharedInstance().lightGray
        self.actualWind.textColor = Theme.sharedInstance().lightGray
        self.runwayDigits.textColor = Theme.sharedInstance().lightGray
    }
    
    /// Configure the UI with the wind speeds and wind direction arrows
    func displayWind(_ headWind: Double, crossWind: Double) {
        var headWind = headWind, crossWind = crossWind
        
        // Round the wind components to one decimal digit
        headWind = round(10 * headWind) / 10
        crossWind = round(10 * crossWind) / 10
        
        // Display X-axis wind component
        if crossWind < 0 {
            self.displayLhCrosswind(crossWind)
        } else if crossWind > 0 {
            self.displayRhCrosswind(crossWind)
        } else if crossWind == 0 {
            // Display nothing
        }
        
        // Display Y-axis wind component
        if headWind < 0 {
            self.displayTailwind(headWind)
        } else if headWind > 0 {
            self.displayHeadwind(headWind)
        } else if headWind == 0 {
            // Display nothing
        }
    }
    
    func displayLhCrosswind(_ crossWind: Double) {
        self.lhCrosswind.text = String(abs(crossWind))
        self.lhCrosswind.isHidden = false
        if abs(crossWind) <= Double(UserDefaults.standard.integer(forKey: "crosswind_limit")) {
            self.lhCrosswindArrow.isHidden = false
        } else {
            self.lhCrosswindArrowAlert.isHidden = false
        }
    }
    
    func displayRhCrosswind(_ crossWind: Double) {
        self.rhCrosswind.text = String(abs(crossWind))
        self.rhCrosswind.isHidden = false
        if abs(crossWind) <= Double(UserDefaults.standard.integer(forKey: "crosswind_limit")) {
            self.rhCrosswindArrow.isHidden = false
        } else {
            self.rhCrosswindArrowAlert.isHidden = false
        }
    }
    
    func displayTailwind(_ headWind: Double) {
        self.tailwind.text = String(abs(headWind))
        self.tailwind.isHidden = false
        if abs(headWind) <= Double(UserDefaults.standard.integer(forKey: "tailwind_limit")) {
            self.tailwindArrow.isHidden = false
        } else {
            self.tailwindArrowAlert.isHidden = false
        }
    }
    
    func displayHeadwind(_ headWind: Double) {
        self.headwind.text = String(abs(headWind))
        self.headwind.isHidden = false
        if abs(headWind) <= Double(UserDefaults.standard.integer(forKey: "headwind_limit")) {
            self.headwindArrow.isHidden = false
        } else {
            self.headwindArrowAlert.isHidden = false
        }
    }
    
    // MARK: - Alerts and segues
    
    /// Modal segue to the Tab Bar Controller which automatically points to the Find View Controller
    func segueToTabBarController(_ tabItemIndex: Int) {
        let tabBarController = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController")
            as! UITabBarController
        
        tabBarController.selectedIndex = tabItemIndex
        self.present(tabBarController, animated: false, completion: nil)
    }
    
    func alertView(_ title: String, message: String) {
        OperationQueue.main.addOperation {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(dismiss)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
