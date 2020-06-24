//
//  RegisteringUser.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

struct RegisteringUser: Codable {
  let profile: Profile
  let credentials: Credentials
}

// MARK: - Credentials
struct Credentials: Codable {
  let password: Password
}

// MARK: - Password
struct Password: Codable {
  let value: String
}

// MARK: - Profile
struct Profile: Codable {
  let firstName, lastName, email, login: String
  let mobilePhone: String?
}


