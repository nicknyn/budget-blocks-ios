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
    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    
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
    
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension CreateTransactionViewController: UITextFieldDelegate {
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        //showDatePicker()
//        textField.inputView = datePicker
//        return true
//    }
//}
