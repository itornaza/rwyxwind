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
    
    //----------------------
    // MARK: - Properties
    //----------------------
    
    struct Keys {
        // Look to the AircraftDataClient for reference
        static let IATACode = "iata_code"
        static let ICAOCode = "icao_code"
        static let Name = "name"
        static let Lat  = "latitude"
        static let Long = "longitude"
        static let Hdg  = "hdg"
        static let Wx   = "wx"
        
        // Keys to be used for the ShortDescriptor attribute within the fetchedResultsController
        struct ShortDescriptor {
            static let IATACode = "iataCode"
            static let ICAOCode = "icaoCode"
            static let Hdg = "hdg"
        }
    }
    
    //-------------------------------------------------------
    // MARK: - Properties converted to Core Data Attributes
    //-------------------------------------------------------
    
    @NSManaged var iataCode: String
    @NSManaged var icaoCode: String
    @NSManaged var name: String
    @NSManaged var lat: Double
    @NSManaged var long: Double
    @NSManaged var hdg: Double
    @NSManaged var wx: Weather
    
    //-------------------------
    // MARK: - Constructors
    //-------------------------
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // Get the entity from the Virtual_Tourist.xcdatamodeld
        let entity = NSEntityDescription.entity(forEntityName: "Runway", in: context)!
        
        // Insert the new Pin into the Core Data Stack
        super.init(entity: entity, insertInto: context)
        
        // Initialize the properties from a dictionary
        self.iataCode = dictionary[Runway.Keys.IATACode] as! String
        self.icaoCode = dictionary[Runway.Keys.ICAOCode] as! String
        self.name = dictionary[Runway.Keys.Name] as! String
        self.lat = Double(dictionary[Runway.Keys.Lat] as! String)!
        self.long = Double(dictionary[Runway.Keys.Long] as! String)!
    }

}
