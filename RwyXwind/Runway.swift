//
//  Runway.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 23/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import Foundation
import MapKit
import CoreData

// @objc(Runway) is not needed as the "Current Product Module" is selected 
// in the class inspector on the xcdatamodeld file

class Runway: NSManagedObject {
    
    // MARK: - Properties
    
    struct Keys {
        static let IATACode = "iata_code"
        static let Name = "name"
        static let Lat  = "lat"
        static let Long = "long"
        static let Hdg  = "hdg"
        static let Wx   = "wx"
    }
    
    // MARK: - Properties converted to Core Data Attributes
    
    @NSManaged var iataCode: String
    @NSManaged var name: String
    @NSManaged var lat: Double
    @NSManaged var long: Double
    @NSManaged var hdg: Double
    @NSManaged var wx: Weather
    
    // MARK: - Constructors
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity from the Virtual_Tourist.xcdatamodeld
        let entity = NSEntityDescription.entity(forEntityName: "Runway", in: context)!
        
        // Insert the new Pin into the Core Data Stack
        super.init(entity: entity, insertInto: context)
        
        // Initialize the properties from a dictionary
        iataCode = dictionary[Keys.IATACode] as! String
        name = dictionary[Keys.Name] as! String
        lat = dictionary[Keys.Lat] as! Double
        long = dictionary[Keys.Long] as! Double
    }

}
