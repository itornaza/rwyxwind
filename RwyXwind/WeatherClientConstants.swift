//
//  WeatherClientConstants.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 21/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import Foundation

extension WeatherClient {
    
    struct Constants {
        static let APIKey = "f2680cbd795dadef1214d5fe093f95ed"
        static let BaseUrl = "http://api.openweathermap.org/data/2.5/weather?"
        static let APIKeyPrefix = "&APPID="
        static let Lat = "lat="
        static let Long = "&lon="
    }
    
    struct JSONKeys {
        static let StatusCode = "cod"
        static let StationName = "name"
        static let Wind = "wind"
        static let WindDirection = "deg"
        static let WindSpeed = "speed"
    }
    
}
