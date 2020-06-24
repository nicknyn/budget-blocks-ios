//
//  BlocksDataSource.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/16/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class BlocksDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
  
  private let sfSymbols = [ UIImage(systemName: "heart"),
                            UIImage(systemName: "house"),
                            UIImage(systemName: "tray"),
                            UIImage(systemName: "car"),
                            UIImage(systemName: "smiley")
  ]
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return sfSymbols.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let image = sfSymbols[indexPath.item]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HEHE", for: indexPath) as! BlockCell
    if indexPath == IndexPath(item: 0, section: 0) {
      cell.blockButton.setTitle("Income", for: .normal)
      cell.backgroundColor = #colorLiteral(red: 0.3165915608, green: 0.7718194127, blue: 0.7388673425, alpha: 1)
      cell.blockButton.titleLabel?.font = UIFont(name: "Poppins", size: 12)
    } else {
      cell.blockButton.setImage(image, for: .normal)
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    return  indexPath == IndexPath(item: 0, section: 0) ?
      CGSize(width: collectionView.frame.width / 5 , height: collectionView.frame.height / 2 )
      : CGSize(width: collectionView.frame.width / 8 , height: collectionView.frame.height / 2 )
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 30.0, right: 10.0)
  }
}
