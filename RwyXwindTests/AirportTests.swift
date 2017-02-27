//
//  AirportTests.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 27/2/17.
//  Copyright © 2017 polarbear.gr. All rights reserved.
//

import XCTest
@testable import RwyXwind

class AirportTests: XCTestCase {
    
    let delay: TimeInterval = 4
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_getAirportByCodeValid() {
        let exp = expectation(description: "completionHandler")
        RwyXwind.AirportClient.sharedInstance().getAirportByCode(LetterCode: "KVA") { runway, error in
            XCTAssertEqual(error, nil)
            XCTAssertEqual(runway?.iataCode, "KVA")
            XCTAssertEqual(runway?.name, "Megas Alexandros Intl")
            exp.fulfill()
        }
        waitForExpectations(timeout: self.delay) { error in
            if error != nil {
                XCTFail("Waited more than \(self.delay)sec for getAirprtByCode to execute")
            }
        }
    }
    
    func test_getAirportByCodeInvalid() {
        let exp = expectation(description: "completionHandler")
        RwyXwind.AirportClient.sharedInstance().getAirportByCode(LetterCode: "ZZZ") { runway, error in
            XCTAssertNotNil(error)
            XCTAssertNil(runway)
            exp.fulfill()
        }
        waitForExpectations(timeout: self.delay) { error in
            if error != nil {
                XCTFail("Waited more than \(self.delay)sec for getAirprtByCode to execute")
            }
        }
    }
    
    func test_getAirportByCodeIncomplete() {
        let exp = expectation(description: "completionHandler")
        RwyXwind.AirportClient.sharedInstance().getAirportByCode(LetterCode: "ZZ") { runway, error in
            XCTAssertNotNil(error)
            XCTAssertNil(runway)
            exp.fulfill()
        }
        waitForExpectations(timeout: self.delay) { error in
            if error != nil {
                XCTFail("Waited more than \(self.delay)sec for getAirprtByCode to execute")
            }
        }
    }
    
}
