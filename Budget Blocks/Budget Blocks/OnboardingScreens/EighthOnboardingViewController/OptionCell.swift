//
//  OptionCell.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/12/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

final class OptionCell: UICollectionViewCell {
  
  override var isSelected: Bool {
    didSet {
      categoryLabel.textColor = isSelected ? .white : .black
      amountLabel.textColor = isSelected ? .white : .black
      backgroundColor = isSelected ? #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1) : .secondarySystemBackground
    }
  }
  
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
    lb.textAlignment = .center
    lb.translatesAutoresizingMaskIntoConstraints = false
    return lb
  }()
  
  lazy var categoryImageView: UIImageView = {
    let im = UIImageView()
    
    im.translatesAutoresizingMaskIntoConstraints = false
    return im
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(containerView)
    self.layer.cornerRadius = 20
    self.layer.masksToBounds = true
    self.backgroundColor = UIColor.secondarySystemBackground
    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: self.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
      
    ])
    containerView.addSubview(categoryLabel)
    containerView.addSubview(amountLabel)
    containerView.addSubview(categoryImageView)
    
    NSLayoutConstraint.activate([
      categoryLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      categoryLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      categoryLabel.widthAnchor.constraint(equalToConstant: 200),
      
      amountLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor,constant: 4),
      amountLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
      amountLabel.trailingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
      
      
      categoryImageView.bottomAnchor.constraint(equalTo: categoryLabel.topAnchor,constant: -4),
      categoryImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      categoryImageView.heightAnchor.constraint(equalToConstant: 20),
      categoryImageView.widthAnchor.constraint(equalToConstant: 20)
      
    ])
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
}
