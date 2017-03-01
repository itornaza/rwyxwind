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
        RwyXwind.AirportDataClient.getIata(fromIcao: "LGKV") { iata, errorString in
            XCTAssertEqual(errorString, nil)
            XCTAssertEqual(iata, "KVA")
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
        RwyXwind.AirportDataClient.getIata(fromIcao: "ZZZZ") { iata, errorString in
            XCTAssertNotNil(errorString)
            XCTAssertNil(iata)
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
        RwyXwind.AirportDataClient.getIata(fromIcao: "1234") { iata, errorString in
            XCTAssertNotNil(errorString)
            XCTAssertNil(iata)
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
        RwyXwind.AirportDataClient.getIata(fromIcao: "ZZ") { iata, errorString in
            XCTAssertNotNil(errorString)
            XCTAssertNil(iata)
            exp.fulfill()
        }
        waitForExpectations(timeout: self.delay) { error in
            if error != nil {
                XCTFail("Waited more than \(self.delay)sec for getIata to execute")
            }
        }
    }
    
}
