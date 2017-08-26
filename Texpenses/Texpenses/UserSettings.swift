//
//  UserSettings.swift
//  Texpenses
//
//  Created by Kassem Bagher on 26/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
class UserSettings: NSObject {
    
    var currency:Currency = Currency()
    
    static let sharedInstance = UserSettings()
    
    
    override init() {}
    
    func replaceBaseCurrencyWith(currency c:Currency) {
        currency = c
    }
    
    func getBaseCurrency() -> Currency? {
        if currency.countryName.isEmpty {
            if let c = Currency.init().getCurrencyWith(symbol: "USD") {
                currency = c
                return currency
            }
            return nil
        }
        return currency
    }
    
}
