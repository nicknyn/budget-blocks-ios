//
//  Error+Log.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/11/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

extension Error {
    func log() {
        NSLog("\(self)")
    }
}
