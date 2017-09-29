//
//  Preferences+CoreDataProperties.swift
//  Texpenses
//
//  Created by Kassem Bagher on 28/9/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
import CoreData


extension Preferences {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Preferences> {
        return NSFetchRequest<Preferences>(entityName: "Preferences")
    }

    @NSManaged public var userCurrency: Currency?

}
