//
//  ProfileTableViewController.swift
//  Budget Blocks
//
//  Created by Nick Nguyen on 5/18/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ProfileTableViewController : UITableViewController {
    
    //MARK:- Outlets
    
    @IBOutlet weak var profileHeaderView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    private(set) var statusBarView: UIView?
    
    private let options = ["Change Password","Share app with friends","Visit website"]
    
    
    //MARK:- Life Cycle -
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor  = . secondarySystemBackground
        tableView.tableFooterView = UIView()
        
          NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfo), name: Notification.Name("GetUser"), object: nil)
       
    }
    
    @objc func updateUserInfo(_ notification: Notification) {
        if let userInfo = notification.userInfo, let user = userInfo["user"] as? User {
            nameLabel.text = user.name
            emailLabel.text = user.email
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        if #available(iOS 13, *) {
            navigationController?.navigationBar.isHidden = true
            let statusBar = UIView(frame: ( UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBarView = statusBar
            statusBar.backgroundColor = UIColor.white
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(statusBar)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        statusBarView?.removeFromSuperview()
         navigationController?.navigationBar.isHidden = false
    }
    
    
    //MARK:- Datasource-
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        let option = options[indexPath.row]
        cell.textLabel?.text = option
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch  indexPath.row {
            case 0:
                print("Tap")
                   let vc = ChangePasswordViewController()
                navigationController?.pushViewController(vc, animated: true)
            default:
            break
        }
    }
}
