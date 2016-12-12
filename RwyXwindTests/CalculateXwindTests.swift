//
//  CalculateXwindTests.swift
//  RwyXwindTests
//
//  Created by Ioannis Tornazakis on 21/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import XCTest
@testable import RwyXwind

class CalculateXwindTests: XCTestCase {
    
    var windVC = RwyXwind.WindViewController()
    
    // MARK: - Test set up
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.windVC = storyboard.instantiateViewController(withIdentifier: "WindViewController") as! RwyXwind.WindViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Pure wind directions
    
    /// Rwy 28 wind from 280 degrees 10 kts
    func testPureHeadwind() {
        self.measure{
            var crosswind: Double = 0.0
            var headwind: Double = 0.0
            (crosswind, headwind) = self.windVC.calculateXwind(10.0, windDirection: 280.0, runwayHeading: 280.0)
            XCTAssertTrue(self.oneDecimal(headwind) == 10.0)
            XCTAssertTrue(self.oneDecimal(crosswind) == 0.0)
        }
    }
    
    /// Rwy 28 wind from 100 degrees 10 kts
    func testPureTailwind() {
        var crosswind: Double = 0.0
        var headwind: Double = 0.0
        (crosswind, headwind) = self.windVC.calculateXwind(10.0, windDirection: 100.0, runwayHeading: 280.0)
        XCTAssertTrue(self.oneDecimal(headwind) == -10.00)
        XCTAssertTrue(self.oneDecimal(crosswind) == 0.0)
    }
    
    /// Rwy 28 wind from 190 degrees 10 kts
    func testPureLhCrosswind() {
        var crosswind: Double = 0.0
        var headwind: Double = 0.0
        (crosswind, headwind) = self.windVC.calculateXwind(10.0, windDirection: 190.0, runwayHeading: 280.0)
        XCTAssertTrue(self.oneDecimal(headwind) == 0.0)
        XCTAssertTrue(self.oneDecimal(crosswind) == -10.0)
    }
    
    /// Rwy 28 wind from 010 degrees 10 kts
    func testPureRhCrosswind() {
        var crosswind: Double = 0.0
        var headwind: Double = 0.0
        (crosswind, headwind) = self.windVC.calculateXwind(10.0, windDirection: 010.0, runwayHeading: 280.0)
        XCTAssertTrue(self.oneDecimal(headwind) == 0.0)
        XCTAssertTrue(self.oneDecimal(crosswind) == 10.0)
    }
    
    // MARK: - Mixed wind directions
    
    /// Rwy 28 wind from 300 degrees 8.2 kts
    func testheadwindAndRhCrosswind() {
        var crosswind: Double = 0.0
        var headwind: Double = 0.0
        (crosswind, headwind) = self.windVC.calculateXwind(8.2, windDirection: 300.0, runwayHeading: 280.0)
        XCTAssertTrue(self.oneDecimal(headwind) == 7.7)
        XCTAssertTrue(self.oneDecimal(crosswind) == 2.8)

    }
    
    /// Rwy 28 wind from 200 degrees 4.5 kts
    func testHeadwindAndLhCrosswind() {
        var crosswind: Double = 0.0
        var headwind: Double = 0.0
        (crosswind, headwind) = self.windVC.calculateXwind(4.5, windDirection: 200.0, runwayHeading: 280.0)
        XCTAssertTrue(self.oneDecimal(headwind) == 0.8)
        XCTAssertTrue(self.oneDecimal(crosswind) == -4.4)

    }
    
    /// Rwy 10 wind from 260 degrees 23.1 kts
    func testTailwindAndRhCrosswind() {
        var crosswind: Double = 0.0
        var headwind: Double = 0.0
        (crosswind, headwind) = self.windVC.calculateXwind(23.1, windDirection: 260.0, runwayHeading: 100.0)
        XCTAssertTrue(self.oneDecimal(headwind) == -21.7)
        XCTAssertTrue(self.oneDecimal(crosswind) == 7.9)

    }
    
    /// Rwy 10 wind from 310 degrees 3.9 kts
    func testTailwindAndLhCrosswind() {
        var crosswind: Double = 0.0
        var headwind: Double = 0.0
        (crosswind, headwind) = self.windVC.calculateXwind(3.9, windDirection: 310.0, runwayHeading: 100.0)
        XCTAssertTrue(self.oneDecimal(headwind) == -3.4)
        XCTAssertTrue(self.oneDecimal(crosswind) == -2.0)
    }
    
    // MARK: - Helpers
    func oneDecimal(_ number: Double) -> Double {
        return round(10 * number) / 10
    }
    
}
