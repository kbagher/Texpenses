//
//  AddExpenseViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 23/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddExpenseViewController: UIViewController,UITextFieldDelegate,LocationServiceDelegate {
    @IBOutlet var currency: UILabel!
    @IBOutlet var expenseTitle: UILabel!
    @IBOutlet var expense: UITextField!
    @IBOutlet var map: MKMapView!
    private let location = LocationService.sharedInstance
    private let model = Model.sharedInstance
    private var place: CLPlacemark?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        expense.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddExpenseViewController.setTitle(sender:)))
        expenseTitle.addGestureRecognizer(tap)
        
        currency.text = model.getCurrentActiveTrip()?.currency?.symbol
        
        location.delegate = self
        location.startUpdatingLocation()
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
    
    @IBAction func closeView(_sender : AnyObject){
        expense.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Helping functions
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    @IBAction func saveExpense(_ sender: AnyObject) {
        if !isDataReady(){
            return
        }
        if let trip = model.getCurrentActiveTrip(){
            let _ = model.addTransactionFor(Trip: trip, amount: Double(expense.text!)!, title: expenseTitle.text!, latitude: (location.currentLocation?.coordinate.latitude)!, longitude: (location.currentLocation?.coordinate.longitude)!, locality: (place?.locality)!, locationName: (place?.name)!)
            
            expense.endEditing(true)
            dismiss(animated: true, completion: nil)
        }
        else{
            displayNoActiveTrip()
            return
        }
    }
    
    func displayNoLocation(){
        let alert = UIAlertController(title: "No Location", message: "It looks like we can't get your current location 😣.\nMake sure location service is on and try again", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil);
    }
    
    func displayNoActiveTrip(){
        let alert = UIAlertController(title: "No active trip", message: "It looks you don't have any active trip.\nPlease go to the dashboard and create one", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil);
    }
    
    func displayNoTitle(){
        let alert = UIAlertController(title: "No Title", message: "Please enter a valid title for your expense.\nYou don't want to lose track of it, don't you! 🙈", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "Sure 😅", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil);
    }
    
    func displayNoExpenseAmount(){
        let alert = UIAlertController(title: "No Amount", message: "Please enter a valid amount for your expense.\nWe're pretty suere you paid something for that! 👀", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "Sure i did 😅", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil);
    }
    
    func isDataReady() -> Bool{
        // Check user's location availability
        if place == nil || location.currentLocation == nil{
            displayNoLocation()
            return false
        }
        
        // check title filed 
        if let _ = expenseTitle.text{
            expenseTitle.text = expenseTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if (expenseTitle.text?.isEmpty)! || expenseTitle.text == "Title..."{
                displayNoTitle()
                return false
            }
        }

        // check amount filed
        if let _ = expense.text{
            if (expense.text?.isEmpty)!{
                displayNoExpenseAmount()
                return false
            }
        }
        
        return true
    }
    
    func setTitle(sender:UITapGestureRecognizer) {
        let alert = UIAlertController(title: nil, message: "Enter expense title", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Ok", style: .default) { (_) in
            if let field = alert.textFields?[0] {
                self.expenseTitle.text = field.text
            } else {
                // user did not fill field
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }


    // MARK: - Location Service

    func didReverseGeocode(place: CLPlacemark) {
        self.place = place
    }
    
    
    func didUpdateLocation(currentLocation: CLLocation) {
        let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        map.setRegion(region, animated: true)
        
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        map.removeAnnotations(map.annotations)
        map.addAnnotation(myAnnotation)
        
        location.getReversedGeocodeWith(locaiton: currentLocation)
        
        location.stopUpdatingLocation()
    }
    func didUpdateLocationFailWithError(error: NSError) {
        
    }
    
    // MARK: - Keyboard visibility
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        let keyboard  = notification.userInfo as NSDictionary?
        let keyboardFrame: CGRect? = (keyboard?.value(forKey: UIKeyboardFrameEndUserInfoKey) as? NSValue)?.cgRectValue
        
        if expense!.frame.origin.y + expense!.frame.size.height + 10 > (keyboardFrame?.origin.y)! {
            
            self.view.frame.origin.y = -(self.expense!.frame.origin.y + expense!.frame.size.height - (keyboardFrame?.origin.y)!) - 30.0
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        expense.resignFirstResponder()
    }
    
    func keyboardWillHide(notification: NSNotification){
        self.view.frame.origin.y = 0
    }

}
