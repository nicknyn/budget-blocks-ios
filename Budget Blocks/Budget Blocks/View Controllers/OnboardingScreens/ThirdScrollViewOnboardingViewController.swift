//
//  ThirdScrollViewOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/11/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

extension UIViewController {
    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }
    func createtextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
}

class ThirdScrollViewOnboardingViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let scrollViewContainer: UIStackView = {
        let view = UIStackView()
        
        view.axis = .vertical
        view.spacing = 10
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let redView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 920).isActive = true
        view.backgroundColor = .white
        return view
    }()
    
    private let profileLabel: UILabel = {
       let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Profile"
        lb.font = UIFont.boldSystemFont(ofSize: 40)
        lb.textColor = #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1)
        return lb
    }()
    
    private let introduceLabel : UILabel = {
       let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Ever wonder how much the average person spends on housing? Add your zipcode and you can compare your budget to the average in your region."
        lb.numberOfLines = 0
        
        return lb
    }()
    @objc func editTapped() {
        print("edit")
    }
    
    private lazy var stackView: UIStackView = {
        let lb = createLabel(text: "Account information")
        let button = createButton(title: "Edit")
  
        button.contentHorizontalAlignment = .leading
        
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitleColor(#colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
       let stackView = UIStackView(arrangedSubviews: [lb,button])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let backButton = createButton(title: "< Back")
        backButton.setTitleColor(#colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        let nextButton = createButton(title: "Next >")
        nextButton.backgroundColor = #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 4
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        let stackView = UIStackView(arrangedSubviews: [backButton,nextButton])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    
    
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc func nextButtonTapped() {
        performSegue(withIdentifier: "3To4", sender: self)
    }
    
    
    @objc func skipTapped() {
        print("skipping")
    }
    
    lazy var nameLabel = createLabel(text: "Name")
    lazy var nameTextField : UITextField = {
       let tf = createtextField(placeholder: "")
        tf.text = "Dummy"
        return tf
    }()
    lazy var emailLabel = createLabel(text: "Email")
    lazy var emailTextField : UITextField = {
        let tf = createtextField(placeholder: "")
        tf.text = "DummyEmail"
        return tf
    }()
    lazy var passwordLabel = createLabel(text: "Password")
    lazy var passwordTextField : UITextField = {
        let tf = createtextField(placeholder: "")
        tf.text = "**********"
        return tf
    }()
    lazy var countryLabel = createLabel(text: "Country")
    lazy var unitedStateLabel = createLabel(text: "United States")
    
    lazy var cityLabel = createLabel(text: "City")
    lazy var cityTextField: UITextField = {
       let tf = createtextField(placeholder: "Garland")
        tf.tintColor = #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1)
        tf.backgroundColor = .red
        tf.layer.cornerRadius = 4
        return tf
    }()
    lazy var stateLabel = createLabel(text: "State")
    lazy var stateTextField : UITextField = {
       let tf = createtextField(placeholder: "TX")
        tf.tintColor = #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1)
        tf.layer.cornerRadius = 4
        return tf
    }()
    lazy var zipcodeLabel = createLabel(text: "Zipcode")
    lazy var zipcodeTextField : UITextField = {
       let tf = createtextField(placeholder: "75041")
        tf.keyboardType = .numberPad
        tf.layer.cornerRadius = 4
        return tf
    }()
    
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "skip", style: .plain, target: self, action: #selector(skipTapped))
        view.addSubview(scrollView)
        
        scrollView.addSubview(scrollViewContainer)
        
        redView.addSubview(profileLabel)
        redView.addSubview(introduceLabel)
        redView.addSubview(stackView)
        redView.addSubview(bottomStackView)
        redView.addSubview(nameLabel)
        redView.addSubview(nameTextField)
        redView.addSubview(emailLabel)
        redView.addSubview(emailTextField)
        redView.addSubview(passwordLabel)
        redView.addSubview(passwordTextField)
        redView.addSubview(countryLabel)
        redView.addSubview(unitedStateLabel)
        redView.addSubview(cityLabel)
        redView.addSubview(cityTextField)
        redView.addSubview(stateLabel)
        redView.addSubview(stateTextField)
        redView.addSubview(zipcodeLabel)
        redView.addSubview(zipcodeTextField)
        
        
        
        
        
        unitedStateLabel.font = UIFont.systemFont(ofSize: 16)
        
        NSLayoutConstraint.activate([
            profileLabel.topAnchor.constraint(equalTo: redView.topAnchor,constant: 40),
            profileLabel.leadingAnchor.constraint(equalTo: redView.leadingAnchor,constant: 32),
            profileLabel.trailingAnchor.constraint(equalTo: redView.trailingAnchor,constant: -32),
            
            introduceLabel.heightAnchor.constraint(equalToConstant: 100),
            introduceLabel.leadingAnchor.constraint(equalTo: profileLabel.leadingAnchor),
            introduceLabel.trailingAnchor.constraint(equalTo: profileLabel.trailingAnchor),
            introduceLabel.topAnchor.constraint(equalTo: profileLabel.bottomAnchor,constant: 16),
            
            stackView.leadingAnchor.constraint(equalTo: profileLabel.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: introduceLabel.bottomAnchor,constant: 16),
            stackView.trailingAnchor.constraint(equalTo: profileLabel.trailingAnchor),
            
            
            bottomStackView.bottomAnchor.constraint(equalTo: redView.bottomAnchor,constant: -32),
            bottomStackView.leadingAnchor.constraint(equalTo: redView.leadingAnchor,constant: 48),
            bottomStackView.trailingAnchor.constraint(equalTo: redView.trailingAnchor,constant: -48),
            bottomStackView.heightAnchor.constraint(equalToConstant: 40),
            
            
            nameLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor,constant: 16),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: 0),
            nameTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            emailLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor,constant: 16),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor,constant: 16),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            countryLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            countryLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor,constant: 16),
            
            unitedStateLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            unitedStateLabel.topAnchor.constraint(equalTo: countryLabel.bottomAnchor,constant: 8),
            
            cityLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            cityLabel.topAnchor.constraint(equalTo: unitedStateLabel.bottomAnchor,constant: 16),
            
            cityTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            cityTextField.topAnchor.constraint(equalTo: cityLabel.bottomAnchor,constant: 4),
            cityTextField.widthAnchor.constraint(equalToConstant: 240),
            cityTextField.heightAnchor.constraint(equalToConstant: 40),
            
            stateLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            stateLabel.topAnchor.constraint(equalTo: cityTextField.bottomAnchor,constant: 16),
            
            stateTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            stateTextField.topAnchor.constraint(equalTo: stateLabel.bottomAnchor,constant: 4),
            stateTextField.widthAnchor.constraint(equalToConstant: 240),
            stateTextField.heightAnchor.constraint(equalToConstant: 40),
            
            zipcodeLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            zipcodeLabel.topAnchor.constraint(equalTo: stateTextField.bottomAnchor,constant: 16),
            
            zipcodeTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            zipcodeTextField.topAnchor.constraint(equalTo: zipcodeLabel.bottomAnchor,constant: 4),
            zipcodeTextField.widthAnchor.constraint(equalToConstant: 240),
            zipcodeTextField.heightAnchor.constraint(equalToConstant: 40)
            
        ])
       
        
        
        scrollViewContainer.addArrangedSubview(redView)

        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        scrollViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        // this is important for scrolling
        scrollViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }

}
