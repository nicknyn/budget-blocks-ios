//
//  SecondOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

final class SecondOnboardingViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("Static \(UserController.userID)")
    let leftRecognizer = UISwipeGestureRecognizer(target: self, action:
      #selector(swipeMade(_:)))
    leftRecognizer.direction = .left
    
    let rightRecognizer = UISwipeGestureRecognizer(target: self, action:
      #selector(swipeMade(_:)))
    rightRecognizer.direction = .right
    self.view.addGestureRecognizer(leftRecognizer)
    self.view.addGestureRecognizer(rightRecognizer)
    
    
    navigationItem.hidesBackButton = true
    navigationItem.rightBarButtonItem  = UIBarButtonItem(title: "skip", style: .plain, target: self, action: #selector(skipTapped))
    
  }
  @objc func skipTapped() {
    print("skipping")
  }
  
  @IBAction func backButtonTapped(_ sender: UIButton) {
    navigationController?.popViewController(animated: true)
  }
  @objc func swipeMade(_ sender: UISwipeGestureRecognizer) {
    if sender.direction == .right  {
      
      navigationController?.popViewController(animated: true)
    }
    if sender.direction == .left {
      performSegue(withIdentifier: "2To3", sender: self)
      
    }
  }
}
