//
//  RwyXwindUITests.swift
//  RwyXwindUITests
//
//  Created by Ioannis Tornazakis on 21/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import XCTest

class RwyXwindUITests: XCTestCase {
    
    //----------------------
    // MARK: - Properties
    //----------------------
    
    let delay: UInt32 = 4
    
    //------------------------
    // MARK: - Configuration
    //------------------------
    
    /// Run before each test
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
        self.clearBookmarks()
    }
    
    /// Run after each test
    override func tearDown() {
        super.tearDown()
    }
    
    //---------------------
    // MARK: - Tests
    //---------------------
    
    func test_invalidLetterCode() {
        let app = XCUIApplication()
        
        // No input
        app.buttons["Calculate crosswind"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["Please, input IATA or ICAO code to continue"].exists)
        app.alerts["Invalid input"].buttons["OK"].tap()
        
        // One letter input
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element.tap()
        app.keys["K"].tap()
        app.buttons["Return"].tap()
        app.buttons["Calculate crosswind"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["Input 3 letters for IATA or  4 letters for ICAO"].exists)
        app.alerts["Airport service error"].buttons["OK"].tap()
        
        // Two letter input
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element.tap()
        app.keys["V"].tap()
        app.buttons["Return"].tap()
        app.buttons["Calculate crosswind"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["Input 3 letters for IATA or  4 letters for ICAO"].exists)
        app.alerts["Airport service error"].buttons["OK"].tap()
    }
    
    func test_validIATA() {
        let app = XCUIApplication()
        self.inputValidIATA()
        app.buttons["Calculate crosswind"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["KVA: Megas Alexandros Intl"].exists)
    }
    
    func test_invalidIATA() {
        let app = XCUIApplication()
        self.inputInvaldIATA()
        app.buttons["Calculate crosswind"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["Invalid airport code"].exists)
        app.alerts["Airport service error"].buttons["OK"].tap()
    }
    
    func test_validICAO() {
        let app = XCUIApplication()
        self.inputValidICAO()
        app.buttons["Calculate crosswind"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["LGKV: Megas Alexandros Intl"].exists)
    }
    
    func test_invalidICAO() {
        let app = XCUIApplication()
        self.inputInvalidICAO()
        app.buttons["Calculate crosswind"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["Sorry, could not map IATA code to ICAO in order to continue 🙁"].exists)
        app.alerts["Airport service error"].buttons["OK"].tap()
    }
    
    func test_validPicker() {
        let app = XCUIApplication()
        self.inputValidIATA()
        self.pickerSetUp(first: "2", second: "1", third: "3")
        app.buttons["Calculate crosswind"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["21"].exists)
    }
    
    func test_validPcker360() {
        let app = XCUIApplication()
        self.inputValidIATA()
        self.pickerSetUp(first: "0", second: "0", third: "0")
        app.buttons["Calculate crosswind"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["36"].exists)
    }
    
    func test_overflowPickerSecondDigit() {
        let app = XCUIApplication()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "3")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "8")
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["Runway heading shall be from 000 to 360 degrees"].exists)
        app.alerts["Invalid input"].buttons["OK"].tap()
    }
    
    func test_overflowPickerThirdDigit() {
        let app = XCUIApplication()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "3")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "6")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "1")
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["Runway heading shall be from 000 to 360 degrees"].exists)
        app.alerts["Invalid input"].buttons["OK"].tap()
    }
    
    func test_addBookmark() {
        let app = XCUIApplication()
        self.addBookmark()
        XCTAssertTrue(app.tables.staticTexts["KVA rwy 36: Megas Alexandros Intl"].exists)
    }
    
    func test_alreadyBookmark() {
        let app = XCUIApplication()
        self.addBookmark()
        app.tables.staticTexts["KVA rwy 36: Megas Alexandros Intl"].tap()
        let toolbarsQuery = app.toolbars
        toolbarsQuery.buttons["Add"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["Already in bookmarks"].exists)
        app.alerts["Megas Alexandros Intl, RWY: 36"].buttons["OK"].tap()
    }
    
    func test_windFromBookmark() {
        let app = XCUIApplication()
        self.addBookmark()
        app.tables.staticTexts["KVA rwy 36: Megas Alexandros Intl"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["KVA: Megas Alexandros Intl"].exists)
    }
    
    func test_removeBookmark() {
        let app = XCUIApplication()
        self.addBookmark()
        let tablesQuery = app.tables.cells
        tablesQuery.element(boundBy: 0).swipeLeft()
        tablesQuery.element(boundBy: 0).buttons["Delete"].tap()
        XCTAssertEqual(tablesQuery.count, 0)
    }
    
    //---------------------
    // MARK: - Helpers
    //---------------------
    
    func inputIATA(first: String, second: String, third: String) {
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element.tap()
        app.keys[first].tap()
        app.keys[second].tap()
        app.keys[third].tap()
        app.buttons["Return"].tap()
    }
    
    func inputValidIATA() {
        self.inputIATA(first: "K", second: "V", third: "A")
    }
    
    func inputInvaldIATA() {
        self.inputIATA(first: "Z", second: "Z", third: "Z")
    }
    
    func inputICAO(first: String, second: String, third: String, forth: String) {
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element.tap()
        app.keys[first].tap()
        app.keys[second].tap()
        app.keys[third].tap()
        app.keys[forth].tap()
        app.buttons["Return"].tap()
    }
    
    func inputValidICAO() {
        self.inputICAO(first: "L", second: "G", third: "K", forth: "V")
    }
    
    func inputInvalidICAO() {
        self.inputICAO(first: "Z", second: "Z", third: "Z", forth: "Z")
    }
    
    func pickerSetUp(first: String, second: String, third: String) {
        let app = XCUIApplication()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: first)
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: second)
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: third)
    }
    
    func addBookmark() {
        let app = XCUIApplication()
        self.inputValidIATA()
        app.buttons["Calculate crosswind"].tap()
        sleep(self.delay) // Allow time for the transition to complete
        let toolbarsQuery = app.toolbars
        toolbarsQuery.buttons["Add"].tap()
        app.alerts["Megas Alexandros Intl, RWY: 36"].buttons["OK"].tap()
        toolbarsQuery.buttons["Bookmarks"].tap()
    }
    
    func clearBookmarks() {
        let app = XCUIApplication()
        let tabBarsQuery = XCUIApplication().tabBars
        tabBarsQuery.buttons["Bookmarks"].tap()
        let tablesQuery = app.tables.cells
        for _ in 0..<tablesQuery.count {
            tablesQuery.element(boundBy: 0).swipeLeft()
            tablesQuery.element(boundBy: 0).buttons["Delete"].tap()
        }
        tabBarsQuery.buttons["Search"].tap()
    }
    
}
