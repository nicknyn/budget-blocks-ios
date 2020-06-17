//
//  SevenOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/10/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class SevenOnboardingViewController: UIViewController {
    var amount: Double?
    
    @IBOutlet weak var actualAmountLabel: UILabel!
    @IBOutlet weak var goalTextField: UITextField! {
        didSet {
            goalTextField.layer.borderWidth = 1.0
            goalTextField.layer.borderColor = #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1)
            goalTextField.keyboardType = .numberPad
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true 
        actualAmountLabel.text = String(amount!) + "$"
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
