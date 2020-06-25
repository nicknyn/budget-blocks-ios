//
//  ProfileVC.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ProfileVC: UITableViewController {
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var editButton: UIButton!
  
  //MARK:- Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .secondarySystemBackground
  }
  
  // MARK: - Actions
  
  @IBAction func accountInfoTapped(_ sender: UIButton) {
    editButton.setTitle("Save", for: .normal)
    print("edit info...")
    nameTextField.becomeFirstResponder()
  }
  
  @IBAction func editBankAccountTapped(_ sender: UIButton) {
    print("Editting")
  }
  
  @IBAction func logOutTapped(_ sender: UIButton) {
    print("Logging out")
  }
}
