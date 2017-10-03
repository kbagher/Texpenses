//
//  Model.swift
//  Texpenses
//
//  Created by Khaled Dowaid on 26/9/17.
//  Copyright © 2017 Khaled Dowaid. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Model {
    
    // MARK: - Class Variables
    static let sharedInstance = Model()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext: NSManagedObjectContext
    
    // Singleton design pattern
    private init()
    {
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Currency
    
    
    /// Check if currency exists in database
    ///
    /// - Parameter symbol: Currency Symbol (SAR, USD, AUD, etc...)
    /// - Returns: True if the dpecified currency exists
    func checkIsCurrencyExistsWith(symbol: String) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Currency")
        fetchRequest.predicate = NSPredicate(format: "symbol == %@", symbol)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        // true if results available
        return results.count > 0
    }
    
    
    /// Gets Currency object based on the specified symbol
    ///
    /// - Parameter code: Currency Symbol (SAR, USD, AUD, etc...)
    /// - Returns: currency object for the given symbol
    func getCurrencyWithCountry(code:String)->Currency?{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Currency")
        fetchRequest.predicate = NSPredicate(format: "symbol BEGINSWITH[c] %@", code)
        
        var results: [Currency] = []
        
        do {
            results = try managedContext.fetch(fetchRequest) as! [Currency]
            if results.count > 0 {
                // return first result
                return results[0]
            }
            return nil // no result
        }
        catch {
            print("error executing fetch request: \(error)")
            return nil
        }
    }
    
    // MARK: CRUD operations
    
    
    /// Add new currency to the database
    ///
    /// - Parameters:
    ///   - name: Currency name (i.e. Australian Dollar)
    ///   - symbol: Currency Symbol (i.e. AUD)
    func addCurrency(name:String,symbol:String) {
        
        if checkIsCurrencyExistsWith(symbol: symbol) {
            return // currency already exists in the database
        }
        
        // Add the cyrrency to the database
        let entity =  NSEntityDescription.entity(forEntityName: "Currency",in:managedContext)
        let currency = Currency(entity: entity!,insertInto:managedContext)
        currency.name = name
        currency.symbol = symbol
        
        updateDatabase();
    }
    
    
    /// Get All currencies
    ///
    /// - Returns: Array of all available currencies
    func getCurrencies() -> [Currency]?
    {
        do
        {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Currency")
            let results = try managedContext.fetch(fetchRequest)
            if results.count == 0 {
                return nil // no currencies available
            }
            return results as? [Currency]
        }
        catch let error as NSError
        {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil;
    }
    
    // MARK: - Preferences
    
    /// Get user's preferences
    ///
    /// - Returns: object of user's preferences
    func getPreferences() -> Preferences? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Preferences")
        fetchRequest.fetchLimit = 1
        
        var results = [Preferences]()
        
        do {
            results = try managedContext.fetch(fetchRequest) as! [Preferences]
            if results.count > 0 {
                return results[0] // has preferences
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return nil // no preferences or error occured
    }
    
    
    /// Update user's base currency preferences
    ///
    /// If no preferences available, a new record will be added
    /// - Parameter currency: New base currency
    func updatePreferenceWith(BaseCurrency currency:Currency) {
        if let pref = getPreferences(){
            pref.userCurrency = currency
        }
        else{
            let entity =  NSEntityDescription.entity(forEntityName: "Preferences",in:managedContext)
            let pref = Preferences(entity: entity!,insertInto:managedContext)
            pref.userCurrency = currency
        }
        updateDatabase()
    }
    
    // MARK: - Transactions
    // MARK: CRUD operations
    
    
    /// Add new transaction (Expense)
    ///
    /// - Parameters:
    ///   - trip: Transaction's trip
    ///   - amount: expense amount
    ///   - title: expense title
    ///   - latitude: expense coordinate (latitude)
    ///   - longitude: expense coordinate (longitude)
    ///   - locality: expense locality (city)
    ///   - locationName: expense location name
    func addTransactionFor(Trip trip:Trip,amount:Double,title:String,latitude:Double,longitude:Double,locality:String,locationName:String)  {
        print("Adding transaction")
        let entity =  NSEntityDescription.entity(forEntityName: "Transaction",in:managedContext)
        let transaction = Transaction(entity: entity!,insertInto:managedContext)
        transaction.amount = amount
        transaction.title = title
        transaction.latitude = latitude
        transaction.longitude = longitude
        transaction.locality = locality
        transaction.locationName = locationName
        transaction.date = Date() as NSDate
        transaction.exchangeRate = trip.currentExchangeRate
        transaction.trip = trip
        trip.addToTransactions(transaction)
        updateDatabase()
    }
    
    /// Delete a transaction
    ///
    /// - Parameter t: transaction object to be deleted
    func deleteTransaction(_ t:Transaction){
        managedContext.delete(t)
        updateDatabase()
    }
    
    // MARK: - Trips
    
    
    /// Gets summaries of all trips
    ///
    /// - Returns: Array of trips's Summary
    func getTripsSummaries() -> [Summary]?{
        if let trips = getTrips(){ // retrieve all trips

            var summaries = [Summary]()
            
            // Summarise each trip
            for trip in trips{
                
                // trip's total expenses
                var tripAmountSum = 0.0
                var baseAmountSum = 0.0
                
                // trip's average exhcnage rate
                var exchangeRateAvg = 0.0
                
                // country and currency information
                let countryName = trip.country!
                let baseCurrency = (trip.baseCurrency?.symbol)!
                let countryCurrency = (trip.currency?.symbol)!
                
                // trip's date formatted in dd/MM/yyyy
                let fromDate = format(Date: trip.startDate as Date?)
                // trip's time formatted in hh:MM PM/AM
                let toDate = format(Date: trip.endDate as Date?)
                
                /* 
                 Iterate trhough all available transactions to calculate
                 total base curency expenses, countrie's expenses and average exhange rate
                */
                if let transactions = trip.transactions?.array,transactions.count > 0  {
                    for tr in transactions{
                        let transaction = tr as! Transaction
                        tripAmountSum += transaction.amount
                        baseAmountSum += transaction.amount * transaction.exchangeRate
                        exchangeRateAvg += transaction.exchangeRate
                    }
                    // format decimal points display 2 numbers only (.00)
                    tripAmountSum = formatDecimalPoints(Number: tripAmountSum)
                    baseAmountSum =  formatDecimalPoints(Number: baseAmountSum)
                    exchangeRateAvg = exchangeRateAvg / Double(transactions.count)
                }
                // define new summary object passing the summaries data
                let summary = Summary(countryName: countryName, fromDate: fromDate!, toDate: toDate!, baseCurrency: baseCurrency, baseExpenses: String(baseAmountSum), countryCurrency: countryCurrency, countryExpenses: String(tripAmountSum), exchangeRate: String(exchangeRateAvg))
                
                // add the summaries trip to the array
                summaries.append(summary)
            }
            return summaries // returns either 0 or many objects
        }
        return nil // no trips
    }
    
    
    /// Calculates the exchange rate for current trip based on the 
    /// given amount
    ///
    /// This method will use the currency of the current trip to calculate the
    /// exchange rate based on the passed amount
    /// - Parameter amount: amount
    /// - Returns: calculated exhcnage rate
    func calculateExchangeRateForCurrentTrip(Amount amount:Double ) -> Double{
        if let t = getCurrentActiveTrip(){
            let rate = t.currentExchangeRate
            return rate * amount
        }
        return 0.0 // no curent active trip
    }
    
    
    /// Gets total expenses amount for a trip
    ///
    /// - Parameter trip: trip object
    /// - Returns: total expenses in trip's currency
    func getTotalExpensesFor(Trip trip:Trip) -> Double{

        if trip.transactions?.count == 0 {
            return 0.0 // no expenses
        }
        
        var total = 0.0
        
        // calculate total expenses amount
        for item in trip.transactions!{
            let tr = item as! Transaction
            total += tr.amount
        }
        
        return total
    }
    
    
    /// Gets the current active trip
    ///
    /// The active trips depends on the trip's endDate. If the trip has an end date
    /// it means it's not active.
    /// - Returns: trip object if available
    func getCurrentActiveTrip() -> Trip? {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Trip")
        let sort = NSSortDescriptor(key: #keyPath(Trip.startDate), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 1
        
        var results = [Trip]()
        
        do {
            results = try managedContext.fetch(fetchRequest) as! [Trip]
            if results.count > 0 { // trips available
                if results[0].endDate == nil {
                    return results[0] // latest trip is active
                }
                return nil // latest trip is not active
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return nil // no trips available
    }
    
    
    /// Close current active trip
    ///
    /// This will update the trip's endDate
    /// - Parameter t: trip to be closed
    func close(Trip t:Trip){
        
        if t.transactions?.count == 0 {
            /*
             Trip has no transactions, the trip endDate will be set to the
             current system date
             */
            t.endDate = Date() as NSDate
            updateDatabase()
        }
        else{
            /*
             Trip has transactions, the trip endDate will be set to the
             latest available transaction's date
             */
            let tr = t.transactions?.lastObject as! Transaction
            t.endDate = tr.date
            updateDatabase()
        }
    }
    
    // MARK: CRUD operations
    // Add a new trip
    
    
    /// Crates a new trip
    ///
    /// - Parameters:
    ///   - countryName: country's name
    ///   - countryCode: country's iso code (AU, SA, US, etc...)
    ///   - startDate: trip start date
    ///   - currency: trip's currency
    func addTrip(countryName:String,countryCode:String,startDate:Date,currency:Currency){
        if let c = getCurrentActiveTrip(), c.countryCode == countryCode{
            // avoid adding the same active trip
            return
        }

        let entity =  NSEntityDescription.entity(forEntityName: "Trip",in:managedContext)
        let trip = Trip(entity: entity!,insertInto:managedContext)
        trip.country = countryName
        trip.currency = currency
        trip.countryCode = countryCode
        trip.startDate = startDate as NSDate
        trip.endDate = nil
        trip.baseCurrency = getPreferences()?.userCurrency
        updateDatabase()
    }
    
    
    
    /// Get all trips
    ///
    /// - Returns: all available trips
    func getTrips() -> [Trip]?
    {
        do
        {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Trip")
            
            let results = try managedContext.fetch(fetchRequest)
            return results as? [Trip]
        }
        catch let error as NSError
        {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil // error occured
    }
    
    
    /// Update trip's end date
    ///
    /// - Parameters:
    ///   - trip: trip to be updated
    ///   - d: trip's new end date
    func updateTrip(_ trip:Trip, endDate d:Date){
        trip.endDate = d as NSDate;
        updateDatabase()
    }
    
    
    /// Update trip's exchange date
    ///
    /// - Parameters:
    ///   - trip: trip to be updated
    ///   - rate: new exchange rate based on user's base currency
    func updateTrip(_ trip:Trip, ExchangeRate rate:Double){
        trip.currentExchangeRate = rate
        updateDatabase()
    }
    
    
    /// Update trip's currency
    ///
    /// - Parameters:
    ///   - trip: trip to be updated
    ///   - c: new trip's currency
    func updateTrip(BaseCurrency trip:Trip, currency c:Currency){
        trip.baseCurrency = c
        updateDatabase()
    }
    
    
    /// Gets the currency's symbol (i.e $)
    ///
    /// - Parameter c: currency
    /// - Returns: represented symbol
    func getCurrencySymbolFor(CurrencyCode c:String) -> String{
        let lo = Locale
            .availableIdentifiers
            .map { Locale(identifier: $0) }
            .first { $0.currencyCode == c }
        return (lo?.currencySymbol)!
    }

    
    // MARK: - Helping methods
    
    
    /// Format provided date into dd/MM/yyy
    ///
    /// - Parameter date: date to be formated
    /// - Returns: formated date if available
    func format(Date date:Date?) -> String?{
        if let d = date{
            // provide date is not nil
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: d)
        }
        return "N/A" // no data available
    }
    
    
    /// Format decimal point into 2 digits (.00)
    ///
    /// - Parameter n: number to be formated
    /// - Returns: formatted number
    func formatDecimalPoints(Number n:Double) -> Double{
        return Double(round(100 * n)/100)
    }
    
    
    /// Format provide time into hh:MM PM/AM
    ///
    /// - Parameter time: time to be formated
    /// - Returns: formatted time
    func format(Time time:Date?) -> String?{
        if let t = time{
            // provided time is not nil
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.pmSymbol = "PM"
            formatter.amSymbol = "AM"
            return formatter.string(from: t)
        }
        return "N/A" // no time available
    }
    
    
    /// Save changes to local database
    private func updateDatabase()
    {
        do
        {
            try managedContext.save()
        }
        catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
}
