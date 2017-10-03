//
//  AddExpenseViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 23/8/17.
//  Updated by Khaled Dowaid on 1/10/2017
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddExpenseViewController: UIViewController,UITextFieldDelegate,LocationServiceDelegate {
    
    // MARK: - Class Variables
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

        // set focus on expense textfield
        expense.becomeFirstResponder()
        
        // Tap on expense label to add the title
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddExpenseViewController.setTitle(sender:)))
        expenseTitle.addGestureRecognizer(tap)
        
        // Country's Currency label
        currency.text = model.getCurrentActiveTrip()?.currency?.symbol
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure latest user's location is tracked
        location.delegate = self
        location.stopUpdatingLocation()
        location.startUpdatingLocation()
        
        // Add Keyboard observers
        registerNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove keyboard observers
        unregisterNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Close the view withour saving user's expense
    @IBAction func closeView(_sender : AnyObject){
        dismissView()
    }

    
    // MARK: - Helping functions
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Disable copy,paste,etc.. action
        return false
    }
    /// Save user's expense
    @IBAction func saveExpense(_ sender: AnyObject) {
        //
        if !isDataReady(){
            // some textfields input or data are mising
            return
        }
        
        // Add expense for the current active trip
        if let trip = model.getCurrentActiveTrip(){
            let _ = model.addTransactionFor(Trip: trip, amount: Double(expense.text!)!, title: expenseTitle.text!, latitude: (location.currentLocation?.coordinate.latitude)!, longitude: (location.currentLocation?.coordinate.longitude)!, locality: (place?.locality)!, locationName: (place?.name)!)
            
            // dismiss view after adding the expense
            dismissView()
        }
        else{
            // no active trip available
            displayNoActiveTrip()
            return
        }
    }
    
    /// Dismisses the expense view
    func dismissView(){
        expense.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    /// No location is available
    ///
    /// This can be wither because of a permission issue or
    /// the user's location is not retrieved
    func displayNoLocation(){
        let alert = UIAlertController(title: "No Location", message: "It looks like we can't get your current location 😣.\nMake sure location service is on and try again", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil);
    }
    
    /// No active trip is available
    ///
    /// user needs to create a new trip from the dashboard view
    func displayNoActiveTrip(){
        let alert = UIAlertController(title: "No active trip", message: "It looks you don't have any active trip.\nPlease go to the dashboard and create one", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil);
    }
    
    /// Missing expense title
    func displayNoTitle(){
        let alert = UIAlertController(title: "No Title", message: "Please enter a valid title for your expense.\nYou don't want to lose track of it, don't you! 🙈", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "Sure 😅", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil);
    }
    
    /// Noexpense amount entered
    func displayNoExpenseAmount(){
        let alert = UIAlertController(title: "No Amount", message: "Please enter a valid amount for your expense.\nWe're pretty suere you paid something for that! 👀", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "Sure i did 😅", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil);
    }
    
    /// Check if all required data are provided
    func isDataReady() -> Bool{
        // User's location availability
        if place == nil || location.currentLocation == nil{
            displayNoLocation()
            return false
        }
        
        // Check expense title
        if let _ = expenseTitle.text{
            expenseTitle.text = expenseTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if (expenseTitle.text?.isEmpty)! || expenseTitle.text == "Title..."{
                displayNoTitle()
                return false
            }
        }

        // Check expense amount
        if let _ = expense.text{
            if (expense.text?.isEmpty)!{
                displayNoExpenseAmount()
                return false
            }
        }
        
        return true
    }
    
    
    /// Setting expense title
    ///
    /// Tapping on the expense title will display and input alert action
    /// allowing the user to enter a title
    /// - Parameter sender: tap gesture
    func setTitle(sender:UITapGestureRecognizer) {
        
        // Customise the alert
        let alert = UIAlertController(title: nil, message: "Enter expense title", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Ok", style: .default) { (_) in
            
            // grap entered text
            if let field = alert.textFields?[0] {
                // user entered a valid text
                self.expenseTitle.text = field.text
            } else {
                // user did not fill field
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        // Set title back to default if user deleted the previous title
        alert.addTextField { (textField) in
            textField.placeholder = "Title..."
        }
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        // display customised alert
        self.present(alert, animated: true, completion: nil)
    }


    // MARK: - Location Service
    
    /// Location reversed geocode information
    func didReverseGeocode(place: CLPlacemark) {
        self.place = place
    }
    
    /// User location update delegate
    ///
    /// This is used to set user's location on the map
    func didUpdateLocation(currentLocation: CLLocation) {
        
        // Sett user's location in the center of the map
        let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
        // Add pin on user's location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        
        // remove previously added pins
        map.removeAnnotations(map.annotations)
        map.addAnnotation(myAnnotation)
        
        // Get location reversed geocode
        location.getReversedGeocodeWith(locaiton: currentLocation)
        
        location.stopUpdatingLocation()
    }
    
    /// Handles error while trying to get user's location delegate
    ///
    /// # See Also:
    /// LocationServiceDelegate -> didUpdateLocationFailWithError

    func didUpdateLocationFailWithError(error: NSError) {
        print("NO COOL")
    }
    
    // MARK: - Keyboard visibility
    
    /// Register keyboard will hide and show observers
    ///
    /// This is used to push view up or down to avoid overlapping the
    /// expense amount textfield with the keyboard
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    /// Remove keyboard will hide and show observers
    ///
    /// This is used to push view up or down to avoid overlapping the
    /// expense amount textfiled with the the keyboard
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    /// Handle keyboard will show observer
    ///
    /// This is used to push view up to avoid overlapping the
    /// expense amount textfiled by the keyboard
    func keyboardWillShow(notification: NSNotification){
        let keyboard  = notification.userInfo as NSDictionary?
        let keyboardFrame: CGRect? = (keyboard?.value(forKey: UIKeyboardFrameEndUserInfoKey) as? NSValue)?.cgRectValue
        
        if expense!.frame.origin.y + expense!.frame.size.height + 10 > (keyboardFrame?.origin.y)! {
            
            self.view.frame.origin.y = -(self.expense!.frame.origin.y + expense!.frame.size.height - (keyboardFrame?.origin.y)!) - 30.0
        }
        
    }
    
    /// Handle keyboard will show observer
    ///
    /// This is used to push view up to avoid overlapping the
    /// expense amount textfiled by the keyboard
    func keyboardWillHide(notification: NSNotification){
        self.view.frame.origin.y = 0
    }
    
    /// Hide keyboard when user touches anywhere on the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        expense.resignFirstResponder()
    }
}
