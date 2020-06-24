//
//  8thOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/12/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

final class EighthOnboardingViewController: UIViewController {
  
  private var minimumSpacing: CGFloat = 5
  let defaultCategories: [String: Double] = ["Personal":NetworkingController.shared.census!.personal.rounded(),
                                             "Food":NetworkingController.shared.census!.food.rounded(),
                                             "House":NetworkingController.shared.census!.housing.rounded(),
                                             "Transportation":NetworkingController.shared.census!.transportation.rounded()]

  @IBOutlet weak var mainCollectionView: UICollectionView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.hidesBackButton = true
    mainCollectionView.register(OptionCell.self, forCellWithReuseIdentifier: "OptionCell")
    mainCollectionView.delegate = self
    mainCollectionView.dataSource = self
  }
  
  @IBAction func backTapped(_ sender: UIButton) {
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func nextTapped(_ sender: UIButton) {
    
  }
}
extension EighthOnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return defaultCategories.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath) as! OptionCell
    let amountsArray             = Array(defaultCategories.values)
    let amount                   = "$" + String(amountsArray[indexPath.item].rounded())
    let categoryName             = Array(defaultCategories.keys)[indexPath.item]
    cell.layer.cornerRadius      = 4
    cell.categoryLabel.text      = categoryName
    cell.categoryImageView.image = UIImage(named: categoryName)
    cell.actualAmountLabel.text        = "\(amount)"
    return cell
  }
 
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
    var totalUsableWidth = collectionView.frame.width
    let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
    totalUsableWidth -= inset.left + inset.right
    
    let minWidth: CGFloat = 150.0
    let numberOfItemsInOneRow = Int(totalUsableWidth / minWidth)
    totalUsableWidth -= CGFloat(numberOfItemsInOneRow - 1) * flowLayout.minimumInteritemSpacing
    let width = totalUsableWidth / CGFloat(numberOfItemsInOneRow)
    return CGSize(width: width, height: width )
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 5
  }
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    performSegue(withIdentifier: "SetGoal", sender: indexPath)
    let cell = collectionView.cellForItem(at: indexPath) as! OptionCell
    cell.backgroundColor = #colorLiteral(red: 0.4030240178, green: 0.7936781049, blue: 0.7675691247, alpha: 1)
    cell.categoryLabel.textColor = .white
    cell.actualAmountLabel.textColor = .white
    
    
    print(indexPath.item)
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let indexPath = sender as? IndexPath else { return }
    let collectionCell = mainCollectionView.cellForItem(at: indexPath) as! OptionCell
    let textToPass = collectionCell.categoryLabel.text
    let amountToPass = collectionCell.actualAmountLabel.text
    let detailVC = segue.destination as! NinethOnboardingViewController
    detailVC.categoryTitle = textToPass
    detailVC.defaultAmount = amountToPass
  }
}
