//
//  ChartViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 5/30/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import UIKit
import Charts

class ChartViewController: UIViewController {
  
  lazy var iosDataEntry : PieChartDataEntry = {
    let iosDataEntry   = PieChartDataEntry(value: 20)
    iosDataEntry.value = 60.0
    iosDataEntry.label = "Ice Cream"
    return iosDataEntry
  }()
  
  lazy var macDataEntry : PieChartDataEntry = {
    let macDataEntry   = PieChartDataEntry(value: 20)
    macDataEntry.value = 100.0
    macDataEntry.label = "Rent"
    return macDataEntry
  }()
  
  lazy var tvOSDataEntry : PieChartDataEntry = {
    let macDataEntry   = PieChartDataEntry(value: 20)
    macDataEntry.value = 80.0
    macDataEntry.label = "Gas"
    
    
    return macDataEntry
  }()
  
  var numberOfDownloadsDataEntries = [PieChartDataEntry]()
  
  
  lazy var pieChartView : PieChartView = {
    let chart = PieChartView()
    chart.translatesAutoresizingMaskIntoConstraints = false
    return chart
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(pieChartView)
    pieChartView.chartDescription?.text = "TRANSACTION"
    
    numberOfDownloadsDataEntries        = [iosDataEntry,macDataEntry,tvOSDataEntry]
    updateChartData()
    setupUI()
  }
  
  private func updateChartData() {
    let chartDataSet    = PieChartDataSet(entries: numberOfDownloadsDataEntries, label: nil)
    let chartData       = PieChartData(dataSet: chartDataSet)
    
    let colors          = [#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1),#colorLiteral(red: 0.6909318566, green: 0.7678380609, blue: 0.870224297, alpha: 1),#colorLiteral(red: 0.5790472627, green: 0.9850887656, blue: 0.8092169166, alpha: 1)]
    chartDataSet.colors = colors 
    pieChartView.data   = chartData
  }
  
  
  private func setupUI() {
    NSLayoutConstraint.activate([
      pieChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 50),
      pieChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -50),
      pieChartView.topAnchor.constraint(equalTo: view.topAnchor,constant: 50),
      pieChartView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -50)
    ])
  }
}
