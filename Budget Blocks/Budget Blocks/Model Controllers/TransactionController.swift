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
    
    init(networkingController: NetworkingController? = nil) {
        self.networkingController = networkingController
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: .logout, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func logout() {
        networkingController?.logout()
        clearStoredTransactions(context: CoreDataStack.shared.mainContext)
    }
    
    func updateTransactionsFromServer(context: NSManagedObjectContext, completion: @escaping (String?, Error?) -> Void) {
        networkingController?.fetchTransactionsFromServer(completion: { json, error in
            guard let categories = json?[self.networkingController!.manualAccount ? "list" : "Categories"].array else {
                NSLog("Transaction fetch response did not contain transactions")
                if let message = json?["message"].string {
                    return completion(message, error)
                } else if let response = json?.rawString() {
                    NSLog("Response: \(response)")
                }
                return completion(nil, error)
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
                            let amountString = transactionJSON["amount"].string,
                            let amountFloat = Float(amountString),
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
                
                self.networkingController?.setLinked()
                CoreDataStack.shared.save(context: context)
                completion(nil, nil)
            } catch {
                completion(nil, error)
            }
        })
    }
    
    func updateCategoriesFromServer(context: NSManagedObjectContext, completion: @escaping (String?, Error?) -> Void) {
        networkingController?.fetchCategoriesFromServer(completion: { json, error in
            guard let categoriesJSON = json?.array else {
                if let message = json?["message"].string {
                    return completion(message, error)
                } else if let response = json?.rawString() {
                    NSLog("Response: \(response)")
                }
                return completion(nil, error)
            }
            
            do {
                let fetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()
                let existingCategories = try context.fetch(fetchRequest)
                
                for categoryJSON in categoriesJSON {
                    guard let categoryID = categoryJSON["id"].int32,
                        let name = categoryJSON["name"].string else { continue }
                    
                    let category: TransactionCategory
                    if let existingCategory = existingCategories.first(where: { $0.categoryID == categoryID }) {
                        category = existingCategory
                    } else {
                        category = TransactionCategory(categoryID: categoryID, name: name, context: context)
                    }
                    
                    let budgetFloat = categoryJSON["budget"].floatValue
                    let budget = Int64(budgetFloat * 100)
                    category.budget = budget
                }
                
                CoreDataStack.shared.save(context: context)
                completion(nil, nil)
            } catch {
                completion(nil, error)
            }
        })
    }
    
    func setCategoryBudget(category: TransactionCategory, budget: Int64, completion: @escaping (Error?) -> Void) {
        networkingController?.setCategoryBudget(categoryID: category.categoryID, budget: budget, completion: { json, error in
            guard let json = json,
                let amount = json["amount"].float else {
                NSLog("No `amount` returned from budget set request.")
                return completion(error)
            }
            
            category.budget = Int64(amount * 100)
            completion(nil)
        })
    }
    
    func createTransaction(amount: Int64, date: Date, category: TransactionCategory, name: String?, context: NSManagedObjectContext, completion: @escaping (Transaction?, Error?) -> Void) {
        networkingController?.createTransaction(amount: amount, date: date, category: category, name: name, completion: { json, error in
            if let error = error {
                return completion(nil, error)
            }
            
            guard let json = json,
                let transactionID = json["inserted"].int32 else {
                    NSLog("No ID returned from create transaction request.")
                    return completion(nil, nil)
            }
            
            let transaction = Transaction(transactionID: "\(transactionID)", name: name, amount: amount, date: date, context: context)
            CoreDataStack.shared.save(context: context)
            completion(transaction, nil)
        })
    }
    
    func delete(transaction: Transaction, context: NSManagedObjectContext, completion: @escaping (Bool, Error?) -> Void) {
        guard let transactionID = Int32(transaction.transactionID ?? "") else { return completion(false, nil) }
        networkingController?.deleteTransaction(transactionID: transactionID, completion: { json, error in
            if let error = error {
                return completion(false, error)
            }
            
            guard let json = json else {
                NSLog("No json returned from delete transaction request.")
                return completion(false, nil)
            }
            
            let deleted: Bool = json["deleted"].intValue.bool
            
            if deleted {
                context.delete(transaction)
                CoreDataStack.shared.save(context: context)
            }
            
            completion(deleted, nil)
        })
    }
    
    func createCategory(named name: String, context: NSManagedObjectContext, completion: @escaping (TransactionCategory?, Error?) -> Void) {
        networkingController?.createCategory(named: name, completion: { json, error in
            if let error = error {
                completion(nil, error)
            }
            
            guard let json = json,
                let categoryID = json["addedCat"].int32 else {
                    NSLog("No category ID returned from add category request.")
                    return completion(nil, nil)
            }
            
            let category = TransactionCategory(categoryID: categoryID, name: name, context: context)
            CoreDataStack.shared.save(context: context)
            completion(category, nil)
        })
    }
    
    func delete(category: TransactionCategory, context: NSManagedObjectContext, completion: @escaping (Bool, Error?) -> Void) {
        networkingController?.deleteCategory(categoryID: category.categoryID, completion: { json, error in
            if let error = error {
                return completion(false, error)
            }
            
            guard let json = json else {
                NSLog("No json returned from delete category request.")
                return completion(false, nil)
            }
            
            let deleted: Bool = json["deleted"].intValue.bool
            
            if deleted {
                context.delete(category)
                CoreDataStack.shared.save(context: context)
            }
            
            completion(deleted, nil)
        })
    }
    
    func clearStoredTransactions(context: NSManagedObjectContext) {
        let transactionsFetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let categoriesFetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()
        do {
            let allTransactions = try context.fetch(transactionsFetchRequest)
            for transaction in allTransactions {
                context.delete(transaction)
            }
            
            let allCategories = try context.fetch(categoriesFetchRequest)
            for category in allCategories {
                context.delete(category)
            }
            
            CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error fetching transactions for deletion: \(error)")
        }
    }
    
    func getTotalSpending(for category: TransactionCategory) -> Int64 {
        let transactionAmounts = category.transactions?.compactMap({ ($0 as? Transaction)?.amount })
        return transactionAmounts?.reduce(0, +) ?? 0
    }
    
}
