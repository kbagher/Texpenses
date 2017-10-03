//
//  LocationService
//  Texpenses
//
//  Created by Khaled Dowaid on 26/9/17.
//  Copyright © 2017 Khaled Dowaid. All rights reserved.
//

import Foundation
import CoreLocation

/// Location Service delegates
@objc protocol LocationServiceDelegate {
    
    /// Location changed delegate
    ///
    /// - Parameter currentLocation: updated location
    func didUpdateLocation(currentLocation: CLLocation)
    
    /// Error while getting location
    ///
    /// - Parameter error: error object
    func didUpdateLocationFailWithError(error: NSError)
    
    /// Location Service Authorization Changed
    ///
    /// Called whenever the authorization of the location service
    /// is changed.
    /// - Parameter status: new authirization
    @objc optional func didChangeAuthorization(status: CLAuthorizationStatus)
    
    /// Location geocode reversed
    ///
    /// - Parameter place: geocode placemark
    @objc optional func didReverseGeocode(place:CLPlacemark)
}

class LocationService: NSObject, CLLocationManagerDelegate {

    // MARK: - Class Variables
    static let sharedInstance = LocationService()
    private var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var delegate: LocationServiceDelegate?
    let locationGeocoder: CLGeocoder = CLGeocoder()
    
    
    override init() {
        super.init()
        
        // initialize location manager once
        self.locationManager = CLLocationManager()
        
        
        guard let locationManager = self.locationManager else {
            return // location manager not initialised
        }
        // Location required accurase and distance
        locationManager.distanceFilter = 150
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard let delegate = self.delegate else {
            return
        }
        // inform the delegate that authorization has changed
        delegate.didChangeAuthorization!(status: status)
    }
    
    
    /// Request location service authorization from the user
    func requestAuthorization(){
        guard let locationManager = self.locationManager else {
            return
        }
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Check if the app has authorization to use location service
    ///
    /// - Returns: true if app can use location service
    func isLocationServiceAuthorised() -> Bool{
        return CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
    
    
    /// Start tracking user's location
    func startUpdatingLocation() {
        print("called")
        self.locationManager?.startUpdatingLocation()
    }
    
    /// Stop tracking user's location
    func stopUpdatingLocation() {
        self.locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.last else {
            return
        }
        
        // update current location internally
        self.currentLocation = location

        guard let delegate = self.delegate else {
            print("no delegate")
            return
        }
        
        // inform the delegate that location has changed
        delegate.didUpdateLocation(currentLocation: location)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        updateLocationDidFailWithError(error: error as NSError)
    }
    
    /// Failed to get user's location
    ///
    /// - Parameter error: error object
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        // inform the delegate that an error occured while gettings user's location
        delegate.didUpdateLocationFailWithError(error: error)
    }
    
    
    /// Reverse user's location
    ///
    /// - Parameter locaiton: Location to be reversed
    func getReversedGeocodeWith(locaiton:CLLocation){
        
        locationGeocoder.reverseGeocodeLocation(locaiton, completionHandler:
            {(placemarks, error) in
                
                guard let delegate = self.delegate else {
                    return
                }
                
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    // has placemark
                    let pm = placemarks![0]
                    
                    // Send reversed geocode location's placemark
                    delegate.didReverseGeocode!(place: pm)
                }}
        )
    }
    
}
