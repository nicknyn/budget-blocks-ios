//
//  EmbeddedViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/11/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class EmbeddedViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var incomeAmounLabel: UILabel! {
        didSet {
            incomeAmounLabel.text = String(NetworkingController.shared.census!.income.rounded()) + "$"
        }
    }
    
     public var amount: Double? {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                return NetworkingController.shared.census!.income.rounded()
            case 1 :
                return NetworkingController.shared.census!.income.rounded() / 4
            default:
            break
        }
        return nil
        
    }
    
    
    @IBAction func segmentSwitched(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
            incomeAmounLabel.text = String(NetworkingController.shared.census!.income.rounded()) + "$"
            case 1:
            incomeAmounLabel.text = String(NetworkingController.shared.census!.income.rounded() / 4) + "$"
            default:
            break
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

   
}
