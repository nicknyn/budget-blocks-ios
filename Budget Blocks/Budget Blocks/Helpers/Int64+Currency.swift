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
extension String.StringInterpolation {
    
    /// Prints `Optional` values by only interpolating it if the value is set. `nil` is used as a fallback value to provide a clear output.
    mutating func appendInterpolation<T: CustomStringConvertible>(_ value: T?) {
        appendInterpolation(value ?? "nil" as CustomStringConvertible)
    }
    
}
