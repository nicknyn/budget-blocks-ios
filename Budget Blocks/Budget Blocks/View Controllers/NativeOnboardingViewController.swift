//
//  NativeOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/3/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class NativeOnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBarImage()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
  
    func addNavBarImage() {

        let image = UILabel()
        image.font = UIFont.boldSystemFont(ofSize: 32)
        image.text = "Budget"

        navigationItem.titleView = image
    }
}
