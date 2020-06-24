//
//  UserController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/11/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import CoreData


class UserController {
  
  static let shared = UserController()

  var user = User(context: CoreDataStack.shared.mainContext)
  var currentUserGoal = Goal(context: CoreDataStack.shared.mainContext)
  
  static var userID: Int?
  
  func createUser(with name: String, email: String) -> User {
    user.name  = name
    user.email = email
    try? CoreDataStack.shared.mainContext.save()
    return user
  }
}
