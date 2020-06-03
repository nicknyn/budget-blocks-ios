//
//  NativeOnboardingViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/3/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class NativeOnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
     addNavBarImage()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
  
    func addNavBarImage() {
//        let navController = navigationController!
        let image = UILabel() //Your logo url here
//        let imageView = UIImageView(image: image)
        image.font = UIFont.boldSystemFont(ofSize: 32)
        image.text = "Budget"
//        let bannerWidth = navController.navigationBar.frame.size.width
//        let bannerHeight = navController.navigationBar.frame.size.height
//        let bannerX = bannerWidth / 2 - (image.size.width)! / 2
//        let bannerY = bannerHeight / 2 - (image.size.height)! / 2
//        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
//        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = image
    }
}
