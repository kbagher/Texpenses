//
//  DashboardViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 24/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var currency: UIView?
    @IBOutlet weak var expenses: UIView?
    @IBOutlet weak var exchangeRate: UIView?
    @IBOutlet weak var currecnySymbol: UILabel!
    @IBOutlet weak var currecnyName: UILabel!
    @IBOutlet weak var expensesSoFar: UILabel!
    @IBOutlet weak var rate: UITextField!
    @IBOutlet weak var averageExchangeRate: UILabel!
    @IBOutlet weak var baseCurranceValue: UILabel!
    var staticRate = 0.79
    var rateText:String = ""
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setStyleFor(view: currency!)
        setStyleFor(view: exchangeRate!)
        setStyleFor(view: expenses!)
        rate.delegate = self
    }
    
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
        
//        if exchangeRate!.frame.origin.y + rate.frame.origin.y + rate.frame.size.height + 10 > (keyboardFrameEndRect?.origin.y)! {
//            print("iff")
//            self.view.frame.origin.y = -(self.exchangeRate!.frame.origin.y + self.rate.frame.origin.y + self.rate.frame.size.height - (keyboardFrameEndRect?.origin.y)!) - 30.0
//        }
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
            if rateText.characters.count == 0{
                return false
            }
            rateText.remove(at: rateText.index(before: rateText.endIndex))
            rate.text = formatCurrency(value: rateText)
            baseCurranceValue.text = formatCurrency(value: String(Double(rateText)! * staticRate))
            return false
        }

        switch string {
            case "0","1","2","3","4","5","6","7","8","9",".":
                if string == "." && rateText.contains(".") {
                    return false
                }
            rateText += string
            print(rateText)
            print(rate.text!)
            rate.text = formatCurrency(value: rateText)
            baseCurranceValue.text = String(Double(rateText)! * staticRate)
            return false
            default:
                return false
            }
        }

    func formatCurrency(value: String) ->String {
        let doubleValue = Double(value) ?? 0.0
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = (value.contains(".00")) ? 0 : 2
        formatter.maximumFractionDigits = 2
        formatter.currencySymbol = ""
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: doubleValue)) ?? "\(doubleValue)"
    }

    
    
    // MARK: - UI
    func setStyleFor(view v:UIView) {
        // Cell desing (border and background color
        v.layer.masksToBounds = true
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 12
        v.layer.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0).cgColor
        v.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
