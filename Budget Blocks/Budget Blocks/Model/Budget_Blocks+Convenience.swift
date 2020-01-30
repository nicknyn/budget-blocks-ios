//
//  Budget_Blocks+Convenience.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

extension Transaction {
    @discardableResult convenience init(transactionID: String, amount: Int16, date: Date, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.transactionID = transactionID
        self.amount = amount
        self.date = date
    }
}
