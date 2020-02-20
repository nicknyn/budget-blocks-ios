//
//  UIKit+Font.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/10/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

extension UILabel {
    func setApplicationTypeface() {
        let applicationTypefaceName = "Exo-Regular"
        
        let textSize = self.font.pointSize
        self.font = UIFont(name: applicationTypefaceName, size: textSize)
    }
}
