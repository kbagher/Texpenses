//
//  CurrenciesTableViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 23/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

class CurrenciesTableViewController: UITableViewController,WebServicesDelegate {

    // MARK: - Class Variables
    let model = Model.sharedInstance
    var currencies = Model.sharedInstance.getCurrencies()
    let web = TexpensesAPI.sharedInstance
    var oldSelectedCell = 0
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        web.delegate = self
        
        // remove extra empty cells
        tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        // Load currencies
        if currencies == nil{
            // from server
            LoadingView.showIndicator("Fetching Currencies From Server")
            web.getCurrencies()
        }
        else{
            // from local database
            loadCurrencies()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        // release all delegates
        web.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Helping methods
    
    /// Reload table contents in main thread
    func refreshTable(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    /// Load currencies from local database
    func loadCurrencies(){
        currencies = model.getCurrencies()
        refreshTable()
    }
    
    /// Hide activity view in main thread
    func hideActivityView(){
        DispatchQueue.main.async {
            LoadingView.hideIndicator()
        }
    }

    // MARK: - Delegates
    
    /// Handles retreiving currencies delegate
    ///
    /// # See Also:
    /// WebServiceDelegate -> didRetrieveCurrencies()
    func didRetrieveCurrencies(numOfCurrencies: Int){
        print("got currencies")
        hideActivityView()
        loadCurrencies()
    }
    
    /// Handles error while retreiving currencies delegate
    ///
    /// # See Also:
    /// WebServiceDelegate -> didRetrieveCurrenciesError()
    func didRetrieveCurrenciesError(error: NSError){
        
        hideActivityView()
        
        let alert = UIAlertController(title: "Error", message: "Cannot retrieve currencies from the server 🙁", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = currencies?.count{
            return count
        }
        return 0 // no currencies available
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)

        // Grap reference to UI labels
        let currency:UILabel = cell.viewWithTag(100) as! UILabel
        let symbol = currencies?[indexPath.item].symbol
        let name = currencies?[indexPath.item].name
        
        // Format currency label text
        currency.text = "\(name!) (\(symbol!))"

        // Handle user selected base currency checkmark
        if currencies?[indexPath.item] == model.getPreferences()?.userCurrency {
            // the base currency
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            oldSelectedCell = indexPath.item
        }
        else{
            // other curencies
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // remove old checkmark
        tableView.cellForRow(at: IndexPath(row: oldSelectedCell, section: 0))?.accessoryType=UITableViewCellAccessoryType.none
        
        oldSelectedCell = indexPath.item
        
        // update base currency in the database
        model.updatePreferenceWith(BaseCurrency: (currencies?[indexPath.item])!)
        
        // set checkmark on new selected currency
        tableView.cellForRow(at: indexPath)?.accessoryType=UITableViewCellAccessoryType.checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        
        // navigating back to previous view
        navigationController?.popToRootViewController(animated: true)
    }

}
