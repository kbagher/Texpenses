//
//  TransactionDetailsTableViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 22/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

class TransactionDetailsTableViewController: UITableViewController {
    
    let model = Model.sharedInstance
    
    var transaction: Transaction? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.tableFooterView = UIView()
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = transaction {
            let title:UILabel = tableView.tableHeaderView?.viewWithTag(100) as! UILabel
            let location:UILabel = tableView.tableHeaderView?.viewWithTag(200) as! UILabel
            
            // Country expense amount
            let countryCost:UILabel = tableView.cellForRow(at: IndexPath(item: 0, section: 0))?.viewWithTag(200) as! UILabel
            let countryCostLabel:UILabel = tableView.cellForRow(at: IndexPath(item: 0, section: 0))?.viewWithTag(100) as! UILabel
            
            // Base expense amount
            let baseCost:UILabel = tableView.cellForRow(at: IndexPath(item: 1, section: 0))?.viewWithTag(200) as! UILabel
            let baseCostLabel:UILabel = tableView.cellForRow(at: IndexPath(item: 1, section: 0))?.viewWithTag(100) as! UILabel
            
            // exhange rate
            let rate:UILabel = tableView.cellForRow(at: IndexPath(item: 2, section: 0))?.viewWithTag(200) as! UILabel
            
            // Date and time
            let date:UILabel = tableView.cellForRow(at: IndexPath(item: 3, section: 0))?.viewWithTag(200) as! UILabel
            let time:UILabel = tableView.cellForRow(at: IndexPath(item: 4, section: 0))?.viewWithTag(200) as! UILabel
            
            
            
            // Trip information and currency symbol
            let trip = detail.trip
            
            let tripCurrencySymbol = trip?.currency?.symbol
            let baseCurrencySymbol = model.getPreferences()?.userCurrency?.symbol
            
            
            // Title and location
            title.text = detail.title
            location.text = detail.locationName! + ", " + detail.locality! + ", " + (detail.trip?.country)!
            
            // Expense amount and rate
            countryCost.text =  String(detail.amount)
            countryCostLabel.text = "Country's Currency (" + tripCurrencySymbol! + ")"
            
            baseCost.text = String(model.formatDecimalPoints(Number: detail.amount * detail.exchangeRate))
            baseCostLabel.text = "Base Currency (" + baseCurrencySymbol! + ")"
            
            rate.text = String(detail.exchangeRate)
            
            // Transaction date
            date.text = model.format(Date: detail.date! as Date)
            
            // Transaction time
            time.text = model.format(Time: detail.date! as Date)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
}
