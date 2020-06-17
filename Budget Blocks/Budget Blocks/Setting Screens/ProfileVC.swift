//
//  ProfileVC.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ProfileVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

     
    }

    // MARK: - Actions

    
    @IBAction func accountInfoTapped(_ sender: UIButton) {
        print("edit info...")
    }
    
    
   
    @IBAction func editBankAccountTapped(_ sender: UIButton) {
        print("Editting")
    }
    
    @IBAction func logOutTapped(_ sender: UIButton) {
        print("Logging out")
    }
    
    
}
