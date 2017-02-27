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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetIata() {
        RwyXwind.AirportDataClient.getIata(fromIcao: "LGKV") { iata, errorString in
            XCTAssertEqual(errorString, nil)
            XCTFail()
        }
    }
    
}
