//
//  ActivityCell.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {

    lazy var dateLabel: UILabel = {
        let lb = UILabel()
        lb.text = "06/02/20"
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    lazy var activityImage: UIImageView = {
       let im = UIImageView()
        im.image = UIImage(systemName: "wifi")
        im.translatesAutoresizingMaskIntoConstraints = false
        im.widthAnchor.constraint(equalToConstant: 30).isActive = true
        im.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return im
    }()
    
    lazy var activityName: UILabel = {
       let lb = UILabel()
        lb.text = "Whole Food"
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    lazy var amountLabel: UILabel = {
       let lb = UILabel()
        lb.text = "$62.37"
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(activityImage)
        contentView.addSubview(activityName)
        contentView.addSubview(amountLabel)
        
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 16),
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            activityImage.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor,constant: 32),
            activityImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            activityName.leadingAnchor.constraint(equalTo: activityImage.trailingAnchor,constant: 8),
            activityName.centerYAnchor.constraint(equalTo: centerYAnchor),
            
           
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -16),
             amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
