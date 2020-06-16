//
//  PageHorizontalCell.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class BudgetScreen: UICollectionViewCell  {

    let blocksDataSource = BlocksDataSource()
    let calenderDataSource = CalenderDatasource()
    let categoryDataSource = CategoryTableViewDataSource()
        
    lazy var containerCellView: UIView = {
       let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var calenderCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect(x: 0, y:0, width: 0, height: 0), collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.delegate = calenderDataSource
        cv.dataSource = calenderDataSource
        cv.register(CalendarCell.self, forCellWithReuseIdentifier: "Hello")
        cv.heightAnchor.constraint(equalToConstant: 80).isActive = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    lazy var blocksCollectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0),collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white // red
        collectionView.dataSource = blocksDataSource
        collectionView.delegate = blocksDataSource
        collectionView.register(BlockCell.self, forCellWithReuseIdentifier: "HEHE")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
//        collectionView.isScrollEnabled = false
        
        return collectionView
    }()
    
    lazy var blocksView: UIView = {
       let view = UIView()
        view.backgroundColor = .white // orange before
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 140).isActive = true
        return view
    }()
    
    lazy var blockLabel: UILabel = {
       let lb = UILabel()
        lb.text = "Blocks"
        lb.textAlignment = .left
        lb.backgroundColor = .white //brown
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    lazy var categoryContainerView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var incomeLabel: UILabel = {
       let lb = UILabel()
        lb.text = "Income: $4,170"
        lb.textColor = .black
        lb.backgroundColor = .white // orange
        lb.widthAnchor.constraint(equalToConstant: 200).isActive = true
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    lazy var categoryTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.tableFooterView = UIView()
        tv.backgroundColor = .red
        tv.dataSource = categoryDataSource
        tv.separatorStyle = .none
        tv.isScrollEnabled = false
        tv.delegate = categoryDataSource
        tv.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        return tv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerCellView)
        
        containerCellView.addSubview(calenderCollectionView)
        containerCellView.addSubview(blocksView)
        containerCellView.addSubview(categoryContainerView)
        categoryContainerView.addSubview(incomeLabel)
        categoryContainerView.addSubview(categoryTableView)
        
        blocksView.addSubview(blockLabel)
        blocksView.addSubview(blocksCollectionView)
        
        NSLayoutConstraint.activate([
            containerCellView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerCellView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerCellView.topAnchor.constraint(equalTo: topAnchor),
            containerCellView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            calenderCollectionView.topAnchor.constraint(equalTo: containerCellView.topAnchor),
            calenderCollectionView.leadingAnchor.constraint(equalTo: containerCellView.leadingAnchor),
            calenderCollectionView.trailingAnchor.constraint(equalTo: containerCellView.trailingAnchor),
            
            blocksView.topAnchor.constraint(equalTo: calenderCollectionView.bottomAnchor,constant: 1),
            blocksView.leadingAnchor.constraint(equalTo: containerCellView.leadingAnchor),
            blocksView.trailingAnchor.constraint(equalTo: containerCellView.trailingAnchor),
            
            blockLabel.leadingAnchor.constraint(equalTo: blocksView.leadingAnchor,constant: 16),
            blockLabel.topAnchor.constraint(equalTo: blocksView.topAnchor,constant: 20),
            
            blocksCollectionView.topAnchor.constraint(equalTo: blockLabel.bottomAnchor,constant: 0),
            blocksCollectionView.leadingAnchor.constraint(equalTo: blocksView.leadingAnchor,constant: 16),
            blocksCollectionView.trailingAnchor.constraint(equalTo: blocksView.trailingAnchor),
            blocksCollectionView.bottomAnchor.constraint(equalTo: blocksView.bottomAnchor,constant: -16),
            
            categoryContainerView.topAnchor.constraint(equalTo: blocksView.bottomAnchor,constant: 1),
            categoryContainerView.leadingAnchor.constraint(equalTo: containerCellView.leadingAnchor),
            categoryContainerView.trailingAnchor.constraint(equalTo: containerCellView.trailingAnchor),
            categoryContainerView.bottomAnchor.constraint(equalTo: containerCellView.bottomAnchor),
        
            incomeLabel.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor,constant: 16),
            incomeLabel.topAnchor.constraint(equalTo: categoryContainerView.topAnchor,constant: 16),
            
            categoryTableView.bottomAnchor.constraint(equalTo: categoryContainerView.bottomAnchor),
            categoryTableView.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor),
            categoryTableView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor),
            categoryTableView.topAnchor.constraint(equalTo: incomeLabel.bottomAnchor,constant: 16)
            
            
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

