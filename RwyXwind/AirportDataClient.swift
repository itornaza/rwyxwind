//
//  AirportDataClient.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 21/2/17.
//  Copyright © 2017 polarbear.gr. All rights reserved.
//

import Foundation
import CoreData

class AirportDataClient {
    
    //---------------------------
    // MARK: - Shared Instance
    //---------------------------
    
    class func sharedInstance() -> AirportDataClient {
        struct Singleton {
            static var sharedInstance = AirportDataClient()
        }
        return Singleton.sharedInstance
    }
    
    //-------------------------------
    // MARK: - Core Data properties
    //-------------------------------
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var temporaryContext: NSManagedObjectContext!
    
    func setUpTemporaryContext() {
        temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
    }
    
    //-------------------------------
    // MARK: - Class methods
    //-------------------------------

    /// Distinguish between iata, icao or invalid letter code
    func classifyCode(letterCode: String) -> Int {
        if letterCode.characters.count == LetterCodeCount.iata {
            return Constants.IsIata
        } else if letterCode.characters.count == LetterCodeCount.icao {
            return Constants.IsIcao
        } else {
            return LetterCodeCount.none
        }
    }
    
    /// Build the url for either iata or icao codes
    func getUrl(letterCode: String) -> URL? {
        var urlString = String()
        var url: URL?
        
        // Convert from letter count to code type
        switch(self.classifyCode(letterCode: letterCode)) {
            case Constants.IsIata:
                urlString = Constants.BaseURL + Constants.IATA + letterCode
                url = URL(string: urlString)!
            case Constants.IsIcao:
                urlString = Constants.BaseURL + Constants.ICAO + letterCode
                url = URL(string: urlString)!
            default:
                url = nil
        }
        
        return url
    }
    
    /// IATA -> Airport Data
    func getAirportByCode(letterCode: String, completionHandler: @escaping (_ runway: Runway?, _ errorString: String?)
        -> Void) {
        self.setUpTemporaryContext()
        
        // Create the session
        let session = URLSession.shared
        var parsedResult: NSDictionary!
        
        // Create and configure the request
        let url = self.getUrl(letterCode: letterCode)
        if url == nil {
            completionHandler(nil, "Invalid letter code type, neither IATA nor ICAO")
            return
        }
        
        // Configure the request to return json
        let request = NSMutableURLRequest(url: url!)
        request.addValue(Constants.ApplicationType, forHTTPHeaderField: Constants.HttpHeader)
        
        // Create and run the session to download the data from API until it is done
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, downloadError in
            if downloadError == nil {
                do {
                    // Download succeded, parse the data
                    parsedResult = try JSONSerialization.jsonObject(
                        with: data!,
                        options: JSONSerialization.ReadingOptions.allowFragments
                    ) as! NSDictionary
                } catch {
                    completionHandler(nil, "Could not parse downloaded data")
                    return
                }
                
                // Branch on the API return status
                let parseStatus = parsedResult.value(forKey: JSONKeys.status) as? Int
                if parseStatus == Status.success.id {
                    // Parse is successful go on and get the individual elements
                    
                    // Check all dictionary elements are valid and can be later assigned to runway
                    let iataCheck = parsedResult.value(forKey: JSONKeys.IATA)
                    let icaoCheck = parsedResult.value(forKey: JSONKeys.ICAO)
                    let nameCheck = parsedResult.value(forKey: JSONKeys.name)
                    let latCheck = parsedResult.value(forKey: JSONKeys.lat)
                    let longCheck = parsedResult.value(forKey: JSONKeys.long)
                    
                    // Checks
                    if iataCheck == nil {
                        completionHandler(nil, "IATA code is not available")
                        return
                    } else if icaoCheck == nil {
                        completionHandler(nil, "ICAO code is not available")
                        return
                    } else if nameCheck == nil {
                        completionHandler(nil, "Airport name is not available")
                        return
                    } else if latCheck == nil || latCheck as! Int == 0 || Double(latCheck as! String) == nil {
                        completionHandler(nil, "Airport latitude is not available")
                        return
                    } else if longCheck == nil || longCheck as! Int == 0 || Double(longCheck as! String) == nil {
                        completionHandler(nil, "Airport longitude is not available")
                        return
                    }
                    
                    // Set up the dictionary to create the runway
                    let runwayDictionary: [String : AnyObject] = [
                        Runway.Keys.IATACode: parsedResult.value(forKey: JSONKeys.IATA) as AnyObject,
                        Runway.Keys.ICAOCode: parsedResult.value(forKey: JSONKeys.ICAO) as AnyObject,
                        Runway.Keys.Name    : parsedResult.value(forKey: JSONKeys.name) as AnyObject,
                        Runway.Keys.Lat     : parsedResult.value(forKey: JSONKeys.lat) as AnyObject,
                        Runway.Keys.Long    : parsedResult.value(forKey: JSONKeys.long) as AnyObject
                    ]
                    
                    // Add runway to temporary context so the runway is not included to favorites by default
                    let runway = Runway(dictionary: runwayDictionary, context: self.temporaryContext)
                    
                    // Succesfull return
                    completionHandler(runway, nil)
                    return
                } else if parseStatus == Status.badGateway.id {
                    completionHandler(nil, Status.badGateway.message)
                    return
                } else if parseStatus == Status.badRequest.id {
                    completionHandler(nil, Status.badRequest.message)
                    return
                } else if parseStatus == Status.forbidden.id {
                    completionHandler(nil, Status.forbidden.message)
                    return
                } else if parseStatus == Status.gone.id {
                    completionHandler(nil, Status.gone.message)
                    return
                } else if parseStatus == Status.internalServerError.id {
                    completionHandler(nil, Status.internalServerError.message)
                    return
                } else if parseStatus == Status.notAcceptable.id {
                    completionHandler(nil, Status.notAcceptable.message)
                    return
                } else if parseStatus == Status.notFound.id {
                    completionHandler(nil, Status.notFound.message)
                    return
                } else if parseStatus == Status.notModified.id {
                    completionHandler(nil, Status.notModified.message)
                    return
                } else if parseStatus == Status.serviceUnavailable.id {
                    completionHandler(nil, Status.serviceUnavailable.message)
                    return
                } else if parseStatus == Status.tooManyRequests.id {
                    completionHandler(nil, Status.tooManyRequests.message)
                    return
                } else if parseStatus == Status.unauthorized.id {
                    completionHandler(nil, Status.unauthorized.message)
                    return
                } else {
                    completionHandler(nil, "Could not parse the airport data")
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
