//
//  WebServices.swift
//  Texpenses
//
//  Created by Kassem Bagher on 26/9/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation

/// Web Service delegates
@objc protocol WebServicesDelegate {
    
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


class WebServices {
    
    // MARK: - Class Variables
    static let sharedInstance = WebServices()
    var delegate: WebServicesDelegate?
    private init(){}
    let session = URLSession.shared
    
    
    /// Gets exchange rate from server
    ///
    /// This will return the exhcnage rate from the server baseed on the
    /// user's base currencies  and the country's currency
    /// - Parameters:
    ///   - bc: user's base currency
    ///   - toCurrency: country's currency
    func exchangeRateWith(BaseCurrency bc:Currency, toCurrency:Currency) {
        
        // check if it's the same currency
        if bc.name! == toCurrency.name! {
            // Send exhcnage rate of 1.0 to the delegate
            self.delegate?.didRetrieveExchangeRate!(rate: 1.0)
            return
        }
        
        // create new requets with REST API URL
        var request = URLRequest(url: URL(string: "https://currencyconverter.p.mashape.com/?from=\(toCurrency.symbol!)&from_amount=1&to=\(bc.symbol!)")!)
        // API Key header
        request.setValue("At6ickh4Aamshmzv7yKtKX8lpNUrp1JONpdjsnIEwcuCI0WbHT", forHTTPHeaderField: "X-Mashape-Key")
        // tell the API to return json only
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // URL request task
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            
            // Request error
            if let error = downloadError
            {
                print("\(String(describing: data)) \n data")
                print("\(String(describing: response)) \n response")
                print("\(error)\n error")
                self.delegate?.didRetrieveCurrenciesError!(error: error as NSError)
            }
            else
            {
                // holds the request results
                let parsedResult: Any!
                do
                {
                    // Convert results to JSON object
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                }
                catch let error as NSError
                {
                    parsedResult = nil
                    self.delegate?.didRetrieveExchangeRateError!(error: error)
                }
                if let results = parsedResult as? NSDictionary {
                    // Extract ecchange rate from JSON
                    if let  stringRate = results.value(forKey: "to_amount"){
                        var rate = Double(stringRate as! Double)
                        rate = Model.sharedInstance.formatDecimalPoints(Number: rate)
                        self.delegate?.didRetrieveExchangeRate!(rate: rate)
                    }
                    else{
                        // wrong json data, sent by server
                        self.delegate?.didRetrieveExchangeRateError!(error: NSError())
                    }
                }
            }
        })
        
        // run the task
        task.resume()
    }
    
    
    /// Gets currencies from the server
    func getCurrencies(){
        // create new requets with REST API URL
        let request = URLRequest(url: URL(string: "http://currencyconverter.kund.nu/api/availablecurrencies/")!)
        
        // URL request task
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            
            // Request error
            if let error = downloadError
            {
                print("\(String(describing: data)) \n data")
                print("\(String(describing: response)) \n response")
                print("\(error)\n error")
                self.delegate?.didRetrieveCurrenciesError!(error: error as NSError)
            }
            else
            {
                // holds the request results
                let parsedResult: Any!
                do
                {
                    // Convert response to JSON object
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                }
                catch let error as NSError
                {
                    parsedResult = nil
                    self.delegate?.didRetrieveCurrenciesError!(error: error)
                }
                
                if let results = parsedResult as? NSArray {
                    // Extract currencies from JSON Dictionary
                    for item in results{
                        // extract currency information
                        let cur = item as! NSDictionary
                        let symbol = String(describing: cur.value(forKey: "id")!)
                        var name:String = String(describing: cur.value(forKey: "description")!)
                        name = name.substring(from: (name.index(name.startIndex, offsetBy: 4)))
                        name = name.replacingOccurrences(of: ",", with: "")
                        name = name.replacingOccurrences(of: "  ", with: " ")
                        
                        // Add currency to the database
                        Model.sharedInstance.addCurrency(name: name, symbol: symbol)
                    }
                    self.delegate?.didRetrieveCurrencies!(numOfCurrencies: results.count)
                }
                
            }
        })
        task.resume()
    }
    
}
