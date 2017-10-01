//
//  SummaryCollectionViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 22/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SummaryCollectionViewController: UICollectionViewController {

    var summaries: [Summary]?
    let model = Model.sharedInstance

    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.
        getSummaries()
    }

    override func viewWillAppear(_ animated: Bool) {
        getSummaries()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

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

        
        let countryName:UILabel = cell.viewWithTag(100)! as! UILabel
        let date:UILabel = cell.viewWithTag(200)! as! UILabel
        let baseCurrency:UILabel = cell.viewWithTag(300)! as! UILabel
        let baseExpenses:UILabel = cell.viewWithTag(400)! as! UILabel
        let countryCurrency:UILabel = cell.viewWithTag(500)! as! UILabel
        let countryExpenses:UILabel = cell.viewWithTag(600)! as! UILabel
        let exchangeRate:UILabel = cell.viewWithTag(700)! as! UILabel
        

        if let sum = summaries?[indexPath.item]{
            countryName.text = sum.countryName
            countryExpenses.text = sum.countryExpenses
            countryCurrency.text = sum.countryCurrency
            date.text = sum.fromDate + " - " + sum.toDate
            baseCurrency.text = sum.baseCurrency
            baseExpenses.text = sum.baseExpenses
            if sum.countryExpenses == "0.0"{
                exchangeRate.text = "Average exchange rate (N/A)"
            }
            else{
                exchangeRate.text = "Average exchange rate 1 " + sum.countryCurrency + " = " + sum.exchangeRate + " " + sum.baseCurrency
            }
        }

        // Configure the cell
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0).cgColor
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
    
        return cell
    }

    // MARK: - Helping methods
    func getSummaries(){
        summaries = model.getTripsSummaries()?.reversed()
        collectionView?.reloadData()
    }
    
}
