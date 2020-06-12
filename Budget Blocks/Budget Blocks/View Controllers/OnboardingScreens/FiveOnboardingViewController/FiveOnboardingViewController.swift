//
//  FiveOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/10/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import CoreData

class FiveOnboardingViewController: UIViewController {

    private lazy var fetchedResultsController: NSFetchedResultsController<DataScienceTransaction> = {
        let fetchRequest: NSFetchRequest<DataScienceTransaction> = DataScienceTransaction.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false),
        ]
        
        
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
    
    
    @IBOutlet weak var tableView: UITableView!
      
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
extension FiveOnboardingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! CustomCell
        let transaction = fetchedResultsController.object(at: indexPath)
        
        cell.dateLabel.text = transaction.date
        cell.nameLabel.text = transaction.name
        cell.dollarLabel.text = String(transaction.amount) + "$"
        cell.dollarLabel.textColor = transaction.amount > 0 ? #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1) : .red
        cell.transactionImageView.image = transaction.amount > 0 ? UIImage(systemName: "shift") : UIImage(systemName: "chevron.down")
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension FiveOnboardingViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
            case .insert:
                tableView.insertSections(indexSet, with: .automatic)
            case .delete:
                tableView.deleteSections(indexSet, with: .automatic)
            default:
                return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else { return }
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            case .delete:
                guard let indexPath = indexPath else { return }
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .move:
                guard let indexPath    = indexPath,
                    let newIndexPath = newIndexPath else { return }
                tableView.moveRow(at: indexPath, to: newIndexPath)
            case .update:
                guard let indexPath = indexPath else { return }
                tableView.reloadRows(at: [indexPath], with: .automatic)
            @unknown default:
                fatalError()
        }
    }
}
