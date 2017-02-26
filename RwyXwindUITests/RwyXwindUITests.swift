//
//  RwyXwindUITests.swift
//  RwyXwindUITests
//
//  Created by Ioannis Tornazakis on 21/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import XCTest

class RwyXwindUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //---------------------
    // MARK: - Tests
    //---------------------
    
    
    // TODO: Tests shall be able to run at any sequence
    
    
    func test_0_clearBookmarks() {
        let app = XCUIApplication()
        let tabBarsQuery = XCUIApplication().tabBars
        tabBarsQuery.buttons["Bookmarks"].tap()
        let tablesQuery = app.tables.cells
        for _ in 0..<tablesQuery.count {
            tablesQuery.element(boundBy: 0).swipeLeft()
            tablesQuery.element(boundBy: 0).buttons["Delete"].tap()
        }
    }
    
    func test_1_validIATA() {
        let app = XCUIApplication()
        self.inputValidIATA()
        sleep(4) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["KVA: Megas Alexandros Intl"].exists)
    }
    
    func test_2_addBookmark() {
        let app = XCUIApplication()
        self.inputValidIATA()
        let toolbarsQuery = app.toolbars
        toolbarsQuery.buttons["Add"].tap()
        app.alerts["Megas Alexandros Intl, RWY: 36"].buttons["OK"].tap()
        toolbarsQuery.buttons["Bookmarks"].tap()
        XCTAssertTrue(app.tables.staticTexts["KVA rwy 36: Megas Alexandros Intl"].exists)
    }
    
    func test_3_windFromBookmark() {
        let app = XCUIApplication()
        XCUIApplication().tabBars.buttons["Bookmarks"].tap()
        app.tables.staticTexts["KVA rwy 36: Megas Alexandros Intl"].tap()
        sleep(4) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["KVA: Megas Alexandros Intl"].exists)
    }
    
    func test_4_removeBookmark() {
        let app = XCUIApplication()
        XCUIApplication().tabBars.buttons["Bookmarks"].tap()
        let tablesQuery = app.tables.cells
        tablesQuery.element(boundBy: 0).swipeLeft()
        tablesQuery.element(boundBy: 0).buttons["Delete"].tap()
        XCTAssertEqual(tablesQuery.count, 0)
    }
    
    func test_5_validICAO() {
        let app = XCUIApplication()
        self.inputValidICAO()
        sleep(4) // Allow time for the transition to complete
        XCTAssertTrue(app.staticTexts["LGKV: Megas Alexandros Intl"].exists)
    }
    
    //---------------------
    // MARK: - Helpers
    //---------------------
    
    func inputValidIATA() {
        let app = XCUIApplication()
        let textField = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element
        textField.tap()
        app.keys["K"].tap()
        app.keys["V"].tap()
        app.keys["A"].tap()
        app.buttons["Return"].tap()
        app.buttons["Calculate crosswind"].tap()
    }
    
    func inputValidICAO() {
        let app = XCUIApplication()
        let textField = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element
        textField.tap()
        app.keys["L"].tap()
        app.keys["G"].tap()
        app.keys["K"].tap()
        app.keys["V"].tap()
        app.buttons["Return"].tap()
        app.buttons["Calculate crosswind"].tap()
    }
}
