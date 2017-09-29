//
//  DashboardViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 24/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit
import CoreLocation

class DashboardViewController: UIViewController,UITextFieldDelegate,WebServicesDelegate,LocationServiceDelegate{
    
    @IBOutlet weak var currency: UIView?
    @IBOutlet weak var expenses: UIView?
    @IBOutlet weak var exchangeRate: UIView?
    @IBOutlet weak var currecnySymbol: UILabel!
    @IBOutlet weak var currecnyName: UILabel!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var expensesSoFar: UILabel!
    @IBOutlet weak var rate: UITextField!
    @IBOutlet weak var averageExchangeRate: UILabel!
    @IBOutlet weak var baseCurranceValue: UILabel!
    @IBOutlet weak var baseCurrency: UILabel!
    @IBOutlet weak var tripCurrency: UILabel!
    let model = Model.sharedInstance
    let location = LocationService.sharedInstance
    var currentPlaceMark: CLPlacemark?
    var appDataReady = false
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setStyleFor(view: currency!)
        setStyleFor(view: exchangeRate!)
        setStyleFor(view: expenses!)
        setTextfieldStyleFor(textField: rate!)
        LocationService.sharedInstance.delegate = self
        WebServices.sharedInstance.delegate=self
        WebServices.sharedInstance.exchangeRateWith(BaseCurrency: (model.getPreferences()?.userCurrency)!, toCurrency: model.getCurrencyWithCountry(code: "AU")!)
        //////////////////////// TEST
        
//        let m: Model = Model.sharedInstance
////        m.addCurrency(name: "Saudi Riyal", symbol: "SAR", rate: 1.0)
////        m.deleteCurrency(withSymbol: "AUD")
//        let x = m.getCurrencies()!
//        print(x.count);
//        let w:WebServices = WebServices.sharedInstance
//        w.delegate=self
//        w.getCurrencies()
////
//        LocationService.sharedInstance.delegate = self
//        LocationService.sharedInstance.startUpdatingLocation()

        
//        let x = Model.sharedInstance.getCurrentTrip()
//        if x == nil {
//            print("NILL")
//        }

//        let m = Model.sharedInstance;
//        
//        m.addTrip(countryName: "Saudi Arabia", countryCode: "AU", startDate: Date.init(), currency: m.getCurrencyWithCountry(code: "AU")!)
        
        //////////////////////
        
        
        rate.delegate = self
    }
    
    ///////// TEST

    
    func tracingLocation(currentLocation: CLLocation) {
        print("got location")
        isAppDataReady()
        LocationService.sharedInstance.stopUpdatingLocation()
    }

    
    
    func didReverseGeocode(name: String, country: String, countryCode: String, city: String, timeZone: TimeZone) {
        countryName.text = country
        cityName.text = city
        if let c = Model.sharedInstance.getCurrencyWithCountry(code: countryCode){
            currecnyName.text = c.name
            currecnySymbol.text = c.symbol
        }
    }
    
    func didRetrieveExchangeRate(rate: Double) {
        if let t = model.getCurrentActiveTrip(){
            model.updateTrip(t, ExchangeRate: rate)
            isAppDataReady()
        }
    }
    
    func didRetrieveExchangeRateError(error: NSError) {
        
    }
    
    
    func tracingLocationDidFailWithError(error: NSError) {
        print(error.description)
    }
    /////////
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAppDataReady()
        registerNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    // MARK: - Helping Methods
    func createNewTrip(){
        let alert = UIAlertController(title: "Create a new trip", message: "It looks like you don't have any active trip. Would you like to create one?", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "No 🙁", style: UIAlertActionStyle.default, handler: nil));
        //event handler with closure
        alert.addAction(UIAlertAction(title: "Yes plz 😍", style: UIAlertActionStyle.cancel, handler: {(action:UIAlertAction) in
            let name = self.currentPlaceMark?.country!
            let code = self.currentPlaceMark?.isoCountryCode!
            let currency = self.model.getCurrencyWithCountry(code: code!)
            let date = Date()
            let _ = self.model.addTrip(countryName: name!, countryCode: code!, startDate: date, currency: currency!)
            self.displayDashboardInfo()
        }));
        self.present(alert, animated: true, completion: nil);
    }
    
    
    func closeTrip(){
        let alert = UIAlertController(title: "Closing current trip", message: "It looks like your current location is different from your last trip's location.\nThe trip will be marked as closed.", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK, you guys are awesome", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            if let t = self.model.getCurrentActiveTrip(){
                self.model.close(Trip: t)
                self.isAppDataReady()
            }
        }));
        present(alert, animated: true, completion: nil);
    }
    
    func selectCurrency(){
        let alert = UIAlertController(title: "No Base Currency", message: "It looks like your don't have a base currency selected yet 🤔.\nYou can select the base currency from 'Settings > Currency'", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "Let's do it 💪", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            self.tabBarController?.selectedIndex = 3
        }));
        present(alert, animated: true, completion: nil);
    }

    
    func didReverseGeocode(place: CLPlacemark) {
        currentPlaceMark = place
        isAppDataReady()
    }

    func isAppDataReady() {
        // Check if there any currencies in the database
        if Model.sharedInstance.getCurrencies()?.count == 0{
            WebServices.sharedInstance.getCurrencies()
            print("getting currencies")
            return
        }
        
        if model.getPreferences() == nil {
            selectCurrency()
            return
        }
        
        if let trip = Model.sharedInstance.getCurrentActiveTrip(){
            // check i the current trip location is similar to the user's location or not
            // if not then close the current trip and call this method again to create a new trip
            if let loc = location.currentLocation{
                if currentPlaceMark != nil{
                    if trip.countryCode == currentPlaceMark?.isoCountryCode {
                        print("Same country")
                        appDataReady = true
                        displayDashboardInfo()
                        return
                    }
                    else{
                        // close trip and inform the user
                        print("Not Same country")
                        closeTrip()
                        return
                    }
                }
                else{
                    location.getReversedGeocodeWith(locaiton: loc)
                    print("No Country info")
                    return
                }
            }
            else{
                location.startUpdatingLocation()
                print("No location")
                return
            }
        }
        else{
            // ask the user if he wish to create a trip
            if let loc = location.currentLocation{
                if currentPlaceMark != nil{
                    createNewTrip()
                    
                    return
                }
                else{
                    location.getReversedGeocodeWith(locaiton: loc)
                    return
                }
            }
            else{
                location.startUpdatingLocation()
                return
            }
        }
    }
    
    func displayDashboardInfo(){
        if !appDataReady {return}
        
        
        let t = model.getCurrentActiveTrip()
        
        // location
        countryName.text =  currentPlaceMark?.country
        cityName.text = currentPlaceMark?.locality
        
        // currency
        currecnyName.text = t?.currency?.name
        currecnySymbol.text = t?.currency?.symbol
        baseCurrency.text = model.getPreferences()?.userCurrency?.symbol
        tripCurrency.text = t?.currency?.symbol
        
        // total expenses
        expensesSoFar.text = String(model.getTotalExpensesFor(Trip: t!)) + " " + (t?.currency?.symbol)!
        
        // exchnage rate
        if let r = t?.currentExchangeRate{
            let from = t?.currency?.symbol
            let to = model.getPreferences()?.userCurrency?.symbol
            averageExchangeRate.text = "1 \(from!) = \(r) \(to!)"
        }
        else{
            averageExchangeRate.text = "-"
        }
        
    }
    
    func didRetrieveCurrenciesError(error: NSError) {
        let alert = UIAlertController(title: "Error", message: "Unable to retrieve currencies from server", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didRetrieveCurrencies(numOfCurrencies: Int) {
        isAppDataReady()
    }

    // MARK: - Keyboard
    // MARK: Keyboard visibility
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        let keyboardInfo  = notification.userInfo as NSDictionary?
        let keyboardFrameEnd: NSValue? = (keyboardInfo?.value(forKey: UIKeyboardFrameEndUserInfoKey) as? NSValue)
        let keyboardFrameEndRect: CGRect? = keyboardFrameEnd?.cgRectValue
        print( exchangeRate!.frame.origin.y + rate.frame.origin.y )
        
        if exchangeRate!.frame.origin.y + exchangeRate!.frame.size.height + 10 > (keyboardFrameEndRect?.origin.y)! {
            print("iff")
            self.view.frame.origin.y = -(self.exchangeRate!.frame.origin.y + exchangeRate!.frame.size.height - (keyboardFrameEndRect?.origin.y)!) - 30.0
        }

    }
    
    func keyboardWillHide(notification: NSNotification){
        self.view.frame.origin.y = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        rate.resignFirstResponder()
    }
    
    // MARK: input validation and formatting
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            if rate.text?.characters.count == 0{
                return false
            }
            rate.text?.remove(at: (rate.text?.index(before: (rate.text?.endIndex)!))!)

            // recalculate the value
            var amount:Double = 1
            if !(rate.text?.isEmpty)!{
                amount = Double(rate.text!)!
            }
            baseCurranceValue.text = String(model.calculateExchangeRateForCurrentTrip(Amount: amount))
            return false
        }
        
        switch string {
        case "0","1","2","3","4","5","6","7","8","9",".":
            if string == "." && (rate.text?.contains("."))! {
                return false
            }
            rate.text? += string
            let amount:Double = Double(rate.text!)!
            baseCurranceValue.text = String(model.calculateExchangeRateForCurrentTrip(Amount: amount))
            return false
        default:
            return false
        }
    }

    //     WILL BE USED LATER
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        let  char = string.cString(using: String.Encoding.utf8)!
//        let isBackSpace = strcmp(char, "\\b")
//
//        if (isBackSpace == -92) {
//            if rateText.characters.count == 0{
//                return false
//            }
//            rateText.remove(at: rateText.index(before: rateText.endIndex))
//            rate.text = formatCurrency(value: rateText)
//            baseCurranceValue.text = formatCurrency(value: String(Double(rateText)! * staticRate))
//            return false
//        }
//
//        switch string {
//            case "0","1","2","3","4","5","6","7","8","9",".":
//                if string == "." && rateText.contains(".") {
//                    return false
//                }
//            rateText += string
//            print(rateText)
//            print(rate.text!)
//            rate.text = formatCurrency(value: rateText)
//            baseCurranceValue.text = String(Double(rateText)! * staticRate)
//            return false
//            default:
//                return false
//            }
//        }

    
    // will be used later
//    func formatCurrency(value: String) ->String {
//        let doubleValue = Double(value) ?? 0.0
//        let formatter = NumberFormatter()
//        formatter.minimumFractionDigits = (value.contains(".00")) ? 0 : 2
//        formatter.maximumFractionDigits = 2
//        formatter.currencySymbol = ""
//        formatter.numberStyle = .currency
//        return formatter.string(from: NSNumber(value: doubleValue)) ?? "\(doubleValue)"
//    }

    
    
    // MARK: - UI
    
    func setTextfieldStyleFor(textField tf:UIView) {
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 7
        tf.layer.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0).cgColor
        tf.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setStyleFor(view v:UIView) {
        // Cell desing (border and background color)
        v.layer.masksToBounds = true
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 12
        v.layer.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0).cgColor
        v.layer.borderColor = UIColor.lightGray.cgColor
    }
    

}
