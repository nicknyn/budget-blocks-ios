//
//  CategoryCell.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    lazy var categoryImageView: UIImageView = {
       let im = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        im.translatesAutoresizingMaskIntoConstraints = false
        im.image = UIImage(systemName: "heart")
        im.widthAnchor.constraint(equalToConstant: 30).isActive = true
        im.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return im
    }()
    
    lazy var categoryName: UILabel = {
       let lb = UILabel()
        lb.text = "House"
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    lazy var amountLabel: UILabel = {
        let lb = UILabel()
        lb.text = "$1,200"
        lb.textColor = .darkGray
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
  
    lazy var categoryProgressView: UIProgressView = {
       let view = UIProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.3882825077, green: 0.6711806059, blue: 0.5451156497, alpha: 1)
        view.progressTintColor = .red
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(categoryImageView)
        contentView.addSubview(categoryName)
        contentView.addSubview(amountLabel)
        contentView.addSubview(categoryProgressView)
        
        
        
        NSLayoutConstraint.activate([
            categoryImageView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 16),
//            categoryImageView.topAnchor.constraint(equalTo: topAnchor,constant: 16),
            categoryImageView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -16),
            
            categoryName.leadingAnchor.constraint(equalTo: categoryImageView.trailingAnchor,constant: 8),
            categoryName.topAnchor.constraint(equalTo: topAnchor,constant: 16),
            categoryName.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -16),
            
            amountLabel.leadingAnchor.constraint(equalTo: categoryName.trailingAnchor,constant: 32),
            amountLabel.topAnchor.constraint(equalTo: topAnchor,constant: 16),
            amountLabel.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -16),
            
            categoryProgressView.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor,constant: 16),
            categoryProgressView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -16),
            categoryProgressView.topAnchor.constraint(equalTo: topAnchor,constant: 16),
            categoryProgressView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -16)
            
        ])
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
