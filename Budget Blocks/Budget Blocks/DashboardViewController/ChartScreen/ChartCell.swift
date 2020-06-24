//
//  ChartCell.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import Charts
import CoreData

class ChartCell: UICollectionViewCell {
  
  private lazy var fetchedResultsController: NSFetchedResultsController<DataScienceTransaction> = {
    let fetchRequest: NSFetchRequest<DataScienceTransaction> = DataScienceTransaction.fetchRequest()
    
    fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "date", ascending: false)]
    
    let context = CoreDataStack.shared.mainContext
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: context,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
    frc.delegate = self
    
    do {
      try frc.performFetch()
      
    } catch {
      fatalError("Error fetching transactions: \(error)")
    }
    
    return frc
  }()
  
  lazy var containerCellView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  
  lazy var lineChartView : LineChartView = {
    let chart = LineChartView()
    chart.backgroundColor = .white
    chart.delegate = self
  
    chart.translatesAutoresizingMaskIntoConstraints = false
    return chart
  }()

 
  
  lazy var activityTableView: UITableView = {
    
    let tv = UITableView(frame: .zero, style: .plain)
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.tableFooterView = UIView()
    tv.backgroundColor = .white // red
    tv.dataSource = self
    tv.delegate = self
    tv.separatorStyle = .singleLine
    
    
    tv.register(ActivityCell.self, forCellReuseIdentifier: "ActivityCell")
    return tv
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(containerCellView)
    containerCellView.addSubview(lineChartView)
    containerCellView.addSubview(activityTableView)
    lineChartView.chartDescription?.text = "TRANSACTION"
    
    var entries = [ChartDataEntry]()
    
    entries.append(ChartDataEntry(x: 200, y: 300))
    entries.append(ChartDataEntry(x: 200, y: 200, data: "Jan"))
    
    let set = LineChartDataSet(entries: entries)
    set.colors = ChartColorTemplates.material()
    let data = LineChartData(dataSet: set)
    lineChartView.data = data
    
    
    
    NSLayoutConstraint.activate([
      containerCellView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerCellView.topAnchor.constraint(equalTo: topAnchor),
      containerCellView.trailingAnchor.constraint(equalTo: trailingAnchor),
      containerCellView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      lineChartView.topAnchor.constraint(equalTo: containerCellView.topAnchor),
      lineChartView.leadingAnchor.constraint(equalTo: containerCellView.leadingAnchor),
      lineChartView.trailingAnchor.constraint(equalTo: containerCellView.trailingAnchor),
      lineChartView.heightAnchor.constraint(equalToConstant: 300),
      
      
      activityTableView.topAnchor.constraint(equalTo: lineChartView.bottomAnchor,constant: 32),
      activityTableView.leadingAnchor.constraint(equalTo: containerCellView.leadingAnchor),
      activityTableView.trailingAnchor.constraint(equalTo: containerCellView.trailingAnchor),
      activityTableView.bottomAnchor.constraint(equalTo: containerCellView.bottomAnchor)
    ])
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}
extension ChartCell: ChartViewDelegate {
  
}
extension ChartCell :  UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Recent Activity"
  }
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    header.backgroundView?.backgroundColor = .white
    header.textLabel?.textColor = .black
    header.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return fetchedResultsController.fetchedObjects?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
    let transaction = fetchedResultsController.object(at: indexPath)
    
    cell.dateLabel.text = transaction.date
    
    cell.activityName.text = transaction.name
    cell.amountLabel.text = String(transaction.amount) + "$"
    cell.amountLabel.textColor = transaction.amount > 0 ? #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1) : .red
   
    
    
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension ChartCell: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    activityTableView.beginUpdates()
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    activityTableView.endUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    let indexSet = IndexSet(integer: sectionIndex)
    
    switch type {
      case .insert:
        activityTableView.insertSections(indexSet, with: .automatic)
      case .delete:
        activityTableView.deleteSections(indexSet, with: .automatic)
      default:
        return
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
      case .insert:
        guard let newIndexPath = newIndexPath else { return }
        activityTableView.insertRows(at: [newIndexPath], with: .automatic)
      case .delete:
        guard let indexPath = indexPath else { return }
        activityTableView.deleteRows(at: [indexPath], with: .automatic)
      case .move:
        guard let indexPath    = indexPath,
          let newIndexPath = newIndexPath else { return }
        activityTableView.moveRow(at: indexPath, to: newIndexPath)
      case .update:
        guard let indexPath = indexPath else { return }
        activityTableView.reloadRows(at: [indexPath], with: .automatic)
      @unknown default:
        fatalError()
    }
  }
}
