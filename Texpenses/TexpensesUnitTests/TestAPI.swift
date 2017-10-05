//
//  TestAPI.swift
//  Texpenses
//
//  Created by Kassem Bagher on 5/10/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
class TestAPI: API {
    
    var delegate: APIDelegate?
    
    func getCurrencies() {
        // Simulate api delay
        sleep(1)
        // return number of 10 currencies by the server
        delegate?.didRetrieveCurrencies!(numOfCurrencies: 10)
    }
    
    func exchangeRateWith(BaseCurrency bc: Currency, toCurrency: Currency) {
        
    }
}
