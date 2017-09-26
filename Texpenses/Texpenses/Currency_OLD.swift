//
//  File.swift
//  Texpenses
//
//  Created by Kassem Bagher on 24/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
class Currency_OLD: NSObject {
    var countryName:String = ""
    var currency:String = ""
    var rate:Double = 0.79
    private var currencies:[Currency_OLD] = [Currency_OLD]()
    
    override init() {
        super.init()
        // TODO: retrieve from the APi and store it in the database
        // Here....
        
        currencies = getDummyData()
    }
    
    init(countryName:String,currency:String,rate:Double) {
        self.countryName = countryName
        self.currency = currency
        self.rate = rate
    }
    
    func getCurrencyWith(symbol s:String) -> Currency_OLD? {
        
        for c in currencies {
            if c.currency == s {
                return c
            }
        }
        
        return nil
    }
    
    func calculateExchangeRateFromBaseWith(currency c:Currency_OLD,amount: Double) -> Double {
        // TODO: logic need to be completed
        return amount * c.rate
    }
    
    func getAvailableCurrencies() -> [Currency_OLD] {
        return currencies
    }
    
    func getDummyData() -> [Currency_OLD] {
        var data = [Currency_OLD]()
        
        data.append(Currency_OLD(countryName: "Saudi Riyal", currency: "SAR",rate: 0.27))
        data.append(Currency_OLD(countryName: "Australian Dollar", currency: "AUD",rate: 0.79))
        data.append(Currency_OLD(countryName: "Brazilian Real", currency: "BRL",rate: 0.32))
        data.append(Currency_OLD(countryName: "Egyptian Pound", currency: "EGP",rate: 0.056))
        data.append(Currency_OLD(countryName: "American Dollar", currency: "USD",rate: 1))
        
        return data
    }
    
}
