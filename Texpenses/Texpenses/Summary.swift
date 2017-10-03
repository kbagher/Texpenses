//
//  Summary.swift
//  Texpenses
//
//  Created by Kassem Bagher on 24/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//


import Foundation

/// This class will hold trips summary data
class Summary: NSObject{
    
    // MARK: - Class Variables
    var countryName:String = ""
    var fromDate:String = ""
    var toDate:String = ""
    var baseCurrency:String = ""
    var baseExpenses:String = ""
    var countryCurrency:String = ""
    var countryExpenses:String = ""
    var exchangeRate:String = ""
    
    override init() {
        super.init()
    }
    
    
    /// Initialise object with passed data
    ///
    /// - Parameters:
    ///   - countryName: trip country name
    ///   - fromDate: trip start date
    ///   - toDate: trip end date
    ///   - baseCurrency: user's base currency
    ///   - baseExpenses: trip expenses in base currency
    ///   - countryCurrency: trip country's currency
    ///   - countryExpenses: trip expenses in country's currency
    ///   - exchangeRate: exhange average exchange rate for thr trip
    init(countryName:String,fromDate:String,toDate:String,baseCurrency:String,baseExpenses:String,countryCurrency:String,countryExpenses:String,exchangeRate:String) {
        self.countryName = countryName
        self.baseCurrency = baseCurrency
        self.baseExpenses = baseExpenses
        self.countryCurrency = countryCurrency
        self.countryExpenses = countryExpenses
        self.fromDate = fromDate
        self.toDate = toDate
        self.exchangeRate = exchangeRate
        
    }
}
