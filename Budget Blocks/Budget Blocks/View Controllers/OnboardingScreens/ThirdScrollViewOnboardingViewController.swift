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
        textField.tintColor = #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1)
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
        view.heightAnchor.constraint(equalToConstant: 1200).isActive = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "skip", style: .plain, target: self, action: #selector(skipTapped))
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContainer)
        redView.addSubview(profileLabel)
        redView.addSubview(introduceLabel)
        redView.addSubview(stackView)
        redView.addSubview(bottomStackView)
        
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
            bottomStackView.heightAnchor.constraint(equalToConstant: 40)
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
