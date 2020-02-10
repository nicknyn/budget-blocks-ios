//
//  Int64+Currency.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/5/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

extension Int64 {
    var currency: String {
        let dollars = self / 100
        let cents = abs(self) % 100
        let centsString: String
        if cents < 10 {
            centsString = "0\(cents)"
        } else {
            centsString = "\(cents)"
        }
        
        return "\(dollars).\(centsString)"
    }
}
