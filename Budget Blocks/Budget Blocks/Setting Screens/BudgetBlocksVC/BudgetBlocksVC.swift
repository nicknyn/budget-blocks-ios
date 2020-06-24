//
//  BudgetBlocksVC.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class BudgetBlocksVC: UITableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetBlockCell", for: indexPath) as! BudgetBlockCell
    return cell
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .secondarySystemBackground
  }
}
