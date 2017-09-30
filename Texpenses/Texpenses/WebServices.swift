//
//  WebServices.swift
//  Texpenses
//
//  Created by Kassem Bagher on 26/9/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation

@objc protocol WebServicesDelegate {
    @objc optional func didRetrieveExchangeRate(rate: Double)
    @objc optional func didRetrieveExchangeRateError(error: NSError)
    @objc optional func didRetrieveCurrencies(numOfCurrencies: Int)
    @objc optional func didRetrieveCurrenciesError(error: NSError)
}


class WebServices {
    
    static let sharedInstance = WebServices()
    var delegate: WebServicesDelegate?
    private init(){}
    
    let session = URLSession.shared
    
    func exchangeRateWith(BaseCurrency bc:Currency, toCurrency:Currency) {
        var request = URLRequest(url: URL(string: "https://currencyconverter.p.mashape.com/?from=\(toCurrency.symbol!)&from_amount=1&to=\(bc.symbol!)")!)
        request.setValue("At6ickh4Aamshmzv7yKtKX8lpNUrp1JONpdjsnIEwcuCI0WbHT", forHTTPHeaderField: "X-Mashape-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            // Handler in the case of an error
            if let error = downloadError
            {
                print("\(String(describing: data)) \n data")
                print("\(String(describing: response)) \n response")
                print("\(error)\n error")
                self.delegate?.didRetrieveCurrenciesError!(error: error as NSError)
            }
            else
            {
                // Create a variable to hold the results once they have been passed through the JSONSerialiser.
                // Why has this variable been declared with an explicit data type of Any
                let parsedResult: Any!
                do
                {
                    // Convert the http response payload to JSON.
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                }
                catch let error as NSError
                {
                    parsedResult = nil
                    self.delegate?.didRetrieveExchangeRateError!(error: error)
                }
                if let results = parsedResult as? NSDictionary {
                    var rate = Double(results.value(forKey: "to_amount") as! Double)
//                    rate = Double(round(100 * rate)/100)
                    rate = Model.sharedInstance.formatDecimalPoints(Number: rate)
                    self.delegate?.didRetrieveExchangeRate!(rate: rate)
                }
                
            }
        })
        task.resume()
    }
    
    
    func getCurrencies(){
        let request = URLRequest(url: URL(string: "http://currencyconverter.kund.nu/api/availablecurrencies/")!)
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            print("HERE")
            // Handler in the case of an error
            if let error = downloadError
            {
                print("\(String(describing: data)) \n data")
                print("\(String(describing: response)) \n response")
                print("\(error)\n error")
                self.delegate?.didRetrieveCurrenciesError!(error: error as NSError)
            }
            else
            {
                // Create a variable to hold the results once they have been passed through the JSONSerialiser.
                // Why has this variable been declared with an explicit data type of Any
                let parsedResult: Any!
                do
                {
                    // Convert the http response payload to JSON.
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                }
                catch let error as NSError
                {
                    parsedResult = nil
                    self.delegate?.didRetrieveCurrenciesError!(error: error)
                }
                
                if let results = parsedResult as? NSArray {
                    for item in results{
                        let cur = item as! NSDictionary
                        let symbol = String(describing: cur.value(forKey: "id")!)
                        var name:String = String(describing: cur.value(forKey: "description")!)
                        name = name.substring(from: (name.index(name.startIndex, offsetBy: 4)))
                        name = name.replacingOccurrences(of: ",", with: "")
                        name = name.replacingOccurrences(of: "  ", with: " ")
                        let _ = Model.sharedInstance.addCurrency(name: name, symbol: symbol)
                    }
                    self.delegate?.didRetrieveCurrencies!(numOfCurrencies: results.count)
                }
                
            }
        })
        task.resume()
    }
    
}
