//
//  Currency+CoreDataProperties.swift
//  Texpenses
//
//  Created by Kassem Bagher on 27/9/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
import CoreData


extension Currency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Currency> {
        return NSFetchRequest<Currency>(entityName: "Currency")
    }

    @NSManaged public var name: String?
    @NSManaged public var symbol: String?
    @NSManaged public var trips: NSSet?

}

// MARK: Generated accessors for trips
extension Currency {

    @objc(addTripsObject:)
    @NSManaged public func addToTrips(_ value: Trip)

    @objc(removeTripsObject:)
    @NSManaged public func removeFromTrips(_ value: Trip)

    @objc(addTrips:)
    @NSManaged public func addToTrips(_ values: NSSet)

    @objc(removeTrips:)
    @NSManaged public func removeFromTrips(_ values: NSSet)

}
