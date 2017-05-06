//
//  AirportDataClientConstants.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 21/2/17.
//  Copyright © 2017 polarbear.gr. All rights reserved.
//
/*
    API: http://www.airport-data.com/api/doc.php#airport
 
    Example usage:
    1. IATA to IATA use: http://www.airport-data.com/api/ap_info.json?iata=FRA
    2. ICAO to ICAO use: http://www.airport-data.com/api/ap_info.json?icao=EDDF

    Sample JSON response
    {
        "icao":"EDDF",
        "iata":"FRA",
        "name":"Frankfurt International Airport",
        "location":"Frankfurt am Main",
        "country":"Germany",
        "country_code":"DE",
        "longitude":"8.543125",
        "latitude":"50.026421",
        "link":"http:\/\/www.airport-data.com\/world-airports\/EDDF-FRA\/",
        "status":200
    }
*/

import Foundation

extension AirportDataClient {
    
    struct Constants {
        static let BaseURL = "http://www.airport-data.com/api/ap_info.json?"
        static let ICAO2IATA = "icao="
        static let ICAO = "icao="
        static let IATA2ICAO = "iata="
        static let IATA = "iata="
        static let ApplicationType = "application/json"
        static let HttpHeader = "Accept"
        static let IsIata = 1
        static let IsIcao = 2
    }
    
    struct JSONKeys {
        static let status = "status"
        static let ICAO = "icao"
        static let IATA = "iata"
        static let ICAO_API = "icao_code"
        static let IATA_API = "iata_code"
        static let name	= "name"
        static let location = "location"
        static let country = "country"
        static let countryCode = "country_code"
        static let long = "longitude"
        static let lat = "latitude"
        static let link = "link"
        static let error = "error"
    }
    
    struct Status {
        
        // OK Success!
        struct success {
            static let id = 200
            static let message = "success"
        }
        
        // Not Modified. There was no new data to return.
        struct notModified {
            static let id = 304
            static let message = "Not modified"
        }
        
        // Bad Request. The request was invalid or cannot be otherwise served. An accompanying error message will explain further.
        struct badRequest {
            static let id = 400
            static let message = "Bad request"
        }
        
        // Unauthorized. Authentication credentials were missing or incorrect.
        struct unauthorized {
            static let id = 401
            static let message = "Unauthorized"
        }
        
        // Forbidden. The request is understood, but it has been refused or access is not allowed. An accompanying error message will explain why.
        struct forbidden {
            static let id = 403
            static let message = "Forbidden"
        }
        
        // Not Found. The URI requested is invalid or the resource requested, such as a user, does not exists. Also returned when the requested format is not supported by the requested method.
        struct notFound {
            static let id = 404
            static let message = "Not found"
        }
        
        // Not Acceptable. Returned by the Search API when an invalid format is specified in the request.
        struct notAcceptable {
            static let id = 406
            static let message = "Not acceptable"
        }
        
        // Gone. This resource is gone. Used to indicate that an API endpoint has been turned off.
        struct gone {
            static let id = 410
            static let message = "This resource is gone"
        }
        
        // Too Many Requests. Returned when a request cannot be served due to the application's rate limit having been exhausted for the resource.
        struct tooManyRequests {
            static let id = 429
            static let message = "Too many requests to the server"
        }
        
        // Internal Server Error. Something is broken.
        struct internalServerError {
            static let id = 500
            static let message = "Internal server error"
        }
        
        // Bad Gateway. Site is down or being upgraded.
        struct badGateway {
            static let id = 502
            static let message = "Bad gateway"
        }
        
        // Service Unavailable. The servers are up, but overloaded with requests. Try again later.
        struct serviceUnavailable {
            static let id = 503
            static let message = "Service unavailable"
        }
        
    }
    
    struct LetterCodeCount {
        static let iata = 3
        static let icao = 4
        static let none = -1
    }
    
}
