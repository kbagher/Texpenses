//
//  TransactionsTableViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 22/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

class TransactionsTableViewController: UITableViewController,UISplitViewControllerDelegate {
    
    // MARK: - Class Variables
    var transactions = [Transaction]()
    let model = Model.sharedInstance
    
    @IBOutlet weak var country: UILabel!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Current active trip
        if let t = model.getCurrentActiveTrip(){
            
            country.text = t.country
            
            // trips's transactions
            if let tr = t.transactions{
                transactions = tr.array as! [Transaction]
            }
        }
        
        // Always show master and details on iPad
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        self.splitViewController?.delegate = self
        self.splitViewController?.presentsWithGesture = false
        self.tableView.allowsSelectionDuringEditing = false
        
        // remove extra empty cells
        tableView.tableFooterView = UIView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Show tabbar before
        self.tabBarController?.tabBar.isHidden = false
        updateTransactions()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // enable row editing (deleting)
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // delete from database
            model.deleteTransaction(transactions[indexPath.item])
            
            // delete from array
            transactions.remove(at: indexPath.row)
            
            // delete from table
            tableView.deleteRows(at: [indexPath], with: .left)
            
            tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)
        
        // grap reference to UI labels
        let title:UILabel = cell.viewWithTag(100) as! UILabel
        let price:UILabel = cell.viewWithTag(200) as! UILabel
        
        // currency symbol
        var cSymbol = ""
        if let t = model.getCurrentActiveTrip(){
            cSymbol = model.getCurrencySymbolFor(CurrencyCode: (t.currency?.symbol)!)
        }
        
        // Transaction information
        title.text = transactions[indexPath.item].title
        price.text = cSymbol + String(transactions[indexPath.item].amount)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // navigate to transaction details
        performSegue(withIdentifier: "showTransactionDetails", sender: indexPath.row)
        
        // deselect the row on iPhones and keep the selection on iPads
        if (self.splitViewController?.isCollapsed)! {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Helping methods
    
    /// Retrieve transactions from database
    func updateTransactions(){
        if let t = model.getCurrentActiveTrip(){
            if let tr = t.transactions{
                transactions = tr.array as! [Transaction]
                transactions = transactions.reversed()
            }
        }
    }
    
    // MARK: - Navigation and Split View
    
    /// Set the master (Transactions) as the main view
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? TransactionDetailsTableViewController else { return false }
        if topAsDetailController.transaction == nil {
            return true
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected transaction to the transaction details view
        if segue.identifier == "showTransactionDetails" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationNavigationController = segue.destination as! UINavigationController
                let dist = destinationNavigationController.topViewController as! TransactionDetailsTableViewController
                dist.transaction = transactions[indexPath.item]
                
                // hide tabbar before navigating to the details view
                self.tabBarController?.tabBar.isHidden = (self.splitViewController?.isCollapsed)!
            }
        }
        
    }
    
}
