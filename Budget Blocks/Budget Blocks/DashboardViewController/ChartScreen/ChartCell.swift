//
//  ChartCell.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import Charts

class ChartCell: UICollectionViewCell {
    
    private let activityDataSource = ActivityDataSource()
    
    lazy var containerCellView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var iosDataEntry : PieChartDataEntry = {
        let iosDataEntry = PieChartDataEntry(value: 20)
        iosDataEntry.value = 60.0
        iosDataEntry.label = "iOS"
        return iosDataEntry
    }()
    
    lazy var macDataEntry : PieChartDataEntry = {
        let macDataEntry = PieChartDataEntry(value: 20)
        macDataEntry.value = 100.0
        macDataEntry.label = "macOS"
        return macDataEntry
    }()
    
    lazy var tvOSDataEntry : PieChartDataEntry = {
        let macDataEntry = PieChartDataEntry(value: 20)
        macDataEntry.value = 80.0
        macDataEntry.label = "macOS"
        
        
        return macDataEntry
    }()
    
    var numberOfDownloadsDataEntries = [PieChartDataEntry]()
    
    
    lazy var pieChartView : PieChartView = {
        let chart = PieChartView()
        chart.backgroundColor = .white
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    private func updateChartData() {
        let chartDataSet = PieChartDataSet(entries: numberOfDownloadsDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1),#colorLiteral(red: 0.6909318566, green: 0.7678380609, blue: 0.870224297, alpha: 1),#colorLiteral(red: 0.5790472627, green: 0.9850887656, blue: 0.8092169166, alpha: 1)]
        chartDataSet.colors = colors
        pieChartView.data = chartData
    }
    
    lazy var activityTableView: UITableView = {
      
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.tableFooterView = UIView()
        tv.backgroundColor = .white // red
        tv.dataSource = activityDataSource
        tv.delegate = activityDataSource
        tv.separatorStyle = .singleLine
        
        
        tv.register(ActivityCell.self, forCellReuseIdentifier: "ActivityCell")
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerCellView)
        containerCellView.addSubview(pieChartView)
        containerCellView.addSubview(activityTableView)
        pieChartView.chartDescription?.text = "TRANSACTION"
        
        numberOfDownloadsDataEntries = [iosDataEntry,macDataEntry,tvOSDataEntry]
        updateChartData()
        
        NSLayoutConstraint.activate([
            containerCellView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerCellView.topAnchor.constraint(equalTo: topAnchor),
            containerCellView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerCellView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            pieChartView.topAnchor.constraint(equalTo: containerCellView.topAnchor),
            pieChartView.leadingAnchor.constraint(equalTo: containerCellView.leadingAnchor),
            pieChartView.trailingAnchor.constraint(equalTo: containerCellView.trailingAnchor),
            pieChartView.heightAnchor.constraint(equalToConstant: 300),
            
            
            activityTableView.topAnchor.constraint(equalTo: pieChartView.bottomAnchor,constant: 32),
            activityTableView.leadingAnchor.constraint(equalTo: containerCellView.leadingAnchor),
            activityTableView.trailingAnchor.constraint(equalTo: containerCellView.trailingAnchor),
            activityTableView.bottomAnchor.constraint(equalTo: containerCellView.bottomAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
