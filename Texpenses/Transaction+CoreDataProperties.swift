//
//  Transaction+CoreDataProperties.swift
//  Texpenses
//
//  Created by Kassem Bagher on 26/9/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var title: String?
    @NSManaged public var amount: Double
    @NSManaged public var trip: Trip?

}
