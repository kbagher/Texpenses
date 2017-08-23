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
    @IBOutlet var expense: UITextField!
    @IBOutlet var map: MKMapView!
    var locationManager: CLLocationManager!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        expense.becomeFirstResponder()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }

    }
    
    @IBAction func closeView(_sender : AnyObject){
        expense.endEditing(true)
        dismiss(animated: true, completion: nil)
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("CCC")
        let location = locations.last!
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        map.setRegion(region, animated: true)

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
