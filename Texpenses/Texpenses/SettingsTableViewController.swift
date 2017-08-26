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

    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userBaseCurrency:UILabel = tableView.cellForRow(at: IndexPath(item: 0, section: 0))?.viewWithTag(200) as! UILabel
        userBaseCurrency.text = UserSettings.sharedInstance.getBaseCurrency()?.currency
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        default:
            return 2
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "showCurrencies", sender: nil)
        default:
            switch indexPath.item {
            case 0:
                sendEmail()
            default:
                shareApp()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Other functions
    
    func shareApp() {
        
        let txt = "Best app to track your expenses while travelling 😍"
        let url = NSURL(string: "https://itunes.apple.com/au/app/%D8%B4%D9%88%D8%A7%D8%B1%D8%B9-%D8%AC%D8%AF%D8%A9/id1031487168?mt=8")
        
        let shareContent = [ txt,url!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func sendEmail(){
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: "Ooops! 😮", message: "Please make sure you have setup at least one email account in your device", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let mail = MFMailComposeViewController()
        
        mail.mailComposeDelegate = self
        
        mail.setToRecipients(["s3608985@student.rmit.edu.au","s3613654@student.rmit.edu.au"])
        mail.setSubject("Hi Texpenses Team")
        
        self.present(mail, animated: true, completion: nil)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
