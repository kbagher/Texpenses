//
//  TransactionsTableViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 22/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

class TransactionsTableViewController: UITableViewController,UISplitViewControllerDelegate {

    var transactions = [Transaction]()
    let model = Model.sharedInstance
    @IBOutlet weak var country: UILabel!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        if let t = model.getCurrentActiveTrip(){
            
            country.text = t.country
            
            if let tr = t.transactions{
                transactions = tr.array as! [Transaction]
            }
        }
        
        // display master and details on iPad
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        self.splitViewController?.delegate = self
        splitViewController?.presentsWithGesture = false
        
        tableView.tableFooterView = UIView()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        updateTransactions()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    // delete the selected row
    
    func deleteRow(atIndexPath index:[IndexPath]) {
        tableView.deleteRows(at: index, with: UITableViewRowAnimation.automatic)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return transactions.count
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
  

    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            deleteRow(atIndexPath: [indexPath as IndexPath])
            tableView.endUpdates()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)
        
        let title:UILabel = cell.viewWithTag(100) as! UILabel
        let price:UILabel = cell.viewWithTag(200) as! UILabel
        var cSymbol = ""
        
        if let t = model.getCurrentActiveTrip(){
            cSymbol = model.getCurrencySymbolFor(CurrencyCode: (t.currency?.symbol)!)
        }
        
        title.text = transactions[indexPath.item].title
        price.text = cSymbol + String(transactions[indexPath.item].amount)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTransactionDetails", sender: indexPath.row)
        if (self.splitViewController?.isCollapsed)! {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Helping methods
    func updateTransactions(){
        if let t = model.getCurrentActiveTrip(){
            if let tr = t.transactions{
                transactions = tr.array as! [Transaction]
                transactions = transactions.reversed()
            }
        }
    }
    
    // MARK: - Navigation and Split View

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? TransactionDetailsTableViewController else { return false }
        if topAsDetailController.transaction == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showTransactionDetails" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationNavigationController = segue.destination as! UINavigationController
                let dist = destinationNavigationController.topViewController as! TransactionDetailsTableViewController
                dist.transaction = transactions[indexPath.item]
                
                self.tabBarController?.tabBar.isHidden = (self.splitViewController?.isCollapsed)!
            }
        }
        
    }
 

}
