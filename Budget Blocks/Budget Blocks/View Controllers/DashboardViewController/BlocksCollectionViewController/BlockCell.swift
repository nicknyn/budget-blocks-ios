//
//  BlockCell.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class BlockCell: UICollectionViewCell {
    
    lazy var blockButton: UIButton = {
       let button = UIButton()
       
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
        
        
        backgroundColor = UIColor.secondarySystemBackground
        addSubview(blockButton)
        
        NSLayoutConstraint.activate([
            blockButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            blockButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
