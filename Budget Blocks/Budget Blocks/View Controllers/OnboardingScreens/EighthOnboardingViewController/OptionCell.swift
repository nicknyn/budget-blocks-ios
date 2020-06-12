//
//  OptionCell.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/12/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class OptionCell: UICollectionViewCell {
    
    let containerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
      
        return view
    }()
    lazy var categoryLabel: UILabel = {
       let lb = UILabel()
        lb.text = "Dummy"
        lb.textAlignment = .center
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    lazy var amountLabel: UILabel = {
       let lb = UILabel()
        lb.text = "Dummy 600"
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    lazy var optionImageView: UIImageView = {
       let im = UIImageView()
        im.image = UIImage(systemName: "shift")
        im.translatesAutoresizingMaskIntoConstraints = false
        return im
    }()
      
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        
        ])
        containerView.addSubview(categoryLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(optionImageView)
        
        NSLayoutConstraint.activate([
            categoryLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            categoryLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            categoryLabel.widthAnchor.constraint(equalToConstant: 100),
            
            amountLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor,constant: 4),
            amountLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
            
           
            optionImageView.bottomAnchor.constraint(equalTo: categoryLabel.topAnchor,constant: -4),
            optionImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            optionImageView.heightAnchor.constraint(equalToConstant: 30),
            optionImageView.widthAnchor.constraint(equalToConstant: 30)
        
        ])
    }
 
    required init?(coder: NSCoder) {
        super.init(coder: coder)
     
    }
}
