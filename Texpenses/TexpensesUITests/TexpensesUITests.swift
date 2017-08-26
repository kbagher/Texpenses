//
//  TexpensesUITests.swift
//  TexpensesUITests
//
//  Created by Kassem Bagher on 26/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import XCTest

class TexpensesUITests: XCTestCase {
        
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
    
    // check if changing currency is reflected in the app settings view
    func testSettingsChanggeCurrency() {
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        
        let t = app.tables
        t.staticTexts["USD"].tap()
        t.staticTexts["Saudi Riyal (SAR)"].tap()
        XCTAssert(t.staticTexts["SAR"].exists)
    }
    
    // check if the transaction details is changed related to the tapped transaction
    func testTransactionDetails() {
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        app.tabBars.buttons["Transactions"].tap()
        app.tables.staticTexts["Chips Snacks"].tap()
        XCTAssert(app.tables.staticTexts["Chips Snacks"].exists)
    }
    
    // Check if exchage rate is calculated correctly
    func testDashboardExchangeRate() {
        XCUIDevice.shared().orientation = .portrait
        let textField = XCUIApplication().textFields["1"]
        textField.tap()
        textField.typeText("100")
        XCTAssert(XCUIApplication().staticTexts["79.0"].exists)
    }
    
    /* 
     check if the currency textfield and result label
     are both visible and not hidden by the keyboard
     */
    func testDashboardTextFieldsVisibility() {
        XCUIDevice.shared().orientation = .portrait
        let textField = XCUIApplication().textFields["1"]
        textField.tap()
        XCTAssert(textField.isHittable)
        
        let rate = XCUIApplication().staticTexts["0.79"]
        XCTAssert(rate.isHittable)
    }
    
}
