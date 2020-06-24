//
//  PageHorizontalCell.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import CoreData

class BudgetScreen: UICollectionViewCell  {
  
  let blocksDataSource = BlocksDataSource()
  let calenderDataSource = CalenderDatasource()
  
  private lazy var fetchedResultsController: NSFetchedResultsController<Goal> = {
    let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
    
    fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "income", ascending: false)]
    
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
  
  lazy var currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    return formatter
  }()
 
  lazy var incomeLabel: UILabel = {
    let lb = UILabel()
   
    let incomeString = currencyFormatter.string(from: NSNumber(value: UserController.shared.currentUserGoal.income))
  
    lb.text = "Income: \(incomeString!)"
    lb.textColor = .black
    lb.font = UIFont(name: "Poppins-Bold", size: 20)
    lb.backgroundColor = .white // orange
    lb.widthAnchor.constraint(equalToConstant: 200).isActive = true
    lb.translatesAutoresizingMaskIntoConstraints = false
    return lb
  }()
  
  lazy var categoryTableView: UITableView = {
    let tv = UITableView(frame: .zero, style: .plain)
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.tableFooterView = UIView()
    tv.backgroundColor = .secondarySystemBackground
    tv.dataSource = self
    tv.delegate = self
    tv.separatorStyle = .none
    tv.rowHeight = 100
    tv.isScrollEnabled = false
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
      categoryTableView.topAnchor.constraint(equalTo: incomeLabel.bottomAnchor,constant: 16),
      
    ])
    
    print(UserController.shared.currentUserGoal.income)
    print(UserController.shared.currentUserGoal.debt)
    print(UserController.shared.currentUserGoal.savings)
    print(UserController.shared.currentUserGoal.giving)
    print(UserController.shared.currentUserGoal.food)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  let dict = ["House": UserController.shared.currentUserGoal.housing,
              "Food": UserController.shared.currentUserGoal.food,
              "Transportation": UserController.shared.currentUserGoal.transportation,
              "Personal": UserController.shared.currentUserGoal.personal,
              "Debt": UserController.shared.currentUserGoal.debt,
              "Savings":UserController.shared.currentUserGoal.savings
  ]
}
extension BudgetScreen: UITableViewDataSource,UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
    return "Category                        Goal"
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dict.count
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
    let goalAmount = Array(dict.values)[indexPath.row]
    let categoryName = Array(dict.keys)[indexPath.row]
    cell.categoryImageView.image = UIImage(named: categoryName)
    cell.categoryName.font = UIFont(name: "Poppins-Bold", size: 13)
    cell.categoryName.text = categoryName
    cell.amountLabel.text =  currencyFormatter.string(from: NSNumber(value: goalAmount))
    cell.amountLabel.font = UIFont(name: "Poppins-Bold", size: 13)
    cell.amountLabel.textColor = .lightGray
    cell.categoryProgressView.progressViewStyle = .bar
    
    let magicNumber = Double.random(in: 1...756)
    cell.categoryProgressView.progress = Float(magicNumber/goalAmount) // magic number
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = currencyFormatter.string(from: NSNumber(value: magicNumber.rounded()))
    label.textColor = .white
    label.font = UIFont(name: "Poppins-Bold", size: 11)
    cell.categoryProgressView.addSubview(label)
    
    label.centerYAnchor.constraint(equalTo: cell.categoryProgressView.centerYAnchor).isActive = true
    label.leadingAnchor.constraint(equalTo: cell.categoryProgressView.leadingAnchor,constant: 8).isActive = true
  
    return cell
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    header.backgroundView?.backgroundColor = .white
    header.textLabel?.textColor = .black
    header.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
  }
}
extension BudgetScreen: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    categoryTableView.beginUpdates()
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    categoryTableView.endUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
      case .insert:
        categoryTableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
      case .delete:
        categoryTableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
      default:
        break
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
      case .insert:
        guard let newIndexPath = newIndexPath else { return }
        categoryTableView.insertRows(at: [newIndexPath], with: .automatic)
      case .update:
        guard let indexPath = indexPath else { return }
        categoryTableView.reloadRows(at: [indexPath], with: .automatic)
      case .move:
        guard let oldIndexPath = indexPath,
          let newIndexPath = newIndexPath else { return }
        categoryTableView.deleteRows(at: [oldIndexPath], with: .automatic)
        categoryTableView.insertRows(at: [newIndexPath], with: .automatic)
      case .delete:
        guard let indexPath = indexPath else { return }
        categoryTableView.deleteRows(at: [indexPath], with: .automatic)
      @unknown default:
        break
    }
  }
}
