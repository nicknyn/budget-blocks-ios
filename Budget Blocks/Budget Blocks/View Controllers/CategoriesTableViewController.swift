//
//  CategoriesTableViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/18/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import CoreData

protocol CategoriesTableViewControllerDelegate {
    func choose(category: TransactionCategory)
}

class CategoriesTableViewController: UITableViewController {
    
    @IBOutlet weak var showAllButton: UIButton!
    
    var delegate: CategoriesTableViewControllerDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController<TransactionCategory> = {
        let fetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "budget > 0 OR transactions.@count > 0")
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let context = CoreDataStack.shared.mainContext
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error fetching categories: \(error)")
        }
        
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        let category = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = category.name
        if let transactionCount = category.transactions?.count, transactionCount > 0 {
            cell.detailTextLabel?.text = "\(transactionCount) recent transactions"
        } else {
            cell.detailTextLabel?.text = nil
        }

        return cell
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = fetchedResultsController.object(at: indexPath)
        delegate?.choose(category: category)
    }
    
    // MARK: Actions
    
    @IBAction func toggleShowAll(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if sender.isSelected {
            fetchedResultsController.fetchRequest.predicate = nil
        } else {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "budget > 0 OR transactions.@count > 0")
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error fetching categories: \(error)")
        }
        
        tableView.reloadData()
    }
    
}
