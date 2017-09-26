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

    // MARK: - Currency CRUD operations
    func addCurrency(name:String,symbol:String,rate: Double) -> Bool {
        let entity =  NSEntityDescription.entity(forEntityName: "Currency",in:managedContext)
        let currency = Currency(entity: entity!,insertInto:managedContext)
        currency.name = name
        currency.symbol = symbol
        currency.rate = rate
        return true
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

    // MARK: - Trips CRUD operations
    
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
