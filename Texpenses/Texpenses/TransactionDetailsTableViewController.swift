//
//  TransactionDetailsTableViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 22/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

class TransactionDetailsTableViewController: UITableViewController {
    
    // MARK: - Class Variables
    let model = Model.sharedInstance
    
    var transaction: Transaction? {
        didSet {
            // present data on view once variable updated
            displayInformation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove extra empty cells
        tableView.tableFooterView = UIView()
    }

    /// Display transaction details on UI
    func displayInformation() {
        if let detail = transaction { // transaction not nil
            
            /////////////// Reference to UI Labels ///////////////
            
            // Title and location labels
            let title:UILabel = tableView.tableHeaderView?.viewWithTag(100) as! UILabel
            let location:UILabel = tableView.tableHeaderView?.viewWithTag(200) as! UILabel

            // trip currency expense amount label
            let countryCost:UILabel = tableView.cellForRow(at: IndexPath(item: 0, section: 0))?.viewWithTag(200) as! UILabel
            let countryCostLabel:UILabel = tableView.cellForRow(at: IndexPath(item: 0, section: 0))?.viewWithTag(100) as! UILabel
            
            // base currency expense amount label
            let baseCost:UILabel = tableView.cellForRow(at: IndexPath(item: 1, section: 0))?.viewWithTag(200) as! UILabel
            let baseCostLabel:UILabel = tableView.cellForRow(at: IndexPath(item: 1, section: 0))?.viewWithTag(100) as! UILabel
            
            // exhange rate label
            let rate:UILabel = tableView.cellForRow(at: IndexPath(item: 2, section: 0))?.viewWithTag(200) as! UILabel
            
            // date and time label
            let date:UILabel = tableView.cellForRow(at: IndexPath(item: 3, section: 0))?.viewWithTag(200) as! UILabel
            let time:UILabel = tableView.cellForRow(at: IndexPath(item: 4, section: 0))?.viewWithTag(200) as! UILabel
            
            //////////////////////////////////////////////////////
            
            
            /////////////// Setting Variables ///////////////
            
            // transaction's trip
            let trip = detail.trip
            
            // trip and base currencies symbol data
            let tripCurrencySymbol = trip?.currency?.symbol
            let baseCurrencySymbol = model.getPreferences()?.userCurrency?.symbol
            
            
            // title and location data
            title.text = detail.title
            location.text = detail.locationName! + ", " + detail.locality! + ", " + (detail.trip?.country)!
            
            // trip currency expense amount data
            countryCost.text =  String(detail.amount)
            countryCostLabel.text = "Country's Currency (" + tripCurrencySymbol! + ")"

            // base currency currency expense amount data
            baseCost.text = String(model.formatDecimalPoints(Number: detail.amount * detail.exchangeRate))
            baseCostLabel.text = "Base Currency (" + baseCurrencySymbol! + ")"
            
            // exchange rate data
            rate.text = String(detail.exchangeRate)
            
            // Transaction date
            date.text = model.format(Date: detail.date! as Date)
            
            // Transaction time
            time.text = model.format(Time: detail.date! as Date)
            
            
            /////////////////////////////////////////////////
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}
