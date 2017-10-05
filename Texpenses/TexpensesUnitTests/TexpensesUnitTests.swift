//
//  TexpensesUnitTests.swift
//  TexpensesUnitTests
//
//  Created by Kassem Bagher on 4/10/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import XCTest
@testable import Texpenses

class TexpensesUnitTests: XCTestCase {
    
    let model =  Model.sharedInstance
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// Test adding a currency which already exixts
    ///
    /// Business logic: There should not be two similar currencies in the app
    func testAddingCurrencyAlreadyExists(){
        /* 
         App should have currencies in the database.
         To fill the database for testing:
         1- run the app
         2- Authorise the app to use location service
         3- Wait for the "Optimising App Data" view to finish successfully
         4- Terminate the app
         5- Run the test
         */
        precondition(model.getCurrencies() != nil)
        // grap a currency from the database (we used Australian dollar for the test)
        let currency = model.getCurrencyWithCountry(code: "AU")
        // Add the same currency to the database
        let response = model.addCurrency(name: (currency?.name)!, symbol: (currency?.symbol)!)
        // The app should not add the same currency twice
        XCTAssertFalse(response)
    }
    
    /// Adding transaction while there is no active trip
    ///
    /// Business logic: The user should only be able to add expesnes if he has an active trip
    func testAddingTransaction(){
        /*
         The user should have an active trip
         to create and active trip for testing:
         1- run the app
         2- Authorise the app to use location service
         3- Wait for the "Optimising App Data" view to finish successfully
         4- Select base currency from settings
         5- Go back to the dashboard
         6- tap on "Yes" in the "Create new trip" message
         7- Wait for the "Optimising Exchange Rate" view to finish successfully
         8- Terminate the app
         9- Run the test
         */
        precondition(model.getCurrentActiveTrip() != nil)
        // Grap the current active trip
        let trip = (model.getCurrentActiveTrip())!;
        // Add a testing transaction to the trip
        let response = model.addTransactionFor(Trip: trip, amount: 2.0, title: "Testing", latitude: -37.737616, longitude: 144.995703, locality: "Preston", locationName: "Preston West Primary School")
        // The app should add the transaction successfully
        XCTAssertTrue(response)
    }
    
    
    /// Adding a trip twice
    ///
    /// This will test adding a trip similar (Same location) to the current active trip.
    ///
    /// Business logic: A similar new trip should not be created unless the previous one is closed
    func testDuplicatingTrip(){
        /*
         The user should have an active trip
         to create and active trip for testing:
         1- run the app
         2- Authorise the app to use location service
         3- Wait for the "Optimising App Data" view to finish successfully
         4- Select base currency from settings
         5- Go back to the dashboard
         6- tap on "Yes" in the "Create new trip" message
         7- Wait for the "Optimising Exchange Rate" view to finish successfully
         8- Terminate the app
         9- Run the test
         */
        precondition(model.getCurrentActiveTrip() != nil)
        // Grap the currenct active trip
        let trip = (model.getCurrentActiveTrip())!
        // Add the trip
        let response = model.addTrip(countryName: trip.country!, countryCode: trip.countryCode!, startDate: Date(), currency: trip.currency!)
        // App should not add a similar trip to the current active one in the database
        XCTAssertFalse(response)
    }
    
    
    
}
