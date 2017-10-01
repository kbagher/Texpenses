

import Foundation
import CoreLocation

@objc protocol LocationServiceDelegate {
    func tracingLocation(currentLocation: CLLocation)
    func tracingLocationDidFailWithError(error: NSError)
    @objc optional func didChangeAuthorization(status: CLAuthorizationStatus)
    @objc optional func didReverseGeocode(name:String,country:String,countryCode:String,city:String,timeZone:TimeZone)
    @objc optional func didReverseGeocode(place:CLPlacemark)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = LocationService()
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var delegate: LocationServiceDelegate?
    let ceo: CLGeocoder = CLGeocoder()
    
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
//        if CLLocationManager.authorizationStatus() == .notDetermined {
//            // you have 2 choice
//            // 1. requestAlwaysAuthorization
//            // 2. requestWhenInUseAuthorization
//            locationManager.requestWhenInUseAuthorization()
//        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
        locationManager.distanceFilter = 150 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.didChangeAuthorization!(status: status)
    }
    
    func requestAuthorization(){
        guard let locationManager = self.locationManager else {
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func isLocationServiceAuthorised() -> Bool{
        return CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        // singleton for get last(current) location
        self.currentLocation = location
        
        // use for real time update location
        updateLocation(currentLocation: location)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        updateLocationDidFailWithError(error: error as NSError)
        
    }
    
    // Private function
    private func updateLocation(currentLocation: CLLocation){
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocation(currentLocation: currentLocation)
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error: error)
    }

    func getReversedGeocodeWith(locaiton:CLLocation){
        
        ceo.reverseGeocodeLocation(locaiton, completionHandler:
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
                    let pm = placemarks![0]
                    print("reversed")
                    delegate.didReverseGeocode!(place: pm)
//                    delegate.didReverseGeocode!(name: pm.name!, country: pm.country!, countryCode: pm.isoCountryCode!,city: pm.locality!, timeZone: pm.timeZone!)
                }}
        )
    }
    
}
