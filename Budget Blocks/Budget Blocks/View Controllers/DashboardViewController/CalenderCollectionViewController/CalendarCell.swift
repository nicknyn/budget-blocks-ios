//
//  CalendarCell.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    
    lazy var monthLabel: UILabel = {
       let lb = UILabel()
        lb.text = "May"
        lb.font = UIFont.boldSystemFont(ofSize: 12)
        lb.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(monthLabel)
        NSLayoutConstraint.activate([
            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
