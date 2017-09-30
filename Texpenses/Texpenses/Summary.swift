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
    
    func getDummyData() -> [Summary] {
        var data = [Summary]()
        
        data.append(Summary.init(countryName: "Australia", fromDate: "20/10/2017", toDate: "29/10/2017", baseCurrency: "USD", baseExpenses: "1,922.35", countryCurrency: "AUD", countryExpenses: "2,500.00", exchangeRate: "0.79"))
        
        data.append(Summary.init(countryName: "Germany", fromDate: "07/01/2016", toDate: "12/01/2016", baseCurrency: "USD", baseExpenses: "1,246.00", countryCurrency: "EUR", countryExpenses: "1,200.00", exchangeRate: "1.19"))
        
        data.append(Summary.init(countryName: "Saudi Arabia", fromDate: "01/10/2014", toDate: "09/10/2014", baseCurrency: "USD", baseExpenses: "3,232.92", countryCurrency: "SAR", countryExpenses: "12,121.12", exchangeRate: "0.27"))
        
        return data
    }
}
