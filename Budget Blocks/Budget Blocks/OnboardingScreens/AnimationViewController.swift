//
//  ReadyViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 6/17/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import Lottie

final class AnimationViewController: UIViewController {
  
  @IBOutlet weak var lottieAnimationView: AnimationView!
  
  let animation = Animation.named("animation")
  
  //MARK:- View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.isHidden = true
    displayAnimation()
  }
  
  fileprivate func displayAnimation() {
    lottieAnimationView.animation = animation
    lottieAnimationView.animationSpeed = 1.8
    lottieAnimationView.play { [weak self] (finished) in
      DispatchQueue.main.async {
        self?.performSegue(withIdentifier: "ShowOnboarding", sender: self)
      }
    }
  }
}
