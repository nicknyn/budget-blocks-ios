//
//  CoreDataStack.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

final class CoreDataStack {
  
  // Let us access the CoreDataStack from anywhere in the app.
  static let shared = CoreDataStack()
  
  // Set up a persistent container
  lazy var container: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "Budget_Blocks")
    container.loadPersistentStores { (_, error) in
      if let error = error {
        fatalError("Failed to load persistent stores: \(error)")
      }
    }
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.undoManager = nil
    container.viewContext.shouldDeleteInaccessibleFaults = true
    
    return container
  }()
  
  var mainContext: NSManagedObjectContext {
    return container.viewContext
  }
  
  func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
    context.performAndWait {
      do {
        try context.save()
      } catch {
        NSLog("Error saving context: \(error)")
        context.reset()
      }
    }
  }
}
