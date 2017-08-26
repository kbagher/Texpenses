//
//  File.swift
//  Texpenses
//
//  Created by Kassem Bagher on 24/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
class Currency: NSObject {
    var countryName:String = ""
    var currency:String = ""
    private var currencies:[Currency] = [Currency]()
    
    override init() {
        super.init()
        // TODO: retrieve from the APi and store it in the database
        // Here....
        
        currencies = getDummyData()
    }
    
    init(countryName:String,currency:String) {
        self.countryName = countryName
        self.currency = currency
    }
    
    func getCurrencyWith(symbol s:String) -> Currency? {
        
        for c in currencies {
            if c.currency == s {
                return c
            }
        }
        
        return nil
    }
    
    
    func getAvailableCurrencies() -> [Currency] {
        return currencies
    }
    
    func getDummyData() -> [Currency] {
        var data = [Currency]()
        
        data.append(Currency(countryName: "Saudi Riyal", currency: "SAR"))
        data.append(Currency(countryName: "Australian Dollar", currency: "AUD"))
        data.append(Currency(countryName: "Brazilian Real", currency: "BRL"))
        data.append(Currency(countryName: "Egyptian Pound", currency: "EGP"))
        data.append(Currency(countryName: "American Dollar", currency: "USD"))
        
        return data
    }
    
}
