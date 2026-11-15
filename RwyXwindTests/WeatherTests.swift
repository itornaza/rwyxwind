//
//  WeatherTests.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 27/2/17.
//  Copyright © 2017 polarbear.gr. All rights reserved.
//

import XCTest
@testable import RwyXwind

class WeatherTests: XCTestCase {
    
    let delay: TimeInterval = 4
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_getWeatherByCoordinatesValid() {
        let exp = expectation(description: "completionHandler")
        RwyXwind.WeatherClient.sharedInstance().getWeatherByCoordinates(40.916267, long: 24.622108) { weather, error in
            XCTAssertNil(error)
            XCTAssertNotNil(weather?.speed)
            XCTAssertNotNil(weather?.direction)
            exp.fulfill()
        }
        waitForExpectations(timeout: self.delay) { error in
            if error != nil {
                XCTFail("Waited more than \(self.delay)sec for getAirprtByCode to execute")
            }
        }
    }
    
    func test_getWeatherByCoordinatesInvalid() {
        let exp = expectation(description: "completionHandler")
        RwyXwind.WeatherClient.sharedInstance().getWeatherByCoordinates(10000.0, long: -10000.0) { weather, error in
            XCTAssertNotNil(error)
            XCTAssertNil(weather)
            exp.fulfill()
        }
        waitForExpectations(timeout: self.delay) { error in
            if error != nil {
                XCTFail("Waited more than \(self.delay)sec for getAirprtByCode to execute")
            }
        }
    }
    
}
