//
//  Bearer.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/29/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

// I added Codable to the Bearer struct but we are not currently using it but will keep it here in case we refactor for it later
struct Bearer: Codable {
    let token: String
    let userID: Int
    var linkedAccount: Bool
    var manualAccount: Bool
}
