//
//  BudgetBlockCell.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/19/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class BudgetBlockCell: UITableViewCell {
  
  
  @IBOutlet weak var categoryImageView: UIImageView!
  @IBOutlet weak var categoryNameLabel: UILabel!
  @IBOutlet weak var actualAmountLabel: UILabel!
  @IBOutlet weak var goalTextField: UITextField!
  @IBOutlet weak var saveButton: UIButton!
  
  
  @IBAction func savebuttonTapped(_ sender: UIButton) {
    
  }
}
