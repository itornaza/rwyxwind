//
//  AirportClient.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 21/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class AirportClient {
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> AirportClient {
        struct Singleton {
            static var sharedInstance = AirportClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Core Data properties
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var temporaryContext: NSManagedObjectContext!
    
    func setUpTemporaryContext() {
        temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
    }
    
    // MARK: - Methods
    
    func getAirportByCode(LetterCode LetterCode: String, completionHandler: (runway: Runway?, errorString: String?) -> Void) {
        
        self.setUpTemporaryContext()
        
        // Create the session
        let session = NSURLSession.sharedSession()
        var parsedResult: NSDictionary!
        
        // Create and configure the request
        let urlString = AirportClient.Constants.BaseURL +
                        LetterCode +
                        AirportClient.Constants.UserKeyPrefix +
                        AirportClient.Constants.UserKey
        let url = NSURL(string: urlString)!
        
        // Configure the request to return json
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.ApplicationType, forHTTPHeaderField: Constants.HttpHeader)
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if downloadError == nil {
                do {
                    // Download succeded, parse the data
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!,
                        options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                } catch {
                    completionHandler(runway: nil, errorString: "Could not parse downloaded data")
                    return
                }
                
                // Check API key for validity
                if let authorization = parsedResult.valueForKey(JSONKeys.AuthorizedAPI) {
                    if authorization as! Int == 0 {
                        completionHandler(runway: nil, errorString: "Access to Airports is not allowed")
                        return
                    }
                }
                
                // Check IATA code for validity
                if let result = parsedResult.valueForKey(JSONKeys.Success) {
                    if result as! Int == 0 {
                        completionHandler(runway: nil, errorString: "Invalid airport code")
                        return
                    }
                }
                
                if let dictionary = parsedResult.valueForKey(JSONKeys.Airports) as? [[String:AnyObject]] {
                    
                    for airport in dictionary {
                        
                        if airport[JSONKeys.AirportName] == nil {
                            completionHandler(runway: nil, errorString: "Airport name is not available")
                            return
                        }
                        
                        if airport[JSONKeys.AirportCode] == nil {
                            completionHandler(runway: nil, errorString: "Airport code is not available")
                            return
                        }
                        
                        if airport[JSONKeys.AirportLat] == nil {
                            completionHandler(runway: nil, errorString: "Latitude is not available")
                            return
                        }
                        
                        if airport[JSONKeys.AirportLong] == nil {
                            completionHandler(runway: nil, errorString: "Longitude is not available")
                            return
                        }
                        
                        // Set up the dictionary to create the runway
                        let runwayDictionary: [String : AnyObject] = [
                            Runway.Keys.IATACode: airport[JSONKeys.AirportCode]!,
                            Runway.Keys.Name    : airport[JSONKeys.AirportName]!,
                            Runway.Keys.Lat     : airport[JSONKeys.AirportLat]!,
                            Runway.Keys.Long    : airport[JSONKeys.AirportLong]!
                        ]
                        
                        // Add runway to temporary context so the runway is not included
                        // to favorites by default
                        let runway = Runway(dictionary: runwayDictionary, context: self.temporaryContext)

                        // All succedded
                        completionHandler(runway: runway, errorString: nil)
                        return
                    }
                } else {
                    completionHandler(runway: nil, errorString: "Could not parse airports")
                    return
                }
            } else {
                completionHandler(runway: nil, errorString: "Could not complete the download request")
                return
            }
        }
        task.resume()
    }
    
}
