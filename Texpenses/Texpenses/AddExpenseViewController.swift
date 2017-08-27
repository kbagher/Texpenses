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

class AddExpenseViewController: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate {

    @IBOutlet var currency: UILabel!
    @IBOutlet var expenseTitle: UILabel!
    @IBOutlet var expense: UITextField!
    @IBOutlet var map: MKMapView!
    var locationManager: CLLocationManager!

    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        expense.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddExpenseViewController.setTitle(sender:)))
        expenseTitle.addGestureRecognizer(tap)

        
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterNotifications()
    }

    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    @IBAction func saveExpense(_ sender: AnyObject) {
        expense.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeView(_sender : AnyObject){
        expense.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Other
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


    // MARK: - Location Manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        let location = locations.last!
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        map.setRegion(region, animated: true)
        
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        map.removeAnnotations(map.annotations)
        map.addAnnotation(myAnnotation)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
