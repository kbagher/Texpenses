//
//  WebServices.swift
//  Texpenses
//
//  Created by Kassem Bagher on 26/9/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation

protocol WebServicesDelegate {
    func didRetrieveAndUpdateCurrencies(numOfCurrencies: Int)
}


class WebServices {
    
    static let sharedInstance = WebServices()
    var delegate: WebServicesDelegate?
    private init(){}
    
    let session = URLSession.shared
    
    func getCurrencies(){
        let request = URLRequest(url: URL(string: "http://currencyconverter.kund.nu/api/availablecurrencies/")!)
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            // Handler in the case of an error
            if let error = downloadError
            {
                print("\(String(describing: data)) \n data")
                print("\(String(describing: response)) \n response")
                print("\(error)\n error")
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
                catch _ as NSError
                {
                    parsedResult = nil
                }
                catch
                {
                    fatalError()
                }
                
                if let results = parsedResult as? NSArray {
                    for item in results{
                        let cur = item as! NSDictionary
                        let symbol = String(describing: cur.value(forKey: "id")!)
                        var name:String = String(describing: cur.value(forKey: "description")!)
                        name = name.substring(from: (name.index(name.startIndex, offsetBy: 4)))
                        name = name.replacingOccurrences(of: ",", with: "")
                        name = name.replacingOccurrences(of: "  ", with: " ")
                        Model.sharedInstance.addCurrency(name: name, symbol: symbol)
                    }
                    self.delegate?.didRetrieveAndUpdateCurrencies(numOfCurrencies: results.count)
                }
                
            }
        })
        task.resume()
    }
    
}
