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
                              UIImage(systemName: "trash"),
                              UIImage(systemName: "tray"),
                              UIImage(systemName: "sun.min"),
                              UIImage(systemName: "moon")
    ]

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sfSymbols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = sfSymbols[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HEHE", for: indexPath) as! BlockCell
        if indexPath == IndexPath(item: 0, section: 0) {
            cell.blockButton.setTitle("Income", for: .normal)
            cell.blockButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
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
