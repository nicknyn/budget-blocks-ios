//
//  OnboardingViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/19/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var plaidView: UIView!
    @IBOutlet weak var manualView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        plaidView.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        plaidView.layer.cornerRadius = 56
        let plaidTap = UITapGestureRecognizer(target: self, action: #selector(plaid))
        plaidView.addGestureRecognizer(plaidTap)
        
        manualView.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        manualView.layer.cornerRadius = 56
        let manualTap = UITapGestureRecognizer(target: self, action: #selector(manual))
        manualView.addGestureRecognizer(manualTap)
    }
    
    // MARK: Actions
    
    @IBAction func signOut(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func plaid() {
        print("Plaid")
    }
    
    @objc private func manual() {
        print("Manual")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
