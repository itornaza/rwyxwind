//
//  RwyXwindUITests.swift
//  RwyXwindUITests
//
//  Created by Ioannis Tornazakis on 21/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import XCTest

/**
 * The tests are shall be run only against the iPhone 11 Pro Max simulator to take into account the proper screen
 * coordinates, see the function prepareKeyboad at the end of this file
 */
class RwyXwindUITests: XCTestCase {
    
    // MARK: - Properties
    
    let app = XCUIApplication()
    let delay: UInt32 = 4
    
    // String literals
    let testAirport: String = "LGKV (KVA): Kavala International Airport, \"Megas Alexandros\""
    let testAirportBookmark = "LGKV (KVA) 36: Kavala International Airport, \"Megas Alexandros\""
    let testAirportAlert = "Kavala International Airport, \"Megas Alexandros\", RWY: 36"
    let airportServiceError = "Airport service error"
    let iataError = "IATA code is not available"
    let icaoError = "ICAO code is not available"
    let latError = "Airport latitude is not available"
    let calculate = "Calculate crosswind"
    let rtn = "Return"
    let invalid = "Invalid input"
    let ok = "OK"
    let add = "Add"
    let bookmarks = "Bookmarks"
    let alreadyBookmark = "Already in bookmarks"
    let delete = "Delete"
    let search = "Search"
    let noInputAlert = "Please, input IATA or ICAO code to continue"
    let invalidInputAlert = "Input 3 letters for IATA or 4 letters for ICAO"
    let rwyHeadingAlert = "Runway heading shall be from 000 to 360 degrees"
    
    // MARK: - Configuration
    
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
    
    // MARK: - Tests
    
    func test_invalidLetterCode() {
        // No input
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.noInputAlert].exists)
        app.alerts[self.invalid].buttons[self.ok].tap()
        
        // One letter input
        self.prepareKeyboard()
        app.keys["K"].tap()
        app.buttons[self.rtn].tap()
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.airportServiceError].exists)
        app.alerts[self.airportServiceError].buttons[self.ok].tap()
        
        // Two letter input
        self.prepareKeyboard()
        app.keys["V"].tap()
        app.buttons[self.rtn].tap()
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.airportServiceError].exists)
        app.alerts[self.airportServiceError].buttons[self.ok].tap()
    }
    
    func test_validIATA() {
        self.inputValidIATA()
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.testAirport].exists)
    }
    
    func test_invalidIATA() {
        self.inputInvaldIATA()
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.airportServiceError].exists)
        XCTAssertTrue(app.staticTexts[self.icaoError].exists)
        app.alerts[self.airportServiceError].buttons[self.ok].tap()
    }
    
    func test_validIATAButNoAirportData() {
        self.inputValidIATAButNoAirportData()
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.airportServiceError].exists)
        XCTAssertTrue(app.staticTexts[self.latError].exists)
        app.alerts[self.airportServiceError].buttons[self.ok].tap()
    }
    
    func test_validICAO() {
        self.inputValidICAO()
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.testAirport].exists)
    }
    
    func test_invalidICAO() {
        self.inputInvalidICAO()
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.airportServiceError].exists)
        XCTAssertTrue(app.staticTexts[self.iataError].exists)
        app.alerts[self.airportServiceError].buttons[self.ok].tap()
    }
    
    func test_validICAOButNoAirportData() {
        self.inputValidICAOButNoAirportData()
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.airportServiceError].exists)
        XCTAssertTrue(app.staticTexts[self.latError].exists)
        app.alerts[self.airportServiceError].buttons[self.ok].tap()
    }
    
    func test_validPicker() {
        self.inputValidIATA()
        self.pickerSetUp(first: "2", second: "1", third: "3")
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["21"].exists)
    }
    
    func test_validPcker360() {
        self.inputValidIATA()
        self.pickerSetUp(first: "0", second: "0", third: "0")
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["36"].exists)
    }
    
    func test_overflowPickerSecondDigit() {
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "3")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "8")
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.rwyHeadingAlert].exists)
        app.alerts[self.invalid].buttons[self.ok].tap()
    }
    
    func test_overflowPickerThirdDigit() {
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "3")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "6")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "1")
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.rwyHeadingAlert].exists)
        app.alerts[self.invalid].buttons[self.ok].tap()
    }
    
    func test_addBookmark() {
        self.addBookmark()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.tables.staticTexts[self.testAirportBookmark].exists)
    }
    
    func test_alreadyBookmark() {
        self.addBookmark()
        app.tables.staticTexts[self.testAirportBookmark].tap()
        let toolbarsQuery = app.toolbars
        toolbarsQuery.buttons[self.add].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.alreadyBookmark].exists)
        app.alerts[self.testAirportAlert].buttons[self.ok].tap()
    }
    
    func test_windFromBookmark() {
        self.addBookmark()
        app.tables.staticTexts[self.testAirportBookmark].tap()
        sleep(self.delay) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts[self.testAirport].exists)
    }
    
    func test_removeBookmark() {
        self.addBookmark()
        let tablesQuery = app.tables.cells
        tablesQuery.element(boundBy: 0).swipeLeft()
        tablesQuery.element(boundBy: 0).buttons[self.delete].tap()
        sleep(self.delay) // Allow time for action to complete
        XCTAssertEqual(tablesQuery.count, 0)
    }
    
    // MARK: - Helpers
    
    func inputIATA(first: String, second: String, third: String) {
        self.prepareKeyboard()
        app.keys[first].tap()
        app.keys[second].tap()
        app.keys[third].tap()
        app.buttons[self.rtn].tap()
    }
    
    func inputValidIATA() {
        self.inputIATA(first: "K", second: "V", third: "A")
    }
    
    func inputInvaldIATA() {
        self.inputIATA(first: "Z", second: "Z", third: "Z")
    }
    
    func inputValidIATAButNoAirportData() {
        self.inputIATA(first: "S", second: "F", third: "I")
    }
    
    func inputICAO(first: String, second: String, third: String, forth: String) {
        self.prepareKeyboard()
        app.keys[first].tap()
        app.keys[second].tap()
        app.keys[third].tap()
        app.keys[forth].tap()
        app.buttons[self.rtn].tap()
    }
    
    func inputValidICAO() {
        self.inputICAO(first: "L", second: "G", third: "K", forth: "V")
    }
    
    func inputInvalidICAO() {
        self.inputICAO(first: "Z", second: "Z", third: "Z", forth: "Z")
    }
    
    func inputValidICAOButNoAirportData() {
        self.inputICAO(first: "G", second: "M", third: "M", forth: "S")
    }
    
    func pickerSetUp(first: String, second: String, third: String) {
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: first)
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: second)
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: third)
    }
    
    func addBookmark() {
        self.inputValidIATA()
        app.buttons[self.calculate].tap()
        sleep(self.delay) // Allow time for the transition to complete
        let toolbarsQuery = app.toolbars
        toolbarsQuery.buttons[self.add].tap()
        app.alerts[self.testAirportAlert].buttons[self.ok].tap()
        toolbarsQuery.buttons[self.bookmarks].tap()
    }
    
    func clearBookmarks() {
        let tabBarsQuery = XCUIApplication().tabBars
        tabBarsQuery.buttons[self.bookmarks].tap()
        let tablesQuery = app.tables.cells
        for _ in 0..<tablesQuery.count {
            tablesQuery.element(boundBy: 0).swipeLeft()
            tablesQuery.element(boundBy: 0).buttons[self.delete].tap()
        }
        tabBarsQuery.buttons[self.search].tap()
    }
    
    /// Specific for iPhone 11 pro max
    func prepareKeyboard() {
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element.tap()
    }
}
