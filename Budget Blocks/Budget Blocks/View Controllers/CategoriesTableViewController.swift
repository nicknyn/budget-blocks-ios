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
    var transactionController: TransactionController?
    var newCategories: [TransactionCategory] = []
    
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
    
    // MARK: Private
    
    private func reloadTable() {
        var predicates: [NSPredicate] = []
        
        if !showAllButton.isSelected {
            predicates.append(NSPredicate(format: "budget > 0 OR transactions.@count > 0"))
        }
        
        predicates.append(NSPredicate(format: "SELF IN %@", newCategories))
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error fetching categories: \(error)")
        }
        
        tableView.reloadData()
    }
    
    // MARK: Actions
    
    @IBAction func toggleShowAll(_ sender: UIButton) {
        sender.isSelected.toggle()
        reloadTable()
    }
    
    @IBAction func createNewCategory(_ sender: Any) {
        let alert = UIAlertController(title: "Create New Category", message: "Enter a category name", preferredStyle: .alert)
        
        var nameTextField: UITextField?
        alert.addTextField { textField in
            textField.placeholder = "Category name"
            textField.autocapitalizationType = .words
            textField.returnKeyType = .done
            nameTextField = textField
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let create = UIAlertAction(title: "Create", style: .default) { _ in
            guard let transactionController = self.transactionController,
                let name = nameTextField?.text,
                !name.isEmpty else { return }
            
            let loadingGroup = DispatchGroup()
            loadingGroup.enter()
            DispatchQueue.main.async {
                self.loading(message: "Creating category...", dispatchGroup: loadingGroup)
            }
            
            transactionController.createCategory(named: name, context: CoreDataStack.shared.mainContext, completion: { category, error in
                loadingGroup.notify(queue: .main) {
                    loadingGroup.enter()
                    self.dismissAlert(dispatchGroup: loadingGroup)
                }
                
                error?.log()
                
                if let category = category {
                    self.newCategories.append(category)
                    DispatchQueue.main.async {
                        self.reloadTable()
                    }
                }
            })
        }
        
        alert.addAction(cancel)
        alert.addAction(create)
        
        present(alert, animated: true)
    }
    
}
