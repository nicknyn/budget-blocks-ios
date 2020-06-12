//
//  CensusDataRepresentation.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/11/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

struct CensusDataRepresentation : Codable {
    let city: String
    let personal: Double
    let food: Double
    let debt: Double
    let income: Double
    let giving: Double
    let housing: Double
    let transportation: Double
    let transfer: Double
    let savings: Double
    
    enum CodingKeys: String,CodingKey {
        case city = "City"
        case personal = "Personal"
        case food = "Food"
        case debt = "Debt"
        case income = "Income"
        case giving = "Giving"
        case housing = "Housing"
        case transportation = "Transportation"
        case transfer = "transfer"
        case savings = "savings"
    }
}
