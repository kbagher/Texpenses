//
//  Trip+CoreDataProperties.swift
//  Texpenses
//
//  Created by Kassem Bagher on 26/9/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
import CoreData


extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var country: String?
    @NSManaged public var name: String?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var endDate: NSDate?
    @NSManaged public var transactions: NSSet?
    @NSManaged public var currency: Currency?

}

// MARK: Generated accessors for transactions
extension Trip {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}
