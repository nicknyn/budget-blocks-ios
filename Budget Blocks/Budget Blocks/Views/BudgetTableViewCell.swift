//
//  BudgetTableViewCell.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/10/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let textSize = textField.font?.pointSize {
            textField.font = UIFont(name: "Exo-Regular", size: textSize)
        }
    }
}
