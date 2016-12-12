//
//  WeatherClient.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 21/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class WeatherClient {
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> WeatherClient {
        struct Singleton {
            static var sharedInstance = WeatherClient()
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
    
    func getWeatherByCoordinates(lat: Double, long: Double, completionHandler: (weather: Weather?, errorString: String?) -> Void) {
        
        self.setUpTemporaryContext()
        
        // Create the session
        let session = NSURLSession.sharedSession()
        var parsedResult: NSDictionary!
        
        // Create and configure the request
        let urlString = WeatherClient.Constants.BaseUrl +
                        WeatherClient.Constants.Lat +
                        String(lat) +
                        WeatherClient.Constants.Long +
                        String(long) +
                        WeatherClient.Constants.APIKeyPrefix +
                        WeatherClient.Constants.APIKey
        let url = NSURL(string: urlString)!
        
        // Create the request
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if downloadError == nil {
                do {
                    // Download succeded, parse the data
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!,
                        options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                } catch {
                    completionHandler(weather: nil, errorString: "Could not parse downloaded data")
                    return
                }
                
                // Check for erroneous response from the API
                if let code = parsedResult.valueForKey(JSONKeys.StatusCode) {
                    if code as! Int != 200 {
                        completionHandler(weather: nil, errorString: "Weather service is not available")
                        return
                    }
                }
                
                // Check weather station has a name
                if parsedResult.valueForKey(JSONKeys.StationName) == nil {
                    completionHandler(weather: nil, errorString: "Weather station is not available")
                    return
                }
                
                // The response is valid, extract the weather data
                if let dictionary = parsedResult.valueForKey(JSONKeys.Wind) as? [String:AnyObject] {
                    
                    if dictionary[JSONKeys.WindDirection] == nil {
                        completionHandler(weather: nil, errorString: "Wind direction is not available")
                        return
                    }
                    
                    if dictionary[JSONKeys.WindSpeed] == nil {
                        completionHandler(weather: nil, errorString: "Wind speed is not available")
                        return
                    }
                    
                    // Set up the dictionary to create the runway
                    let weatherDictionary: [String : AnyObject] = [
                        Weather.Keys.Speed      : dictionary[JSONKeys.WindSpeed]!,
                        Weather.Keys.Direction  : dictionary[JSONKeys.WindDirection]!,
                        Weather.Keys.Station    : parsedResult.valueForKey(JSONKeys.StationName) as! String
                    ]
                    
                    // Store weather to temporary context as a provision for next versions
                    let weather = Weather(dictionary: weatherDictionary, context: self.temporaryContext)
                    
                    // All succedded
                    completionHandler(weather: weather, errorString: nil)
                    return
                    
                } else {
                    completionHandler(weather: nil, errorString: "Could not parse weather")
                    return
                }
            } else {
                completionHandler(weather: nil, errorString: "Could not complete the download request")
                return
            }
        }
        task.resume()
    }
}