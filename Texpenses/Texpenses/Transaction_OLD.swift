//
//  Transaction.swift
//  Texpenses
//
//  Created by Kassem Bagher on 24/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
class Transaction_OLD: NSObject {
    var title:String = ""
    var baseCost:String = ""
    var country:String = ""
    var countryCost:String = ""
    var exchangeRate:String = ""
    var date:String = ""
    var time:String = ""
    var latitude:String = ""
    var longitude:String = ""
    var locationName:String = ""
    
    
    override init() {
        super.init()
    }
    
    init(title:String,baseCost:String,countryCost:String,exchangeRate:String,date:String,time:String,latitude:String,longitude:String,locationName:String,country:String) {
        self.title = title
        self.baseCost = baseCost
        self.countryCost = countryCost
        self.exchangeRate = exchangeRate
        self.date = date
        self.time = time
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
    }
    
    func getDummyData() -> [Transaction_OLD] {
        var data = [Transaction_OLD]()
        
        data.append(Transaction_OLD(title: "Hiking trip fees", baseCost: "$947.04", countryCost: "$1,201.00", exchangeRate: "0.79", date: "29/10/2017", time: "12:10 PM", latitude: "", longitude: "", locationName: "Dandenong Ranges, Australia",country: "Australia"))
        
        data.append(Transaction_OLD(title: "Sunglasses for Rayan", baseCost: "$101.61", countryCost: "$129.00", exchangeRate: "0.79", date: "29/10/2017", time: "11:19 PM", latitude: "", longitude: "", locationName: "Preston, Melbourne, Australia",country: "Australia"))
        
        data.append(Transaction_OLD(title: "Water bottle", baseCost: "$1.57", countryCost: "$1.99", exchangeRate: "0.79", date: "27/10/2017", time: "01:55 PM", latitude: "", longitude: "", locationName: "Melbourne CBD, Australia",country: "Australia"))
        
        data.append(Transaction_OLD(title: "Chips Snacks", baseCost: "$1.67", countryCost: "$2.12", exchangeRate: "0.79", date: "25/10/2017", time: "05:45 PM", latitude: "", longitude: "", locationName: "Melbourne CBD, Australia",country: "Australia"))
        
        data.append(Transaction_OLD(title: "Launch - Pasta", baseCost: "$16.46", countryCost: "$20.90", exchangeRate: "0.79", date: "25/10/2017", time: "03:20 PM", latitude: "", longitude: "", locationName: "Melbourne CBD, Australia",country: "Australia"))
        
        return data
    }

}
