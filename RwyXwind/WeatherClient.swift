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
    
    //---------------------------
    // MARK: - Shared Instance
    //---------------------------
    
    class func sharedInstance() -> WeatherClient {
        struct Singleton {
            static var sharedInstance = WeatherClient()
        }
        return Singleton.sharedInstance
    }
    
    //------------------------------
    // MARK: - Core Data properties
    //------------------------------
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var temporaryContext: NSManagedObjectContext!
    
    func setUpTemporaryContext() {
        temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
    }
    
    //--------------------
    // MARK: - Methods
    //--------------------
    
    func getWeatherByCoordinates(_ lat: Double, long: Double, completionHandler: @escaping (_ weather: Weather?, _ errorString: String?) -> Void) {
        
        self.setUpTemporaryContext()
        
        // Create the session
        let session = URLSession.shared
        var parsedResult: NSDictionary!
        
        // Create and configure the request
        let urlString = WeatherClient.Constants.BaseUrl +
                        WeatherClient.Constants.Lat +
                        String(lat) +
                        WeatherClient.Constants.Long +
                        String(long) +
                        WeatherClient.Constants.APIKeyPrefix +
                        WeatherClient.Constants.APIKey
        let url = URL(string: urlString)!
        
        // Create the request
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: { data, response, downloadError in
            
            if downloadError == nil {
                do {
                    // Download succeded, parse the data
                    parsedResult = try JSONSerialization.jsonObject(with: data!,
                        options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                } catch {
                    completionHandler(nil, "Could not parse downloaded data")
                    return
                }
                
                // Check for erroneous response from the API
                if let code = parsedResult.value(forKey: JSONKeys.StatusCode) {
                    if code as? Int != 200 {
                        completionHandler(nil, "Weather service is not available")
                        return
                    }
                }
                
                // Check weather station has a name
                if parsedResult.value(forKey: JSONKeys.StationName) == nil {
                    completionHandler(nil, "Weather station is not available")
                    return
                }
                
                // The response is valid,extract the weather data
                if let dictionary = parsedResult.value(forKey: JSONKeys.Wind) as? [String:AnyObject] {
                    
                    if dictionary[JSONKeys.WindDirection] == nil {
                        completionHandler(nil, "Wind direction is not available")
                        return
                    }
                    
                    if dictionary[JSONKeys.WindSpeed] == nil {
                        completionHandler(nil, "Wind speed is not available")
                        return
                    }
                    
                    var description = ""
                    if let phenomena = parsedResult.value(forKey: JSONKeys.Weather) as? [AnyObject] {
                        description = phenomena[0].value(forKey: JSONKeys.Description)! as! String
                    }
                    
                    // Set up the dictionary to create the runway
                    let weatherDictionary: [String : AnyObject] = [
                        Weather.Keys.Speed      : dictionary[JSONKeys.WindSpeed]!,
                        Weather.Keys.Direction  : dictionary[JSONKeys.WindDirection]!,
                        Weather.Keys.weatherDescription: description as AnyObject,
                        Weather.Keys.Station    : parsedResult.value(forKey: JSONKeys.StationName) as! String as AnyObject
                    ]
                    
                    // Store weather to temporary context as a provision for next versions
                    let weather = Weather(dictionary: weatherDictionary, context: self.temporaryContext)
                    
                    // All succedded
                    completionHandler(weather, nil)
                    return
                    
                } else {
                    completionHandler(nil, "Could not parse weather")
                    return
                }
            } else {
                completionHandler(nil, "Could not complete the download request")
                return
            }
        }) 
        task.resume()
    }
}
