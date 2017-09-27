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
    @IBOutlet weak var expensesSoFar: UILabel!
    @IBOutlet weak var rate: UITextField!
    @IBOutlet weak var averageExchangeRate: UILabel!
    @IBOutlet weak var baseCurranceValue: UILabel!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setStyleFor(view: currency!)
        setStyleFor(view: exchangeRate!)
        setStyleFor(view: expenses!)
        setTextfieldStyleFor(textField: rate!)
        
        //////////////////////// TEST
        
//        let m: Model = Model.sharedInstance
////        m.addCurrency(name: "Saudi Riyal", symbol: "SAR", rate: 1.0)
////        m.deleteCurrency(withSymbol: "AUD")
//        let x = m.getCurrencies()!
//        print(x.count);
//        let w:WebServices = WebServices.sharedInstance
//        w.delegate=self
//        w.getCurrencies()
//      
        LocationService.sharedInstance.delegate = self
        LocationService.sharedInstance.startUpdatingLocation()
        
        //////////////////////
        
        
        rate.delegate = self
    }
    
    ///////// TEST
    func didRetrieveAndUpdateCurrencies(numOfCurrencies: Int) {
        print(numOfCurrencies)
    }
    
    func tracingLocation(currentLocation: CLLocation) {
        LocationService.sharedInstance.getCountryWith(locaiton: currentLocation)
        LocationService.sharedInstance.stopUpdatingLocation()
    }

    func didReverseGeocode(name: String, country: String, countryCode: String, city: String, timeZone: TimeZone) {
        print(city)
    }
    
    func tracingLocationDidFailWithError(error: NSError) {
        print(error.description)
    }
    /////////
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            let currency = Currency_OLD.init().getCurrencyWith(symbol: "AUD")
            var amount:Double = 1
            if !(rate.text?.isEmpty)!{
             amount = Double(rate.text!)!
            }
            let val = Currency_OLD.init().calculateExchangeRateFromBaseWith(currency: currency!, amount: amount)
            baseCurranceValue.text = String(val)
            return false
        }
        
        switch string {
        case "0","1","2","3","4","5","6","7","8","9",".":
            if string == "." && (rate.text?.contains("."))! {
                return false
            }
            rate.text? += string
            let currency = Currency_OLD.init().getCurrencyWith(symbol: "AUD")
            let amount:Double = Double(rate.text!)!
            let val = Currency_OLD.init().calculateExchangeRateFromBaseWith(currency: currency!, amount: amount)
            baseCurranceValue.text = String(val)
            
//            rateText += string
//            rate.text = formatCurrency(value: rateText)
//            baseCurranceValue.text = String(Double(rateText)! * staticRate)
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
