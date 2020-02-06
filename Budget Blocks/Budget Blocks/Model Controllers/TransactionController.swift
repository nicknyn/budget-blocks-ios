//
//  TransactionController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

class TransactionController {
    
    var networkingController: NetworkingController?
    
    func createTransaction(transactionID: String, name: String, amount: Int64, date: Date, context: NSManagedObjectContext) {
        Transaction(transactionID: transactionID, name: name, amount: amount, date: date, context: context)
        CoreDataStack.shared.save(context: context)
    }
    
    func deleteTransaction(transaction: Transaction, context: NSManagedObjectContext) {
        context.delete(transaction)
        CoreDataStack.shared.save(context: context)
    }
    
    func updateTransactionsFromServer(context: NSManagedObjectContext, completion: @escaping (String?, Error?) -> Void) {
        networkingController?.fetchTransactionsFromServer(completion: { json, error in
            if let error = error {
                return completion(nil, error)
            }
            
            guard let categories = json?["categories"].array else {
                NSLog("Transaction fetch response did not contain transactions")
                if let message = json?["message"].string {
                    return completion(message, nil)
                } else if let response = json?.rawString() {
                    NSLog("Response: \(response)")
                }
                return completion(nil, nil)
            }
            
            do {
                let transactionsFetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                let existingTransactions = try context.fetch(transactionsFetchRequest)
                let categoriesFetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()
                let existingCategories = try context.fetch(categoriesFetchRequest)
                
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [
                    .withYear,
                    .withMonth,
                    .withDay,
                    .withDashSeparatorInDate
                ]
                for categoryJSON in categories {
                    // Create/update category
                    var currentCategory: TransactionCategory?
                    if let categoryID = categoryJSON["id"].int32,
                        let categoryName = categoryJSON["name"].string {
                        if let existingCategory = existingCategories.first(where: { $0.categoryID == categoryID }) {
                            existingCategory.name = categoryName
                            currentCategory = existingCategory
                        } else {
                            currentCategory = TransactionCategory(categoryID: categoryID, name: categoryName, context: context)
                        }
                    }
                    
                    // Create/update transactions
                    guard let transactions = categoryJSON["transactions"].array else { continue }
                    for transactionJSON in transactions {
                        guard let transactionID = transactionJSON["id"].int,
                            let name = transactionJSON["name"].string,
                            let amountFloat = transactionJSON["amount"].float,
                            let dateString = transactionJSON["payment_date"].string,
                            let date = dateFormatter.date(from: dateString) else { continue }
                        let amount = Int64(amountFloat * 100)
                        
                        let transaction: Transaction
                        if let existingTransaction = existingTransactions.first(where: { $0.transactionID == "\(transactionID)" }) {
                            existingTransaction.name = name
                            existingTransaction.amount = amount
                            existingTransaction.date = date
                            transaction = existingTransaction
                        } else {
                            transaction = Transaction(transactionID: "\(transactionID)", name: name, amount: amount, date: date, context: context)
                        }
                        
                        transaction.category = currentCategory
                    }
                }
                
                CoreDataStack.shared.save(context: context)
                completion(nil, nil)
            } catch {
                completion(nil, error)
            }
        })
    }
    
    func clearStoredTransactions(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        do {
            let allTransactions = try context.fetch(fetchRequest)
            for transaction in allTransactions {
                context.delete(transaction)
            }
            CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error fetching transactions for deletion: \(error)")
        }
    }
    
}
