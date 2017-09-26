//
//  WebServices.swift
//  Texpenses
//
//  Created by Kassem Bagher on 26/9/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import Foundation
protocol WebServicesDelegate {
    func didRetrieveCurrencies()
    func playlistDidTap()
}


class WebServices {
    
    static let sharedInstance = WebServices()
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
                    print(results[0])
                    for item in results{
                        let cur = item as! NSDictionary
                        let symbol = String(describing: cur.value(forKey: "id")!)
//                        print(symbol)
                        var name:String = String(describing: cur.value(forKey: "description")!)
                        name = name.substring(from: (name.index(name.startIndex, offsetBy: 4)))
                        name = name.replacingOccurrences(of: ",", with: "")
                        name = name.replacingOccurrences(of: "  ", with: " ")
                        print(name)
//                        print(symbol + " " + name)
                    }
                }
                
                // Log the results to the console, so you can see what is being sent back from the service.
//                print(parsedResult)
                
                // Extract an element from the data as an array, if your JSON response returns a dictionary you will need to convert it to an NSDictionary
                // Why must parsedResult be cast to AnyObject if it is already declared as type Any, there is a clue in the syntax :-)
//                if let moviesArray = (parsedResult as AnyObject).value(forKey: element) as? NSArray
//                {
//                    var id:String?
//                    for m in moviesArray
//                    {
//                        let movie = m as! NSDictionary
//                        
//                        if movie.value(forKey: "original_title") as! String == self.movie_name.text
//                        {
//                            id = String(describing: movie.value(forKey: "id")!)
//                            self.getRandomMovieImage(id!)
//                            break
//                        }
//                    }
//                    if id == ""
//                    {
//                        print("Movie not found")
//                    }
//                }
            }
        })
        // Execute the task
        task.resume()
    }
    
}
