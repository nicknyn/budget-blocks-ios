//
//  DashboardViewController.swift
//  Budget Blocks
//
//  Created by Isaac Lyons on 1/28/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import LinkKit

class DashboardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        performSegue(withIdentifier: "InitialLogin", sender: self)
    }
    
    @IBAction func linkAccount(_ sender: Any) {
        guard let publicKey = ProcessInfo.processInfo.environment["PLAID_PUBLIC_KEY"] else {
            return NSLog("No public key found!")
        }
        let linkConfiguration = PLKConfiguration(key: publicKey, env: .sandbox, product: .auth)
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: self)
        present(linkViewController, animated: true)
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

extension DashboardViewController: PLKPlaidLinkViewDelegate {
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true)
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        //<#code#>
    }
}
