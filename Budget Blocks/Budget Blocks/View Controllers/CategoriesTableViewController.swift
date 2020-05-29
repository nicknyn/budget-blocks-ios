//
//  CategoriesTableViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/18/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import CoreData

protocol CategoriesTableViewControllerDelegate: AnyObject {
    func choose(category: TransactionCategory)
}

class CategoriesTableViewController: UITableViewController {
    
    @IBOutlet private weak var showAllButton: UIButton!
    
    weak var delegate: CategoriesTableViewControllerDelegate?
    var transactionController: TransactionController?
    var newCategories: [TransactionCategory] = []
    var loadingGroup = DispatchGroup()
    
    private(set) lazy var fetchedResultsController: NSFetchedResultsController<TransactionCategory> = {
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
   
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return transactionController?.networkingController?.manualAccount ?? false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //TODO: Ask the user for confirmation
            let category = fetchedResultsController.object(at: indexPath)
            
            loadingGroup.enter()
            loading(message: "Deleting category...", dispatchGroup: loadingGroup)
            transactionController?.delete(category: category, context: CoreDataStack.shared.mainContext) { deleted, error in
                self.loadingGroup.notify(queue: .main) {
                    self.loadingGroup.enter()
                    self.dismissAlert(dispatchGroup: self.loadingGroup)
                }
                
                error?.log()
                
                if deleted {
                    DispatchQueue.main.async {
                        self.reloadTable()
                    }
                }
            }
        }
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = fetchedResultsController.object(at: indexPath)
        delegate?.choose(category: category)
    }
    
    // MARK: Private
    
    private func reloadTable() {
        let predicate: NSPredicate?
        
        if !showAllButton.isSelected {
            predicate = NSPredicate(format: "budget > 0 OR transactions.@count > 0 OR SELF IN %@", newCategories)
        } else {
            predicate = nil
        }
        
        fetchedResultsController.fetchRequest.predicate = predicate
        
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
          newCategoryFunction()
   }
        // The newCategoryFunction is made to create the actionAlerts for when creating a new Category in app
    func newCategoryFunction() {
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
