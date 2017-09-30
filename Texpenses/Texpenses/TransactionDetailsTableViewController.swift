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
            let countryCost:UILabel = tableView.cellForRow(at: IndexPath(item: 0, section: 0))?.viewWithTag(200) as! UILabel
            let baseCost:UILabel = tableView.cellForRow(at: IndexPath(item: 1, section: 0))?.viewWithTag(200) as! UILabel
            let rate:UILabel = tableView.cellForRow(at: IndexPath(item: 2, section: 0))?.viewWithTag(200) as! UILabel
            let date:UILabel = tableView.cellForRow(at: IndexPath(item: 3, section: 0))?.viewWithTag(200) as! UILabel
            let time:UILabel = tableView.cellForRow(at: IndexPath(item: 4, section: 0))?.viewWithTag(200) as! UILabel
            
            print(detail)
            
            // Trip information and currency symbol
            let trip = detail.trip
            
            let tripCurrencySymbol = model.getCurrencySymbolFor(CurrencyCode: (trip?.currency?.symbol)!)
            let baseCurrencySymbol = model.getCurrencySymbolFor(CurrencyCode: (model.getPreferences()?.userCurrency?.symbol)!)
            
            
            // Title and location
            title.text = detail.title
            location.text = detail.locationName! + ", " + detail.locality! + ", " + (detail.trip?.country)!
            
            // Expense amount and rate
            countryCost.text =  tripCurrencySymbol + String(detail.amount)
            baseCost.text = baseCurrencySymbol + String(detail.amount * detail.exchangeRate)
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

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
