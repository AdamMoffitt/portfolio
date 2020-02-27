//
//  LeagueViewController.swift
//  Hedge Beta
//
//  Created by Adam Moffitt on 4/2/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//

import UIKit

class LeagueViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inboxButton = UIBarButtonItem(image: UIImage(named: "inbox"), style: .plain, target: self, action: #selector(goToMessages))
        self.navigationItem.rightBarButtonItem = inboxButton
        
    }


    @objc func goToMessages() {
        let mVC = InboxTableViewController()
        self.navigationController?.pushViewController(mVC, animated: true)
    }
}
