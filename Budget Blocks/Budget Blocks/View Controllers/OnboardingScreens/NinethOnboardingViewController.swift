//
//  NinethOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/12/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class NinethOnboardingViewController: UIViewController {

    @IBOutlet weak var amountLabel: UILabel!
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationItem.hidesBackButton = true
    }
    
    
    @IBAction func saveTapped(_ sender: UIButton) {
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
