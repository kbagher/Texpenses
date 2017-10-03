//
//  SettingsTableViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 23/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController,MFMailComposeViewControllerDelegate {

    // MARK: - Class Variables
    let model = Model.sharedInstance
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // update view information
        updateCurrency()
        updateFooter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // update base currency if changed in the currency selection view
        updateCurrency()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle user tap on settings table
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "showCurrencies", sender: nil) // currency selection
        default:
            switch indexPath.item {
            case 0:
                contactUS()
            default:
                shareApp()
            }
        }
        // remove selection highlight
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Other functions
    
    
    /// Display app sharing options
    ///
    /// This will display activity view allowint the user to share
    /// the app using available text-supporting apps
    func shareApp() {
        let txt = "Best app to track your expenses while travelling 😍"
        let url = NSURL(string: "https://itunes.apple.com/au/app/%D8%B4%D9%88%D8%A7%D8%B1%D8%B9-%D8%AC%D8%AF%D8%A9/id1031487168?mt=8")
        
        let shareContent = [ txt,url!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        
        // Support popover on iPad
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    /// Display contact us options
    ///
    /// This will display and action sheet allowint the user to either
    /// select email or twitter support
    func contactUS(){
        let alert = UIAlertController(title: "Contact us", message: "How would you like to contact us? ", preferredStyle: UIAlertControllerStyle.actionSheet);
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil));
        //event handler with closure
        alert.addAction(UIAlertAction(title: "Email", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            self.sendEmail()
        }));
        alert.addAction(UIAlertAction(title: "Twitter", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            self.openTwitter()
        }));
        
        // support popover on iPad
        let pop = alert.popoverPresentationController
        pop?.sourceView = tableView.cellForRow(at: IndexPath(item: 0, section: 1))
        pop?.permittedArrowDirections = UIPopoverArrowDirection.up
        
        present(alert, animated: true, completion: nil);

    }
    
    /// Open the app's twitter support account
    ///
    /// This will open safari if twitter app is not available
    func openTwitter(){
        // twitter app account URL
        let twitterApp = URL(string: "twitter://user?screen_name=kassem_bagher")!
        // twitter website accountr URL
        let twitterWeb = URL(string: "https://twitter.com/kassem_bagher")!
        
        if UIApplication.shared.canOpenURL(twitterApp) {
            UIApplication.shared.open(twitterApp, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(twitterWeb, options: [:], completionHandler: nil)
        }
    }
    /// Compose new email to app support team
    ///
    /// If no email account availabl eon the device, and error message will be displayed
    func sendEmail(){
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: "Ooops! 😮", message: "Please make sure you have setup at least one email account in your device", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // Define a new mail compose controller
        let mail = MFMailComposeViewController()
        
        mail.mailComposeDelegate = self
        
        // Set email recipient and subject (Kassem and Khaled)
        mail.setToRecipients(["s3608985@student.rmit.edu.au","s3613654@student.rmit.edu.au"])
        mail.setSubject("Hi Texpenses Team")
        
        self.present(mail, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // user clicked on cancel in the mail compose view controller
        controller.dismiss(animated: true, completion: nil)
    }
    
    /// Display app version in the tableview footer
    func updateFooter(){
        if let v = tableView.tableFooterView?.viewWithTag(100) {
            let f = v as! UILabel
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            f.text = "Version " + version
        }
    }
    /// Fetche base currency from the database
    func updateCurrency(){
        if let c = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) {
            let userBaseCurrency:UILabel = c.viewWithTag(200) as! UILabel
            if let cur = model.getPreferences()?.userCurrency{
                // base currence is available (selected by the user)
                userBaseCurrency.text = cur.symbol
            }
            else{
                // no base currency has been selected yet
                userBaseCurrency.text = "N/A"
            }
        }
    }
    
}
