//
//  TabBarViewController.swift
//  Hedge Beta
//
//  Created by Adam Moffitt on 3/30/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    var messagesViewController: InboxTableViewController!
    var notificationsViewController: NotificationsViewController!
    let SharedFunduModel = FunduModel.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.barTintColor = SharedFunduModel.hedgePrimaryColor
        self.tabBar.selectedImageTintColor = .white
        
        // Wallet
        let marketViewController = MarketViewController()
        marketViewController.tabBarItem = UITabBarItem(title: "Wallet", image: UIImage(named: "wallet"), selectedImage: UIImage(named: "wallet"))
        
        // Messages
        messagesViewController = InboxTableViewController()
        messagesViewController.tabBarItem = UITabBarItem(title: "Inbox", image: UIImage(named: "chat"), selectedImage: UIImage(named: "chat"))
        if FunduModel.shared.newMessages != nil && FunduModel.shared.newMessages != 0 {
            messagesViewController.tabBarItem.badgeValue = String(FunduModel.shared.newMessages)
        }
        messagesViewController.setNotificationObserver()
        SharedFunduModel.observeMessageChannels()
        
        // Teams
        let teamsViewController = TeamsViewController()
        teamsViewController.tabBarItem = UITabBarItem(title: "Teams", image: UIImage(named: "team"), selectedImage: UIImage(named: "team"))

        // Notifications
        notificationsViewController = NotificationsViewController()
        notificationsViewController.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(named: "notifications"), selectedImage: UIImage(named: "notifications"))
        notificationsViewController.setNotificationObserver()
        SharedFunduModel.observeNotifications()

        // Leaderboards
        let leaderboardsViewController = LeaderboardsViewController()
        leaderboardsViewController.tabBarItem = UITabBarItem(title: "Leaderboards", image: UIImage(named: "leaderboard"), selectedImage: UIImage(named: "leaderboard"))
        
        let viewControllerList = [ marketViewController, messagesViewController, teamsViewController, notificationsViewController, leaderboardsViewController ]
        viewControllers = viewControllerList.map { UINavigationController(rootViewController: $0 as! UIViewController) }
        
        self.selectedIndex = 2
        
        UIApplication.shared.applicationIconBadgeNumber = 0

        
//        NotificationCenter.default.addObserver(self, selector: #selector(newMessage(notification:)), name: Notification.Name(rawValue: "newMessageNotification"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(newNotification(notification:)), name: Notification.Name(rawValue: "newNotification"), object: nil)

    }
    
//    @objc func newMessage(notification: NSNotification) {
//        if  messagesViewController.tabBarItem.badgeValue == nil {
//             messagesViewController.tabBarItem.badgeValue = "1"
//        } else {
//        messagesViewController.tabBarItem.badgeValue = String(Int(messagesViewController.tabBarItem.badgeValue!)!+1)
//        }
//    }
//    
//    @objc func newNotification(notification: NSNotification) {
//        if  notificationsViewController.tabBarItem.badgeValue == nil {
//            notificationsViewController.tabBarItem.badgeValue = "1"
//        } else {
//            notificationsViewController.tabBarItem.badgeValue = String(Int(notificationsViewController.tabBarItem.badgeValue!)!+1)
//        }
//    }

}
