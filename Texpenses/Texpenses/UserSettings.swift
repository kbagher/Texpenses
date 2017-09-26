//
//  UserSettings.swift
//  Texpenses
//
//  Created by Kassem Bagher on 26/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
class UserSettings: NSObject {
    
    var currency:Currency_OLD = Currency_OLD()
    
    static let sharedInstance = UserSettings()
    
    
    override init() {}
    
    func replaceBaseCurrencyWith(currency c:Currency_OLD) {
        currency = c
    }
    
    func getBaseCurrency() -> Currency_OLD? {
        if currency.countryName.isEmpty {
            if let c = Currency_OLD.init().getCurrencyWith(symbol: "USD") {
                currency = c
                return currency
            }
            return nil
        }
        return currency
    }
    
}
