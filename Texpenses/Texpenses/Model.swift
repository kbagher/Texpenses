//
//  Model.swift
//  Texpenses
//
//  Created by Kassem Bagher on 26/9/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Model {
    
    static let sharedInstance = Model()
    
    // Get a reference to your App Delegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Hold a reference to the managed context
    let managedContext: NSManagedObjectContext
    
    private init()
    {
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Currency
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
        
        return results.count > 0
    }
    
    func getCurrencyWithCountry(code:String)->Currency?{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Currency")
        fetchRequest.predicate = NSPredicate(format: "symbol BEGINSWITH[c] %@", code)
        
        var results: [Currency] = []
        
        do {
            results = try managedContext.fetch(fetchRequest) as! [Currency]
            if results.count > 0 {
                return results[0]
            }
            return nil
        }
        catch {
            print("error executing fetch request: \(error)")
            return nil
        }
    }
    
    func deleteCurrency(withSymbol symbol:String) -> Bool  {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Currency")
        fetchRequest.predicate = NSPredicate(format: "symbol == %@", symbol)
        
        var results = [Currency]()
        
        do {
            results = try managedContext.fetch(fetchRequest) as! [Currency]
            if results.count > 0 {
                deleteCurrency(currency: results[0])
                return true
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return false
    }
    
    // MARK: CRUD operations
    func addCurrency(name:String,symbol:String) -> Bool {
        if checkIsCurrencyExistsWith(symbol: symbol) {
            return false;
        }
        
        let entity =  NSEntityDescription.entity(forEntityName: "Currency",in:managedContext)
        let currency = Currency(entity: entity!,insertInto:managedContext)
        currency.name = name
        currency.symbol = symbol
        updateDatabase();
        return true
    }
    
    func updateCurrency(currency:Currency,name:String,symbol:String){
        currency.name = name
        currency.symbol = symbol
        updateDatabase()
    }
    
    func deleteCurrency(currency: Currency){
        managedContext.delete(currency)
        updateDatabase()
    }
    
    func getCurrencies() -> [Currency]?
    {
        do
        {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Currency")
            let results = try managedContext.fetch(fetchRequest)
            if results.count == 0 {
                return nil
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
    func getPreferences() -> Preferences? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Preferences")
        fetchRequest.fetchLimit = 1
        
        var results = [Preferences]()
        
        do {
            results = try managedContext.fetch(fetchRequest) as! [Preferences]
            if results.count > 0 {
                return results[0]
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return nil
    }

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
    func addTransactionFor(Trip trip:Trip,amount:Double,title:String,latitude:Double,longitude:Double,locality:String,locationName:String) -> Bool {
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
        return true
    }
    
    func getTransactions() -> [Transaction]?
    {
        do
        {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Transaction")
            let results = try managedContext.fetch(fetchRequest)
            if results.count == 0 {
                return nil
            }
            return results as? [Transaction]
        }
        catch let error as NSError
        {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil;
    }

    
    
    // MARK: - Trips
    
    func getTripsSummaries() -> [Summary]?{
        if let trips = getTrips(){
            print(trips.count)
            var summaries = [Summary]()
            for trip in trips{
                
                var tripAmountSum = 0.0
                var baseAmountSum = 0.0
                var exchangeRateAvg = 0.0
                
                let countryName = trip.country!

                let baseCurrency = (trip.baseCurrency?.symbol)!
                let countryCurrency = (trip.currency?.symbol)!
                
                let fromDate = format(Date: trip.startDate as Date?)
                let toDate = format(Date: trip.endDate as Date?)

                if let transactions = trip.transactions?.array,transactions.count > 0  {
                    for tr in transactions{
                        let transaction = tr as! Transaction
                        tripAmountSum += transaction.amount
                        baseAmountSum += transaction.amount * transaction.exchangeRate
                        exchangeRateAvg += transaction.exchangeRate
                    }
                    tripAmountSum = formatDecimalPoints(Number: tripAmountSum)
                    baseAmountSum =  formatDecimalPoints(Number: baseAmountSum)
                    exchangeRateAvg = exchangeRateAvg / Double(transactions.count)
                }
                let summary = Summary(countryName: countryName, fromDate: fromDate!, toDate: toDate!, baseCurrency: baseCurrency, baseExpenses: String(baseAmountSum), countryCurrency: countryCurrency, countryExpenses: String(tripAmountSum), exchangeRate: String(exchangeRateAvg))
                
                summaries.append(summary)
            }
            return summaries
        }
        return nil
    }
    
    func calculateExchangeRateForCurrentTrip(Amount amount:Double ) -> Double{
        if let t = getCurrentActiveTrip(){
            let rate = t.currentExchangeRate
            return rate * amount
        }
        return 0.0
    }
    
    func getTotalExpensesFor(Trip trip:Trip) -> Double{
        if trip.transactions?.count == 0 {
            return 0.0
        }
        
        var total = 0.0
        
        for item in trip.transactions!{
            let tr = item as! Transaction
            total += tr.amount
        }
        
        return total
    }
    
    func getCurrentActiveTrip() -> Trip? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Trip")
        let sort = NSSortDescriptor(key: #keyPath(Trip.startDate), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 1
        
        var results = [Trip]()
        
        do {
            results = try managedContext.fetch(fetchRequest) as! [Trip]
            if results.count > 0 {
                if results[0].endDate == nil {
                    return results[0]
                }
                return nil
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return nil
    }
    
    func close(Trip t:Trip){
        // No transactions
        if t.transactions?.count == 0 {
            t.endDate = Date() as NSDate
            updateDatabase()
        }
        else{
            let tr = t.transactions?.lastObject as! Transaction
            t.endDate = tr.date
            updateDatabase()
        }
    }
    
    // MARK: CRUD operations
    // Add a new trip
    func addTrip(countryName:String,countryCode:String,startDate:Date,currency:Currency) -> Bool {
        if let c = getCurrentActiveTrip(), c.countryCode == countryCode{
            return false
        }
        print("IN Addgin trips")
        let entity =  NSEntityDescription.entity(forEntityName: "Trip",in:managedContext)
        let trip = Trip(entity: entity!,insertInto:managedContext)
        trip.country = countryName
        trip.currency = currency
        trip.countryCode = countryCode
        trip.startDate = startDate as NSDate
        trip.endDate = nil
        trip.baseCurrency = getPreferences()?.userCurrency
        updateDatabase()
        return true
    }
    
    
    
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
        return nil;
    }
    
    func updateTrip(_ trip:Trip, endDate d:Date){
        trip.endDate = d as NSDate;
        updateDatabase()
    }
    
    func updateTrip(_ trip:Trip, ExchangeRate rate:Double){
        trip.currentExchangeRate = rate
        updateDatabase()
    }
    
    func updateTrip(BaseCurrency trip:Trip, currency c:Currency){
        trip.baseCurrency = c
        updateDatabase()
    }
    
    func getCurrencySymbolFor(CurrencyCode c:String) -> String{
        let localeGBP = Locale
            .availableIdentifiers
            .map { Locale(identifier: $0) }
            .first { $0.currencyCode == c }
        return (localeGBP?.currencySymbol)!
    }
    func delete(Trip t:Trip) {
        managedContext.delete(t)
        updateDatabase()
    }
    
    // MARK: - Helping methods
    func format(Date date:Date?) -> String?{
        if let d = date{
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: d)
        }
        return "N/A"
    }

    func formatDecimalPoints(Number n:Double) -> Double{
        return Double(round(100 * n)/100)
    }
    
    func format(Time time:Date?) -> String?{
        if let t = time{
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.pmSymbol = "PM"
            formatter.amSymbol = "AM"
            return formatter.string(from: t)
        }
        return "N/A"
    }
    
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
