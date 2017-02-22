//
//  AirportDataClientConstants.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 21/2/17.
//  Copyright © 2017 polarbear.gr. All rights reserved.
//
// API: http://www.airport-data.com/api/doc.php#airport

/*
     1. IATA to ICAO use
     http://www.airport-data.com/api/ap_info.json?iata=FRA
     
     2. ICAO to IATA use
     http://www.airport-data.com/api/ap_info.json?icao=EDDF
     
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
        static let IATA2ICAO = "iata="
        static let ApplicationType = "application/json"
        static let HttpHeader = "Accept"
        static let IsIata = 1
        static let IsIcao = 2
    }
    
    struct JSONKeys {
        static let ICAO = "icao"
        static let IATA = "iata"
        static let status = "status"
        static let statusSuccess = "200"
        static let statusFail = "404"
    }
}
