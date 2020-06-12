//
//  CustomTabBarController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 5/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import UIKit

@objc class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    @objc func set(selectedIndex index : Int) {
        _ = self.tabBarController(self, shouldSelect: self.viewControllers![index])
    }
}

@objc extension CustomTabBarController: UITabBarControllerDelegate  {
    @objc func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false // Make sure you want this as false
        }
        
        if fromView != toView {
            
            UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: { (true) in
                
            })
            
            self.selectedViewController = viewController
            
        }
        
        return true
    }
}
