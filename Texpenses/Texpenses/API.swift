//
//  API.swift
//  Texpenses
//
//  Created by Kassem Bagher on 5/10/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation

/// API delegate functions
@objc protocol APIDelegate {
    
    /// Exchange rate retrieved successfully
    ///
    /// Called when the exhcnage rate is retrieved successfully from the server
    /// - Parameter rate: exchange rate
    @objc optional func didRetrieveExchangeRate(rate: Double)
    /// Exchange rate is not retrieved
    ///
    /// Called when the the is an error while
    /// retrieving the exchange rate from the server
    /// - Parameter error: error object
    @objc optional func didRetrieveExchangeRateError(error: NSError)
    
    /// Currencies retrieved successfully
    ///
    /// Called when currencies are retrieved successfully from the server
    /// - Parameter numOfCurrencies: number of retrieved currencies
    @objc optional func didRetrieveCurrencies(numOfCurrencies: Int)
    /// Currencies are not retrieved
    ///
    /// Called when the the is an error while
    /// retrieving currencies from the server
    /// - Parameter error: error object
    @objc optional func didRetrieveCurrenciesError(error: NSError)
}

protocol API {
    
    var delegate: APIDelegate? { get set }
    
    /// Gets exchange rate from server
    ///
    /// This will return the exhcnage rate from the server baseed on the
    /// user's base currencies  and the country's currency
    /// - Parameters:
    ///   - bc: user's base currency
    ///   - toCurrency: country's currency
    func exchangeRateWith(BaseCurrency bc:Currency, toCurrency:Currency)
    /// Gets currencies from the server
    func getCurrencies()
}
