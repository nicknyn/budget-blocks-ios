//
//  SixOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/10/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class SixOnboardingViewController: UIViewController {


    @IBOutlet weak var containerView: UIView!
    
    var embedd :EmbeddedViewController {
        return self.children.last as! EmbeddedViewController
    }
        
      
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    

    @IBAction func nextTapped(_ sender: UIButton) {
         print(embedd.amount!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "6To7" {
            let destVC = segue.destination as! SevenOnboardingViewController
            destVC.amount = embedd.amount!
        }
    }
}
