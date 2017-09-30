//
//  Summary.swift
//  Texpenses
//
//  Created by Kassem Bagher on 24/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
    class Summary: NSObject{
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
