//
//  DashboardViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 24/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit
import CoreLocation

class DashboardViewController: UIViewController,UITextFieldDelegate,APIDelegate,LocationServiceDelegate{
    
    // MARK: - Class Variables
    
    // MARK: Interface
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
    
    // MARK: Variables
    let model = Model.sharedInstance
    let location = LocationService.sharedInstance
    var web : API?
    var currentPlaceMark: CLPlacemark?
    var appDataReady = false
    var currencyUpdated = false
    
    
    // MARK: - View lifecycle
    
    init(){
        super.init(nibName: "DashboardViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View items styling
        setStyleFor(view: currency!)
        setStyleFor(view: exchangeRate!)
        setStyleFor(view: expenses!)
        setTextfieldStyleFor(textField: rate!)

        // Exchange rate calculator textfield delegate
        rate.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set delegates before displaying the view
        if web?.delegate == nil{
            web = TexpensesAPI.sharedInstance
            web?.delegate = self
        }

        location.delegate = self
        
        // check if all required data are loaded
        isAppDataReady()
        
        // Observer keybaord display and hide
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /*
         Remove delegates before moving to another view.
         This will insure delegate are not handled in this view once it dissapear
        */
        location.delegate = nil
        web?.delegate = nil
        
        /*
         Remove keyboard display and hide observers.
         This will insure observer are not handled in this view once it dissapear
         */
        unregisterKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Delegates
    // MARK: Location

    /// Handles location authorizatin change delegate
    ///
    /// # See Also:
    /// LocationServiceDelegate -> didChangeAuthorization
    func didChangeAuthorization(status: CLAuthorizationStatus) {
        isAppDataReady()
    }
    
    /// Handles location updated delegate
    ///
    /// # See Also:
    /// LocationServiceDelegate -> didUpdateLocation
    func didUpdateLocation(currentLocation: CLLocation) {
        // check if app data is ready
        isAppDataReady()
        
        // No need to keep monitoring user's location
        location.stopUpdatingLocation()
    }
    
    
    /// Handles error while trying to get user's location delegate
    ///
    /// # See Also:
    /// LocationServiceDelegate -> didUpdateLocationFailWithError
    func didUpdateLocationFailWithError(error: NSError) {
        print(error.description)
    }

    /// Handles location reversed geocode delegate
    ///
    /// # See Also:
    /// LocationServiceDelegate -> didReverseGeocode
    func didReverseGeocode(place: CLPlacemark) {
        // update current placemark and check if app data is ready
        currentPlaceMark = place
        isAppDataReady()
    }
    
    // MARK: Exchange Rate
    
    /// Handles retreiving exchange rate delegate
    ///
    /// # See Also:
    /// LocationServiceDelegate -> didRetrieveExchangeRate
    func didRetrieveExchangeRate(rate: Double) {
        if let t = model.getCurrentActiveTrip(){
            hideActivityView()
            // update current active trip's latest exchange rate
            model.updateTrip(t, ExchangeRate: rate)
            currencyUpdated = true
            isAppDataReady()
        }
    }

    func didRetrieveExchangeRateError(error: NSError) {
        hideActivityView()
    }

    // MARK: Currencies Update
    
    /// Handles error while retrieving currencies from the server delegate
    ///
    /// # See Also:
    /// LocationServiceDelegate -> didRetrieveCurrenciesError
    func didRetrieveCurrenciesError(error: NSError) {
        hideActivityView()
        let alert = UIAlertController(title: "Error", message: "Unable to retrieve currencies from server", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Handles error retrieving currencies from the server delegate
    ///
    /// # See Also:
    /// LocationServiceDelegate -> didRetrieveCurrencies
    func didRetrieveCurrencies(numOfCurrencies: Int) {
        hideActivityView()
        isAppDataReady()
    }
    
    // MARK: - Helping Methods
    
    
    /// Hide activity view in main thread
    private func hideActivityView(){
        DispatchQueue.main.async {
            LoadingView.hideIndicator()
        }
    }
    
    /// Create a new trip
    ///
    /// Displaying an Alert to get user's response on wheter to create a new trip or not
    private func createNewTrip(){
        let alert = UIAlertController(title: "Create a new trip", message: "It looks like you don't have any active trip. Would you like to create one?", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "No 🙁", style: UIAlertActionStyle.default, handler: nil));
        alert.addAction(UIAlertAction(title: "Yes plz 😍", style: UIAlertActionStyle.cancel, handler: {(action:UIAlertAction) in
            
            // Create a new trip using user's curent location
            let name = self.currentPlaceMark?.country!
            let code = self.currentPlaceMark?.isoCountryCode!
            
            // Current location (Country) currency
            let currency = self.model.getCurrencyWithCountry(code: code!)
            
            let date = Date()
            let _ = self.model.addTrip(countryName: name!, countryCode: code!, startDate: date, currency: currency!)
            self.isAppDataReady()
        }));
        self.present(alert, animated: true, completion: nil);
    }
    
    
    /// Get Currencies from server
    func getCurrencies(){
        web?.getCurrencies()
    }
    
    /// Close current active trip
    ///
    /// Calling this method will clode the current active trp (if available)
    /// # See Also:
    /// Model -> close(Trip t:Trip)
    private func closeTrip(){
        let alert = UIAlertController(title: "Closing current trip", message: "It looks like your current location is different from your last trip's location.\nThe trip will be marked as closed.", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK, you guys are awesome", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            
            // Close current active trip
            if let t = self.model.getCurrentActiveTrip(){
                self.model.close(Trip: t)
                self.isAppDataReady()
            }
            
        }));
        present(alert, animated: true, completion: nil);
    }
    
    
    /// Displaying an Alert to inform the user that he needs to select a base currency
    private func selectCurrency(){
        let alert = UIAlertController(title: "No Base Currency", message: "It looks like your don't have a base currency selected yet 🤔.\nYou can select the base currency from 'Settings > Currency'", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK, take me there plz", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            // display settings view
            self.tabBarController?.selectedIndex = 3
        }));
        present(alert, animated: true, completion: nil);
    }

    /// Request Location Service Authorisation
    ///
    /// Displaying an Alert to explain and inform the user
    /// that the app will be requesting his location
    func askForLocationAuthorisation() {
        let alert = UIAlertController(title: "Location Service", message: "We are asking for the location service for you to be able to track your expenses.\nDon't worry we won't share or collect your information 🙈🙉🙊\n\nPlease click on 'Allow' in the next alert", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "Ok, i'll click on 'Allow'", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            
            self.location.requestAuthorization()
            
        }));
        present(alert, animated: true, completion: nil);
    }

    /// Check if App data are ready for usage
    ///
    /// This will check the following:
    /// - Location service authorisation status
    /// - Currencies list are fetched from the server
    /// - There is an active trip
    /// - The app has reversed user's location to get his current country information
    /// - Check if his current trip needs to be closed or not
    func isAppDataReady() {
        
        // check if location service is authorised
        if !location.isLocationServiceAuthorised(){
            DispatchQueue.main.async {
                self.askForLocationAuthorisation()
            }
            askForLocationAuthorisation()
            return
        }

        // Check if there any currencies in the database
        if model.getCurrencies() == nil{
            LoadingView.showIndicator("Optimising App Data ✌️")
            getCurrencies()
            print("getting currencies")
            return
        }
        
        if model.getPreferences() == nil {
            DispatchQueue.main.async {
                self.selectCurrency()
            }
            return
        }
        
        if let trip = model.getCurrentActiveTrip(){
            // check i the current trip location is similar to the user's location or not
            // if not then close the current trip and call this method again to create a new trip
            if let loc = location.currentLocation{
                if currentPlaceMark != nil{
                    if trip.countryCode == currentPlaceMark?.isoCountryCode {
                        print("Same country")
                        appDataReady = true
                        location.stopUpdatingLocation()
                        if trip.currentExchangeRate == 0.0{
                            LoadingView.showIndicator("Optimising Exchange Rate 💰")
                            web?.exchangeRateWith(BaseCurrency: (model.getPreferences()?.userCurrency)!, toCurrency: trip.currency!)
                            print("getting exchange rate")
                            return
                        }
                        DispatchQueue.main.async(execute: { 
                            self.displayDashboardInfo()
                        })
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
                    // display create a new trip alert in main thread
                    DispatchQueue.main.async {
                        self.createNewTrip()
                    }
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
    
    /// Update calculated exchange rate values
    private func updateExchangeRateCalculator(){
        var amount:Double = 1
        if !(rate.text?.isEmpty)!{
            amount = Double(rate.text!)!
        }
        baseCurranceValue.text = String(model.calculateExchangeRateForCurrentTrip(Amount: amount))
    }
    
    /// Display all information on UI
    private func displayDashboardInfo(){
        
        if !appDataReady {return}
        
        // current active trip
        let t = model.getCurrentActiveTrip()
        
        // fetch updated exchange rate from server
        if !currencyUpdated{
            web?.exchangeRateWith(BaseCurrency: (model.getPreferences()?.userCurrency)!, toCurrency: model.getCurrencyWithCountry(code: (t?.currency?.symbol)!)!)
        }
        
        // country and city information
        countryName.text =  currentPlaceMark?.country
        cityName.text = currentPlaceMark?.locality
        
        // currency information
        currecnyName.text = t?.currency?.name
        currecnySymbol.text = t?.currency?.symbol
        baseCurrency.text = model.getPreferences()?.userCurrency?.symbol
        tripCurrency.text = t?.currency?.symbol
        
        // total expenses infromation
        expensesSoFar.text = String(model.getTotalExpensesFor(Trip: t!)) + " " + (t?.currency?.symbol)!
        
        // calculated exchange rate
        if let r = t?.currentExchangeRate{
            let from = t?.currency?.symbol
            let to = model.getPreferences()?.userCurrency?.symbol
            averageExchangeRate.text = "1 \(from!) = \(r) \(to!)"
            updateExchangeRateCalculator()
        }
        else{
            // exchange rate is not fetched from the server yet
            averageExchangeRate.text = "-"
        }
        
    }
    
    // Used to supress error message caused by using class init()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Keyboard
    // MARK: Keyboard visibility
    
    /// Register keyboard will hide and show observers
    ///
    /// This is used to push view up or down to avoid overlapping the
    /// exchange rate calculator with the keyboard
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    /// Remove keyboard will hide and show observers
    ///
    /// This is used to push view up or down to avoid overlapping the
    /// exchange rate calculator with the the keyboard
    private func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    /// Handle keyboard will show observer
    ///
    /// This is used to push view up to avoid overlapping the
    /// exchange rate calculator by the keyboard
    func keyboardWillShow(notification: NSNotification){
        
        // get keyboard information to determine it's height
        let keyboardInfo  = notification.userInfo as NSDictionary?
        let keyboardFrameEnd: NSValue? = (keyboardInfo?.value(forKey: UIKeyboardFrameEndUserInfoKey) as? NSValue)
        let keyboardFrameEndRect: CGRect? = keyboardFrameEnd?.cgRectValue
        
        // push view up using keyboard size + margine
        if exchangeRate!.frame.origin.y + exchangeRate!.frame.size.height + 10 > (keyboardFrameEndRect?.origin.y)! {
            print("iff")
            self.view.frame.origin.y = -(self.exchangeRate!.frame.origin.y + exchangeRate!.frame.size.height - (keyboardFrameEndRect?.origin.y)!) - 30.0
        }

    }
    /// Handle keyboard will hide observer
    ///
    /// This is used to push view down after the keyboard is hidden
    func keyboardWillHide(notification: NSNotification){
        self.view.frame.origin.y = 0
    }
    
    /// Hide keyboard once the user taps anywhere on the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        rate.resignFirstResponder()
    }
    
    // MARK: input validation and formatting
    
    /// Handle text changes in the exchange rate calculator
    ///
    /// This is used to insure that only numbers and comma is entered
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // define backspace character
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        // user tapped on backspace
        if (isBackSpace == -92) {
            if rate.text?.characters.count == 0{
                // textfield is empty
                return false
            }
            
            // textfield is not empty
            // remove last character from the textfield
            rate.text?.remove(at: (rate.text?.index(before: (rate.text?.endIndex)!))!)

            // recalculate the exchange rate value
            updateExchangeRateCalculator()
            return false
        }
        
        
        // user did tap on other character than backspace
        switch string {
        case "0","1","2","3","4","5","6","7","8","9",".":
            if string == "." && (rate.text?.contains("."))! {
                // avoid duplicated comma
                return false
            }
            
            // valid input
            // update textfield and recalculate exchange rate
            rate.text? += string
            updateExchangeRateCalculator()
            
            return false // always return false as textfiled input has been handeled
        default:
            return false // invalid input
        }
    }
    
    // MARK: - UI
    
    
    /// Style textfield
    ///
    /// This will style the textfield to have rounded corners and light gray border
    ///
    /// - Parameter tf: UITextField to style
    private func setTextfieldStyleFor(textField tf:UITextField) {
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 7
        tf.layer.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0).cgColor
        tf.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    /// Style view
    ///
    /// This will style the UIView to have rounded corners and light gray border.
    /// It is used for dashboard rounded rectangles views (cell like)
    ///
    /// - Parameter tf: UIView to style
    private func setStyleFor(view v:UIView) {
        v.layer.masksToBounds = true
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 12
        v.layer.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0).cgColor
        v.layer.borderColor = UIColor.lightGray.cgColor
    }
}
