//
//  AirportDataClient.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 21/2/17.
//  Copyright © 2017 polarbear.gr. All rights reserved.
//

import Foundation

class AirportDataClient {
    
    /// ICAO --> IATA
    class func getIata(fromIcao: String, completionHandler: @escaping (_ iata: String?, _ errorString: String?) -> Void) {
        // Create the session
        let session = URLSession.shared
        var parsedResult: NSDictionary!
        
        // Create and configure the request
        let urlString = Constants.BaseURL + Constants.ICAO2IATA + fromIcao
        let url = URL(string: urlString)!
        
        // Configure the request to return json
        let request = NSMutableURLRequest(url: url)
        request.addValue(Constants.ApplicationType, forHTTPHeaderField: Constants.HttpHeader)
        
        // Set up the networking task
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, downloadError in
            if downloadError == nil {
                // Get the downloaded data
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data!,
                        options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                } catch {
                    completionHandler(nil, "Could not parse downloaded data")
                    return
                }
                
                // Check successfull response
                if parsedResult.value(forKey: JSONKeys.status) as? Int !=  JSONKeys.statusSuccess {
                    completionHandler(nil, "ICAO service is unavailable right now. Please, try again later")
                }
                
                // Check ICAO code exist
                if parsedResult.value(forKey: JSONKeys.ICAO) == nil {
                    completionHandler(nil, "ICAO code does not exist or is not supported 😔")
                    return
                }
                
                let iata = parsedResult.value(forKey: JSONKeys.IATA) as? String
                if iata == nil {
                    completionHandler(nil, "Sorry, could not map IATA code to ICAO in order to continue 🙁")
                } else {
                    // All succeded
                    completionHandler(iata, nil)
                    return
                }
                
            } else {
                completionHandler(nil, "Could not parse IATA codes")
                return
            }
        })
        
        // Run the task until it os completed
        task.resume()
    }
}
