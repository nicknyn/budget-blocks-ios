//
//  8thOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/12/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class EighthOnboardingViewController: UIViewController {

    private var minimumSpacing: CGFloat = 5
    @IBOutlet weak var mainCollectionView: UICollectionView!

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainCollectionView.register(OptionCell.self, forCellWithReuseIdentifier: "OptionCell")
          mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
    }
    

    
    @IBAction func backTapped(_ sender: UIButton) {
        
    }
    
    
    
    
    @IBAction func nextTapped(_ sender: UIButton) {
        
    }
    

}
extension EighthOnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath) as! OptionCell
        cell.layer.cornerRadius = 4
        
        cell.categoryLabel.text = "DUMMY"
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
        return CGSize(width: width, height: width / 2)
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
        print(indexPath.item)
    }
}
