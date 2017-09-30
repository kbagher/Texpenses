//
//  Transaction+CoreDataProperties.swift
//  Texpenses
//
//  Created by Kassem Bagher on 30/9/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: Double
    @NSManaged public var date: NSDate?
    @NSManaged public var exchangeRate: Double
    @NSManaged public var latitude: Double
    @NSManaged public var locality: String?
    @NSManaged public var locationName: String?
    @NSManaged public var longitude: Double
    @NSManaged public var title: String?
    @NSManaged public var trip: Trip?

}
