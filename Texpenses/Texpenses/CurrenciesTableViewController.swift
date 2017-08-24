//
//  CurrenciesTableViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 23/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

class CurrenciesTableViewController: UITableViewController {

    let currencies = Currency.init().getDummyData()
    
    var selectedCell = 1
    
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currencies.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)

        let currency:UILabel = cell.viewWithTag(100) as! UILabel
        
        currency.text = "\(currencies[indexPath.item].countryName) (\(currencies[indexPath.item].currency))"
        
        if indexPath.item == selectedCell {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.none
        }

        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: IndexPath(row: selectedCell, section: 0))?.accessoryType=UITableViewCellAccessoryType.none
        selectedCell = indexPath.item
        tableView.cellForRow(at: indexPath)?.accessoryType=UITableViewCellAccessoryType.checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popToRootViewController(animated: true)
    }
    
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
