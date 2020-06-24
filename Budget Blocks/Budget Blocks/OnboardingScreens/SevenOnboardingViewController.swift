//
//  SevenOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/10/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import CoreData

final class SevenOnboardingViewController: UIViewController {
  
  private var userGoalInput = ""
  @IBOutlet weak var actualAmountLabel: UILabel!
  @IBOutlet weak var goalTextField: UITextField! {
    didSet {
      goalTextField.becomeFirstResponder()
      goalTextField.delegate = self
      goalTextField.layer.borderWidth = 2.0
      goalTextField.layer.borderColor = #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1)
      goalTextField.keyboardType = .numberPad
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.hidesBackButton = true
    if let census = NetworkingController.shared.census {
      actualAmountLabel.text = "$" + String(census.income.rounded())
    }
  }
  
  @IBAction func backTapped(_ sender: UIButton) {
    navigationController?.popViewController(animated: true)
  }
  
  
  @IBAction func nextTapped(_ sender: UIButton) {
    guard let goalIncomeAmount = goalTextField.text,
      goalTextField.hasText else { return }
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    guard let number = formatter.number(from: String(goalIncomeAmount)) else { return }
    UserController.shared.currentUserGoal.income = number.doubleValue
    print(UserController.shared.currentUserGoal.income)
  }
  
  
  
}
extension SevenOnboardingViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { // return FALSE to not change text
    
    switch string {
      case "0","1","2","3","4","5","6","7","8","9":
        userGoalInput += string
        print(userGoalInput)
        formatCurrency(string: userGoalInput)
      default:
        let array = Array(string)
        var currentStringArray = Array(userGoalInput)
        if array.count == 0 && currentStringArray.count != 0 {
          currentStringArray.removeLast()
          userGoalInput = ""
          for character in currentStringArray {
            userGoalInput += String(character)
          }
          formatCurrency(string: userGoalInput)
      }
    }
    return false
  }
  
  private func formatCurrency(string: String) {
    print("format \(string)")
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    let numberFromField = (NSString(string: userGoalInput).doubleValue) / 100
    goalTextField.text = formatter.string(from: NSNumber(value: numberFromField))
    print(goalTextField.text)
    print(Double(goalTextField.text!.dropFirst()))
  }
}
