//
//  DashboardViewController.swift
//  Texpenses
//
//  Created by Kassem Bagher on 24/8/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var currency: UIView?
    @IBOutlet weak var expenses: UIView?
    @IBOutlet weak var exchangeRate: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setStyleFor(view: currency!)
        setStyleFor(view: exchangeRate!)
        setStyleFor(view: expenses!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setStyleFor(view v:UIView) {
        // Cell desing (border and background color
        v.layer.masksToBounds = true
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 12
        v.layer.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0).cgColor
        v.layer.borderColor = UIColor.lightGray.cgColor
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
