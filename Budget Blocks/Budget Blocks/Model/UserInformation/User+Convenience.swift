//
//  User+Convenience.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 5/28/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

extension User  {
  var userRepresentation: UserRepresentation? {
    guard let name = name, let email = email else { return nil }
    return UserRepresentation(name: name, email: email)
  }
}
