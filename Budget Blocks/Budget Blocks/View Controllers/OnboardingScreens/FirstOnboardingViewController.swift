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
        
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action:
            #selector(swipeMade(_:)))
        leftRecognizer.direction = .left
        
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action:
            #selector(swipeMade(_:)))
        rightRecognizer.direction = .right
        self.view.addGestureRecognizer(leftRecognizer)
        self.view.addGestureRecognizer(rightRecognizer)
        
        navigationController?.toolbar.barTintColor = .white
        navigationController?.navigationBar.isHidden = true
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
 
    @objc func swipeMade(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right  {
            
            dismiss(animated: true, completion: nil)
        }
        if sender.direction == .left {
            performSegue(withIdentifier: "1To2", sender: self)
            
        }
    }
}
