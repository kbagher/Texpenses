//
//  Summary.swift
//  Texpenses
//
//  Created by Kassem Bagher on 24/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

class LoadingView {
    
    // MARK: - Class Variable
    static var overlayView : UIView?
    static var targetView : UIView?
    static var loadingText: String?
    
    
    // MARK: - View design and presentation
    
    
    /// Add observer to detect device rotation
    private static func addRotationObserver(){
        NotificationCenter.default.addObserver(
            self, selector:
            #selector(LoadingView.viewRotated),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil)
    }
    
    /// Adds an overlay view (dimmed background)
    private static func addOverlayView(){
        // Create the overlay
        if let overlay = overlayView, let target = targetView{
            overlay.center = target.center
            overlay.backgroundColor = UIColor.black
            overlay.alpha = 0
            target.addSubview(overlay)
            target.bringSubview(toFront: overlay)
        }
    }
    
    /// Adds Activity indicator and label on the overlay view
    static private func addActivityAndLabel(){
        if let overlay = overlayView{
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            indicator.center = overlay.center
            indicator.startAnimating()
            overlay.addSubview(indicator)
            
            // Create label
            let label = UILabel()
            label.text = loadingText
            label.textColor = UIColor.white
            label.sizeToFit()
            label.center = CGPoint(x: indicator.center.x, y: indicator.center.y + 30)
            overlay.addSubview(label)
        }
    }
    
    /// Display the activity view
    static private func displayView(){
        if let overlay = overlayView{
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            overlay.alpha = overlay.alpha > 0 ? 0 : 0.5
            UIView.commitAnimations()
        }
    }
    
    // MARK: - Show and hide activity indicator view
    
    
    /// Display the activity view on the main app view
    ///
    /// - Parameter loadingText: Text to be displayed
    static func showIndicator(_ loadingText: String?) {
        
        guard let overlayTarget = UIApplication.shared.keyWindow else {
            return
        }
        // Clear it first in case it was already shown
        hideIndicator()
        
        // register device orientation notification
        addRotationObserver()
        
        // init variables
        overlayView = UIView(frame: overlayTarget.frame)
        targetView = overlayTarget
        self.loadingText = loadingText
        
        
        // Create the overlay
        addOverlayView()
        
        // Create and animate the activity indicator
        addActivityAndLabel()
        
        // Animate the overlay to show
        displayView()
    }

    
    /// Hides activity view
    static func hideIndicator() {
        if overlayView != nil {
            
            // unregister device orientation notification
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange,                                                      object: nil)
            
            overlayView?.removeFromSuperview()
            overlayView =  nil
            self.loadingText = nil
            targetView = nil
        }
    }
    
    
    // MARK: - View Layout
    @objc private static func viewRotated() {
        // handle device orientation change by reactivating the loading indicator
        if overlayView != nil {
            showIndicator(self.loadingText)
        }
    }
}
