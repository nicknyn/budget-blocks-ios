//
//  CategoryTableViewCell.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/10/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let textSize = titleLabel.font.pointSize
        titleLabel.font = UIFont(name: "Exo-Regular", size: textSize)
        
        backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
