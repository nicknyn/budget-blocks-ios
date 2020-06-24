//
//  SixOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/10/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

final class SixOnboardingViewController: UIViewController {
  
  //MARK:- Outlets
  @IBOutlet weak var monthWeekSegment: UISegmentedControl! {
    didSet {
      monthWeekSegment.selectedSegmentTintColor = #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1)
    }
  }
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var insideView: UIView!
  @IBOutlet weak var incomeImageView: UIImageView! {
    didSet {
      incomeImageView.image = UIImage(named: "Income")
    }
  }
  @IBOutlet weak var incomeLabel: UILabel!
  @IBOutlet weak var actualAmountLabel: UILabel! {
    didSet {
      if let census = NetworkingController.shared.census {
        actualAmountLabel.text = "$" + String(census.income.rounded())
      }
    }
  }
  
  //MARK:- View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    insideView.backgroundColor = .secondarySystemBackground
    insideView.layer.cornerRadius = 8
    monthWeekSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont(name: "Poppins-Bold", size: 16)!], for: .normal)
    navigationItem.hidesBackButton = true 
    
  }
  //MARK:- IBActions
  @IBAction func backTapped(_ sender: UIButton) {
    navigationController?.popViewController(animated: true)
  }
  
  
  @IBAction func nextTapped(_ sender: UIButton) {
    
  }
}
