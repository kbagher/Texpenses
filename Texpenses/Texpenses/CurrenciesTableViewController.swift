//
//  CurrenciesTableViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 23/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

class CurrenciesTableViewController: UITableViewController,WebServicesDelegate {

    let model = Model.sharedInstance
    var currencies = Model.sharedInstance.getCurrencies()
    let web = WebServices.sharedInstance
    
    var oldSelectedCell = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        web.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        if currencies == nil{
            LoadingView.showIndicator("Fetching Currencies From Server")
            web.getCurrencies()
        }
        else{
            loadCurrencies()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        web.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Helping methods
    
    func refreshTable(){
        tableView.reloadData()
    }
    
    func loadCurrencies(){
        currencies = model.getCurrencies()
        DispatchQueue.main.async(execute: {
            self.refreshTable()
        })
    }
    
    func hideActivityView(){
        DispatchQueue.main.async {
            LoadingView.hideIndicator()
        }
    }

    // MARK: Delegates
    func didRetrieveCurrencies(numOfCurrencies: Int){
        print("got currencies")
        hideActivityView()
        loadCurrencies()
    }
    func didRetrieveCurrenciesError(error: NSError){
        hideActivityView()
        let alert = UIAlertController(title: "Error", message: "Cannot retrieve currencies from the server 🙁", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let count = currencies?.count{
            return count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)

        let currency:UILabel = cell.viewWithTag(100) as! UILabel
        let symbol = currencies?[indexPath.item].symbol
        let name = currencies?[indexPath.item].name
        
        currency.text = "\(name!) (\(symbol!))"

        if currencies?[indexPath.item] == model.getPreferences()?.userCurrency {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            oldSelectedCell = indexPath.item
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.none
        }

        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: IndexPath(row: oldSelectedCell, section: 0))?.accessoryType=UITableViewCellAccessoryType.none
        oldSelectedCell = indexPath.item
        model.updatePreferenceWith(BaseCurrency: (currencies?[indexPath.item])!)
        tableView.cellForRow(at: indexPath)?.accessoryType=UITableViewCellAccessoryType.checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popToRootViewController(animated: true)
    }

}
