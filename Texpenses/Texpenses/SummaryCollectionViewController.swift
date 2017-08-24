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

    var items = Summary.init().getDummyData()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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
        return items.count
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
        

        countryName.text = items[indexPath.item].countryName
        countryExpenses.text = items[indexPath.item].countryExpenses
        countryCurrency.text = items[indexPath.item].countryCurrency
        date.text = items[indexPath.item].fromDate + " - " + items[indexPath.item].toDate
        baseCurrency.text = items[indexPath.item].baseCurrency
        baseExpenses.text = items[indexPath.item].baseExpenses
        exchangeRate.text = "Average exchange rate 1 " + items[indexPath.item].countryCurrency + " = " + items[indexPath.item].exchangeRate + " " + items[indexPath.item].baseCurrency

        // Configure the cell
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0).cgColor
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor

    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
