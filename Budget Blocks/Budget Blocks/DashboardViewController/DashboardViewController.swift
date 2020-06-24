//
//  DashboardViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
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
  
  private lazy var balanceLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .white
    lb.translatesAutoresizingMaskIntoConstraints = false
    lb.text = "Your balance is"
    lb.font = UIFont(name: "Poppins", size: 16)
    
    return lb
  }()
  
  private lazy var amountLabel: UILabel = {
    let lb = UILabel()
    lb.text = "-$252"
    lb.translatesAutoresizingMaskIntoConstraints = false
    lb.textColor = .white
    lb.font = UIFont(name: "Poppins-Bold", size: 30)
    return lb
    
  }()
  
  private lazy var hiUserLabel: UILabel = {
    let lb = UILabel()
    var fullName = UserController.shared.user.name
    var stringArr = fullName?.components(separatedBy: " ")
    var firstName = stringArr?.first
    lb.text = "Hi \(firstName)!"
    lb.translatesAutoresizingMaskIntoConstraints = false
    lb.textColor = .white
    lb.font = UIFont(name: "Poppins-Bold", size: 24)
    return lb
  }()
  
  private let containerView: UIView = {
    let view = UIView()
    view.heightAnchor.constraint(equalToConstant: 1000).isActive = true
    view.backgroundColor = .white
    return view
  }()
  
  private let greenView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = #colorLiteral(red: 0.3165915608, green: 0.7718194127, blue: 0.7388673425, alpha: 1)
    view.heightAnchor.constraint(equalToConstant: 200).isActive = true
    return view
  }()
  
  lazy var spendingOrBudgetSegmentedControl: UISegmentedControl = {
    let sm = UISegmentedControl(items: ["Spending","Budget"])
    sm.translatesAutoresizingMaskIntoConstraints = false
    sm.selectedSegmentIndex = 0
    sm.selectedSegmentTintColor = .clear
    sm.setTitleTextAttributes([
      NSAttributedString.Key.font : UIFont(name: "Poppins-Bold", size: 18)!,
      NSAttributedString.Key.foregroundColor: UIColor.lightGray
    ], for: .normal)
    sm.backgroundColor = .clear
    sm.tintColor = .clear
    sm.setTitleTextAttributes([
      NSAttributedString.Key.font : UIFont(name: "Poppins-Bold", size: 18)!,
      NSAttributedString.Key.foregroundColor: UIColor.white
    ], for: .selected)
    
    sm.addTarget(self, action: #selector(switchToSpending), for: .valueChanged)
    sm.heightAnchor.constraint(equalToConstant: 30).isActive = true
    return sm
  }()
  
  
  @objc func switchToSpending(sender: UISegmentedControl) {
    
    switch spendingOrBudgetSegmentedControl.selectedSegmentIndex {
      case 0:
        let indexPath = IndexPath(item: 0, section: 0)
        segmentSwitchCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
      case 1:
        let indexPath = IndexPath(item: 1, section: 0)
        segmentSwitchCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
      default:
        break
    }
  }

  lazy var segmentSwitchCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.delegate = self
    cv.dataSource = self
    cv.backgroundColor = .white
    cv.isScrollEnabled = false
    cv.isPagingEnabled = true
    
    return cv
    
  }()
  
  lazy var bottomBackgroundView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .secondarySystemBackground
    return view
  }()
  
  
  //MARK:- Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = #colorLiteral(red: 0.3165915608, green: 0.7718194127, blue: 0.7388673425, alpha: 1)
    view.addSubview(bottomBackgroundView)
    NSLayoutConstraint.activate([
      bottomBackgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
      bottomBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      bottomBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bottomBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
      
    ])
    segmentSwitchCollectionView.register(BudgetScreen.self, forCellWithReuseIdentifier: "CollectionViewCell")
    segmentSwitchCollectionView.register(ChartCell.self, forCellWithReuseIdentifier: "ChartCell")
    hideKeyboardWhenTappedAround()
    navigationController?.navigationBar.isHidden = true
    navigationItem.hidesBackButton = true
    view.addSubview(scrollView)
    scrollView.addSubview(scrollViewContainer)
    
    containerView.addSubview(greenView)
    
    greenView.addSubview(spendingOrBudgetSegmentedControl)
    greenView.addSubview(amountLabel)
    greenView.addSubview(balanceLabel)
    greenView.addSubview(hiUserLabel)
    
    containerView.addSubview(segmentSwitchCollectionView)
    
    NSLayoutConstraint.activate([
      greenView.topAnchor.constraint(equalTo: containerView.topAnchor),
      greenView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      greenView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      
      segmentSwitchCollectionView.topAnchor.constraint(equalTo: greenView.bottomAnchor),
      segmentSwitchCollectionView.leadingAnchor.constraint(equalTo: greenView.leadingAnchor),
      segmentSwitchCollectionView.trailingAnchor.constraint(equalTo: greenView.trailingAnchor),
      segmentSwitchCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      spendingOrBudgetSegmentedControl.bottomAnchor.constraint(equalTo: greenView.bottomAnchor,constant: -16),
      spendingOrBudgetSegmentedControl.leadingAnchor.constraint(equalTo: greenView.leadingAnchor,constant: 80),
      spendingOrBudgetSegmentedControl.trailingAnchor.constraint(equalTo: greenView.trailingAnchor,constant: -80),
      
      amountLabel.centerXAnchor.constraint(equalTo: greenView.centerXAnchor),
      amountLabel.centerYAnchor.constraint(equalTo: greenView.centerYAnchor),
      
      balanceLabel.bottomAnchor.constraint(equalTo: amountLabel.topAnchor,constant: -4),
      balanceLabel.centerXAnchor.constraint(equalTo: greenView.centerXAnchor),
      
      hiUserLabel.centerXAnchor.constraint(equalTo: greenView.centerXAnchor),
      hiUserLabel.bottomAnchor.constraint(equalTo: balanceLabel.topAnchor,constant: -4)
      
    ])
    
    
    scrollViewContainer.addArrangedSubview(containerView)
    
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
extension DashboardViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! BudgetScreen
    let chartCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartCell", for: indexPath) as! ChartCell
    
    switch indexPath.item {
      case 0:
        return chartCell
      default:
        return categoryCell
    }
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height )
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    segmentSwitchCollectionView.collectionViewLayout.invalidateLayout()
  }
}
