//
//  AirportClientConstants.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 21/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import Foundation

extension AirportClient {
    
    struct Constants {
        static let UserKey = "f9400512427521179aaefa95f1ac3b10"
        static let UserKeyPrefix = "?user_key="
        static let BaseURL = "https://airport.api.aero/airport/"
        static let AirportString = "match"
        static let ApplicationType = "application/json"
        static let HttpHeader = "Accept"
    }
    
    struct JSONKeys {
        static let Success = "success"
        static let AuthorizedAPI = "authorisedAPI"
        static let Airports = "airports"
        static let AirportName = "name"
        static let AirportCode = "code"
        static let AirportLat = "lat"
        static let AirportLong = "lng"
    }
    
}