//
//  SummaryCollectionViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 22/8/17.
//  Updated by Khaled Dowaid on 1/10/2017
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SummaryCollectionViewController: UICollectionViewController {

    // MARK: Class Variables
    
    var summaries: [Summary]?
    let model = Model.sharedInstance

    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Retrieve trips summaries
        getSummaries()
    }

    override func viewWillAppear(_ animated: Bool) {
        // refresh summaries
        getSummaries()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let sum = summaries{
            return sum.count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summaryCell", for: indexPath)

        // Retrieve UI labels Reference
        let countryName:UILabel = cell.viewWithTag(100)! as! UILabel
        let date:UILabel = cell.viewWithTag(200)! as! UILabel
        let baseCurrency:UILabel = cell.viewWithTag(300)! as! UILabel
        let baseExpenses:UILabel = cell.viewWithTag(400)! as! UILabel
        let countryCurrency:UILabel = cell.viewWithTag(500)! as! UILabel
        let countryExpenses:UILabel = cell.viewWithTag(600)! as! UILabel
        let exchangeRate:UILabel = cell.viewWithTag(700)! as! UILabel
        
        // Grap trip summary object
        if let sum = summaries?[indexPath.item]{
            countryName.text = sum.countryName
            countryExpenses.text = sum.countryExpenses
            countryCurrency.text = sum.countryCurrency
            date.text = sum.fromDate + " - " + sum.toDate
            baseCurrency.text = sum.baseCurrency
            baseExpenses.text = sum.baseExpenses
            if sum.countryExpenses == "0.0"{
                // No expenses available for the trip
                exchangeRate.text = "Average exchange rate (N/A)"
            }
            else{
                exchangeRate.text = "Average exchange rate 1 " + sum.countryCurrency + " = " + sum.exchangeRate + " " + sum.baseCurrency
            }
        }

        // Set cell style
        setStyleForCell(cell: cell)
        
        return cell
    }

    // MARK: - Helping methods
    
    /// Style UiCollectionViewCell
    ///
    /// This will style the UiCollectionViewCell to have rounded corners and light gray border
    ///
    /// - Parameter tf: UITextField to style
    func setStyleForCell(cell: UICollectionViewCell){
        cell.contentView.layer.masksToBounds = false
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.00).cgColor
        cell.contentView.layer.borderColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00).cgColor
        cell.contentView.layer.shadowColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00).cgColor
        cell.contentView.layer.shadowRadius = 10
        cell.contentView.layer.shadowOpacity = 0.5
        cell.contentView.layer.shadowOffset = CGSize.zero
    }
    
    /// Retrieve trips summaries from database
    func getSummaries(){
        // Sort by latest
        summaries = model.getTripsSummaries()?.reversed()
        
        collectionView?.reloadData()
    }
    
}
