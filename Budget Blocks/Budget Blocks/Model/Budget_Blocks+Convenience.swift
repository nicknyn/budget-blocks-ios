//
//  Budget_Blocks+Convenience.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

extension Transaction {
    @discardableResult convenience init(transactionID: String, name: String?, amount: Int64, date: Date, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.transactionID = transactionID
        self.name          = name
        self.amount        = amount
        self.date          = date
    }
}

extension TransactionCategory {
    @discardableResult convenience init(categoryID: Int32, name: String, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.categoryID = categoryID
        self.name       = name
    }
}
