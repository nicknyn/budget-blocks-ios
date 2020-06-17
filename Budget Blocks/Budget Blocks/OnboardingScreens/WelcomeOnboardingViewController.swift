//
//  WelcomeOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/15/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class WelcomeOnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
}
