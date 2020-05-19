//
//  UserController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 5/18/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import CoreData

class UserController {
    func createUser(into context: NSManagedObjectContext,name: String, email: String) {
        let user = User(context: context)
        user.name = name
        user.email = email
        CoreDataStack.shared.save(context: context)
    }
}
