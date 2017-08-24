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
    
    override init() {
        super.init()
    }
    
    init(countryName:String,currency:String) {
        self.countryName = countryName
        self.currency = currency
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
