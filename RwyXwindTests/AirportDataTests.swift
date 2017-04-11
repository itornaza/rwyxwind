//
//  AirportDataTests.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 27/2/17.
//  Copyright © 2017 polarbear.gr. All rights reserved.
//

import XCTest
@testable import RwyXwind

class AirportDataTests: XCTestCase {
    
    let delay: TimeInterval = 4
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_GetIataValid() {
        let exp = expectation(description: "completionHandler")
        RwyXwind.AirportDataClient.sharedInstance().getAirportByCode(letterCode: "LGKV") { runway, error in
            XCTAssertEqual(error, nil)
            XCTAssertEqual(runway?.iataCode, "KVA")
            exp.fulfill()
        }
        waitForExpectations(timeout: self.delay) { error in
            if error != nil {
                XCTFail("Waited more than \(self.delay)sec for getIata to execute")
            }
        }
    }
    
    func test_getIataInvalid() {
        let exp = expectation(description: "completionHandler")
        RwyXwind.AirportDataClient.sharedInstance().getAirportByCode(letterCode: "ZZZZ") { runway, error in
            XCTAssertNotNil(error)
            XCTAssertNil(runway?.iataCode)
            exp.fulfill()
        }
        waitForExpectations(timeout: self.delay) { error in
            if error != nil {
                XCTFail("Waited more than \(self.delay)sec for getIata to execute")
            }
        }
    }
    
    func test_getIataInvalid_2() {
        let exp = expectation(description: "completionHandler")
        RwyXwind.AirportDataClient.sharedInstance().getAirportByCode(letterCode: "1234") { runway, error in
            XCTAssertNotNil(error)
            XCTAssertNil(runway?.iataCode)
            exp.fulfill()
        }
        waitForExpectations(timeout: self.delay) { error in
            if error != nil {
                XCTFail("Waited more than \(self.delay)sec for getIata to execute")
            }
        }
    }
    
    func test_getIataIncomplete() {
        let exp = expectation(description: "completionHandler")
        RwyXwind.AirportDataClient.sharedInstance().getAirportByCode(letterCode: "ZZ") { runway, error in
            XCTAssertNotNil(error)
            XCTAssertNil(runway?.iataCode)
            exp.fulfill()
        }
        waitForExpectations(timeout: self.delay) { error in
            if error != nil {
                XCTFail("Waited more than \(self.delay)sec for getIata to execute")
            }
        }
    }
    
}
