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
            return results as? [Currency]
        }
        catch let error as NSError
        {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil;
    }

    // MARK: - Trips
    
    // MARK: CRUD operations
    // Add a new trip
    func addTrip(countryName:String,startDate:Date,currency:Currency) -> Bool {
        let entity =  NSEntityDescription.entity(forEntityName: "Trip",in:managedContext)
        let trip = Trip(entity: entity!,insertInto:managedContext)
        trip.name = countryName
        trip.currency = currency
        trip.startDate = startDate as NSDate
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

    
    // MARK: - Helping methods
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
