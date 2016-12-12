//
//  Weather.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 23/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import Foundation
import MapKit
import CoreData

// @objc(Weather) is not needed as the "Current Product Module" is selected
// in the class inspector on the xcdatamodeld file

/**
    Integrated with core data to support weather forecast
    functionality scheduled for later versions
*/
class Weather: NSManagedObject {
    
    // MARK: - Properties
    
    struct Keys {
        static let Speed = "speed"
        static let Direction = "direction"
        static let Station = "station"
    }
    
    // MARK: - Properties converted to Core Data Attributes
    
    @NSManaged var speed: Double
    @NSManaged var direction: Double
    @NSManaged var station: String
    @NSManaged var runway: Runway
    
    // MARK: - Constructors
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity from the core data model
        let entity = NSEntityDescription.entityForName("Weather", inManagedObjectContext: context)!
        
        // Insert the new Weather into the Core Data Stack
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Initialize the Photo's properties from a dictionary
        speed = dictionary[Keys.Speed] as! Double
        direction = dictionary[Keys.Direction] as! Double
        station = dictionary[Keys.Station] as! String
    }
}