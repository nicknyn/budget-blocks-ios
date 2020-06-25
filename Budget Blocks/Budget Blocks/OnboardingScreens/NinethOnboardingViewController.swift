//
//  NinethOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/12/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class NinethOnboardingViewController: UIViewController {
  
  var categoryTitle: String? 
  var defaultAmount: String?
  private var userGoalInput = ""
  
  @IBOutlet weak var introductionLabel: UILabel! {
    didSet {
      introductionLabel.text = "Set your \(categoryTitle) budget goals."
    }
  }

  @IBOutlet weak var categoryImageView: UIImageView! {
    didSet {
      categoryImageView.image = UIImage(named: categoryTitle!)
    }
  }
  @IBOutlet weak var amoutGoalTextField: UITextField! {
    didSet {
      amoutGoalTextField.becomeFirstResponder()
    }
  }
  @IBOutlet weak var categoryTitleLabel: UILabel! {
    didSet {
      categoryTitleLabel.text = categoryTitle
    }
  }
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  @IBOutlet weak var amountLabel: UILabel! {
    didSet {
      amountLabel.text = defaultAmount
    }
  }
  
  //MARK:- Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    amoutGoalTextField.delegate = self
    navigationItem.hidesBackButton = true
  }
  
  
  @IBAction func saveTapped(_ sender: UIButton) {
    guard let goalIncomeAmount = amoutGoalTextField.text,
      amoutGoalTextField.hasText else { return }
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    guard let number = formatter.number(from: String(goalIncomeAmount)) else { return }
    switch categoryTitle {
      case "Debt":
        UserController.shared.currentUserGoal.debt = number.doubleValue
      case "House":
        UserController.shared.currentUserGoal.housing = number.doubleValue
      case "Giving":
        UserController.shared.currentUserGoal.giving = number.doubleValue
      case "Personal":
        UserController.shared.currentUserGoal.personal = number.doubleValue
      case "Savings":
        UserController.shared.currentUserGoal.savings = number.doubleValue
      case "Food":
        UserController.shared.currentUserGoal.food = number.doubleValue
      case "Transfer":
        UserController.shared.currentUserGoal.transfer = number.doubleValue
      case "Transportation":
        UserController.shared.currentUserGoal.transportation = number.doubleValue
      default:
      break
    }
    dismiss(animated: true, completion: nil)
    print(  UserController.shared.currentUserGoal.debt)
  }
  
  
}
extension NinethOnboardingViewController: UITextFieldDelegate {
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
    amoutGoalTextField.text = formatter.string(from: NSNumber(value: numberFromField))
    print(amoutGoalTextField.text as Any)
    print(Double(amoutGoalTextField.text!.dropFirst()) as Any)
  }
}

