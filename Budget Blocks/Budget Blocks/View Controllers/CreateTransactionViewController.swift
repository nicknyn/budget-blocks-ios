//
//  CreateTransactionViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 2/18/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class CreateTransactionViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    var amount: Int64 = 0
    var category: TransactionCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    // MARK: Private
    
    private func setUpViews() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        dateFormatter.dateFormat = "MM/dd/YYYY"
        createDatePicker()
        
        categoryTextField.delegate = self
        descriptionTextField.delegate = self
        amountTextField.delegate = self
    }
    
    private func updateViews() {
        categoryTextField.text = category?.name
    }
    
    private func createDatePicker(){
        datePicker.datePickerMode = .date
        dateTextField.inputView = datePicker
        
        let toolbar = UIToolbar(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.width, height: CGFloat(44))))
        toolbar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEntry))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
        
        toolbar.setItems([cancelButton, spacer, doneButton], animated: true)
        
        dateTextField.inputAccessoryView = toolbar
    }
    
    @objc private func cancelEntry() {
        view.endEditing(false)
    }
    
    @objc private func doneClicked(){
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(false)
    }
    
    // MARK: Actions
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
     // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let categoriesVC = segue.destination as? CategoriesTableViewController {
            categoriesVC.delegate = self
        }
    }

}

// MARK: Text field delegate

extension CreateTransactionViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == categoryTextField {
            performSegue(withIdentifier: "ShowCategories", sender: self)
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == amountTextField,
            textField.text?.first == "$" {
            textField.text?.removeFirst()
            
            if textField.text?.last == "0", textField.text?.dropLast().last == "0" {
                textField.text?.removeLast(3)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == amountTextField {
            var amountFloat: Float?
            
            if let amountString = textField.text,
                !amountString.isEmpty {
                amountFloat = Float(amountString)
            } else {
                amountFloat = 0
            }
            
            if let amountFloat = amountFloat {
                amount = Int64(amountFloat * 100)
                
                if amount > 0 {
                    textField.text = "$\(amount.currency)"
                } else {
                    textField.text = nil
                }
            } else {
                textField.text = "$\(amount.currency)"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Categories table view controller delegate

extension CreateTransactionViewController: CategoriesTableViewControllerDelegate {
    func choose(category: TransactionCategory) {
        self.category = category
        navigationController?.popViewController(animated: true)
        updateViews()
    }
}
