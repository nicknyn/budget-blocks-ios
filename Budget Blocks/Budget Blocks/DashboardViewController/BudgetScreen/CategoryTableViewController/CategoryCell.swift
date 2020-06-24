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
    im.widthAnchor.constraint(equalToConstant: 20).isActive = true
    im.heightAnchor.constraint(equalToConstant: 20).isActive = true
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
    view.backgroundColor = #colorLiteral(red: 0.7001445293, green: 0.9239938855, blue: 0.916201055, alpha: 1)
    view.progressTintColor = #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1)
   
    view.layer.cornerRadius = 4
    view.clipsToBounds = true
    view.layer.sublayers![1].cornerRadius = 4
    view.subviews[1].clipsToBounds = true
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
      categoryImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      //      categoryImageView.topAnchor.constraint(equalTo: topAnchor,constant: 16),
      //      categoryImageView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -16),
      
      categoryName.leadingAnchor.constraint(equalTo: categoryImageView.trailingAnchor,constant: 8),
      categoryName.centerYAnchor.constraint(equalTo: centerYAnchor),
      
      amountLabel.trailingAnchor.constraint(equalTo: categoryProgressView.leadingAnchor,constant: -8),
      amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      
      //      categoryProgressView.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor,constant: 16),
      categoryProgressView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -16),
      categoryProgressView.widthAnchor.constraint(equalToConstant: 180),
      categoryProgressView.centerYAnchor.constraint(equalTo: centerYAnchor),
      categoryProgressView.heightAnchor.constraint(equalToConstant: 20)
      
    ])
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}
