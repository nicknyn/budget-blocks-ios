//
//  FirstOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class FirstOnboardingViewController: UIViewController {

    
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationController?.toolbar.barTintColor = .white
        
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    

}
