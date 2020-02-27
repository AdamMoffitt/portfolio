//
//  NotificationsViewController.swift
//  Hedge Beta
//
//  Created by Adam Moffitt on 4/28/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import SCLAlertView
import NVActivityIndicatorView
import Crashlytics
import InstantSearch
import UIDropDown

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    let SharedFunduModel = FunduModel.shared
    var activityIndicatorView : NVActivityIndicatorView!
    let appearance = SCLAlertView.SCLAppearance(
        showCloseButton: false
    )
    let alertViewIcon = UIImage(named: "hedgeLogo") //Replace the IconImage text with the image name
    var notifications: [UserNotification]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notifications"
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.barTintColor = FunduModel.shared.hedgePrimaryColor
        self.edgesForExtendedLayout = []
        view.backgroundColor = FunduModel.shared.funduColor
        
        if self.notifications == nil {
            self.notifications = []
        }
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: self.view.frame.height), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        tableView.backgroundColor = SharedFunduModel.hedgePrimaryColor
        view.addSubview(tableView)
        loadingAnimation()
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, self.tabBarController!.tabBar.frame.height, 0)
        self.tableView.contentInset = adjustForTabbarInsets
        self.tableView.scrollIndicatorInsets = adjustForTabbarInsets
        
        createConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ViewWillAppear")
        if self.tabBarItem.badgeValue != nil {
            let notificationsBadges = Int(self.tabBarItem.badgeValue!)!
            self.tabBarItem.badgeValue = nil
            print("APP BADGE NUMBER: \(UIApplication.shared.applicationIconBadgeNumber)")
            if UIApplication.shared.applicationIconBadgeNumber != 0 {
                
                UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - notificationsBadges
                print("APP BADGE NUMBER AFTER: \(UIApplication.shared.applicationIconBadgeNumber)")
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //TODO mark all notifications as read
        let urlString = URL(string: "https://us-central1-hedge-beta.cloudfunctions.net/seeAllNotifications?userID=\(FunduModel.shared.myUser.userID)")
        print(urlString ?? "")
        if let url = urlString {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                }
            }
            task.resume()
        }
    }
    
    // initialize when creating tab bar to listen for notifications
    func setNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(newNotification(notification:)), name: Notification.Name(rawValue: "newNotification"), object: nil)
    }
    
    @objc func newNotification(notification: NSNotification) {
        if self.notifications == nil {
            self.notifications = []
        }
        let json = JSON(notification.userInfo)
        print("notification: \(json)")
        let message = json["message"].stringValue
        let type = json["type"].stringValue
        let imageString = json["imageURL"].stringValue
        let teamName = json["teamName"].stringValue
        let teamID = json["teamID"].stringValue
        let leagueID = json["leagueID"].stringValue
        let leagueName = json["leagueName"].stringValue
        let date = json["date"].stringValue
        let channelID = json["channelID"].stringValue
        let seen = json["seen"].boolValue
        let fe = UserNotification(image: imageString, message: message, type: type, teamID: teamID, teamName: teamName, date: date, leagueID: leagueID, leagueName: leagueName, channelID: channelID, seen: seen)
        self.notifications.insert(fe, at: 0)
        self.tableView.reloadData()
        
        if seen == false {
            if self.tabBarItem.badgeValue == nil {
                self.tabBarItem.badgeValue = "1"
            } else {
                self.tabBarItem.badgeValue = String(Int(self.tabBarItem.badgeValue!)! + 1)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        if indexPath.row < self.notifications.count {
            cell.backgroundColor = FunduModel.shared.hedgePrimaryColor
            cell.setupViews(data:notifications[indexPath.row])
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            print(notifications[indexPath.row].message)
        }
        if indexPath.row == 0 {
            cell.contentView.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, UIEdgeInsetsMake(0, 10, 10, 10))
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appearance = SCLAlertView.SCLAppearance (
            showCloseButton: false
        )
        print(indexPath.row)
        let cell : NotificationCell = (tableView.cellForRow(at: indexPath as IndexPath)! as? NotificationCell)!
        
        tableView.deselectRow(at: indexPath, animated: true)
        cell.notification.seen = false
        cell.toggleSeen()
        cell.reloadInputViews()
        
        if cell.notification.type == "teamInvite" {
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("Join team") {
                if cell.teamID != nil {
                    self.SharedFunduModel.addUserToTeam(userID: self.SharedFunduModel.myUser.userID, teamID: cell.teamID)
                    self.SharedFunduModel.addteamIDToUser(userID: self.SharedFunduModel.myUser.userID, teamID: cell.teamID, teamName: cell.teamName)
                    self.tabBarController?.selectedIndex = 2
                }
            }
            alert.addButton("Dismiss") {
                self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                alert.hideView()
            }
            alert.showInfo("Accept team invitation?", subTitle: "", colorStyle: UInt(SharedFunduModel.hedgePrimaryColorInt), colorTextButton: UInt(SharedFunduModel.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
        } else if cell.notification.type == "messageNotification" {
            tabBarController?.selectedIndex = 1
        } else if cell.notification.type == "stockNotification" {
            tabBarController?.selectedIndex = 0
        } else if cell.notification.type == "leagueInvite" {
            let alert = SCLAlertView(appearance: appearance)
            let leagueID = cell.notification.leagueID
            let leagueName = cell.notification.leagueName
            alert.addButton("Join League") {
                    if !self.SharedFunduModel.myUser.leagueIDs.contains(leagueID) {
                        self.SharedFunduModel.addTeamToLeague(newTeamID: self.SharedFunduModel.myUser.userID, newTeamName: self.SharedFunduModel.myUser.username, leagueID: leagueID)
                        self.SharedFunduModel.addLeagueIDToUser(userID: self.SharedFunduModel.myUser.userID, leagueID: leagueID, leagueName: leagueName)
                }
            }
            alert.addButton("Dismiss") {
                self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                alert.hideView()
            }
            alert.showInfo("Accept league invitation?", subTitle: "", colorStyle: UInt(SharedFunduModel.hedgePrimaryColorInt), colorTextButton: UInt(SharedFunduModel.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
        } else {
            cell.backgroundColor = FunduModel.shared.hedgeSecondaryColor
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell : NotificationCell = (tableView.cellForRow(at: indexPath as IndexPath)! as? NotificationCell)!
        
        if cell.notification.type == "teamInvite" {
            if self.SharedFunduModel.myUser.teamIDs.contains(cell.notification.teamID) {
                SCLAlertView().showInfo("You have already joined this team", subTitle: "", colorStyle: UInt(SharedFunduModel.hedgePrimaryColorInt), colorTextButton: UInt(SharedFunduModel.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
                return nil
            }
        } else if cell.notification.type == "leagueInvite" {
            if self.SharedFunduModel.myUser.leagueIDs.contains(cell.notification.leagueID) {
                SCLAlertView().showInfo("You have already joined this league", subTitle: "", colorStyle: UInt(SharedFunduModel.hedgePrimaryColorInt), colorTextButton: UInt(SharedFunduModel.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
                return nil
            }
        }
        
        if cell.notification.type != "teamInvite" &&
            cell.notification.type != "messageNotification" &&
            cell.notification.type != "leagueInvite" &&
            cell.notification.type != "stockNotification"
        {
            return nil
        } else {
            return indexPath
        }
    }
    
    func loadingAnimation() {
        self.activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.5, height: self.view.bounds.height * 0.5), type: .ballClipRotateMultiple, color: UIColor.white, padding: 0)
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.activityIndicatorView.heightAnchor.constraint(equalToConstant: self.view.bounds.height * 0.5).isActive = true
        self.activityIndicatorView.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.5).isActive = true
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0
    }
    
    func createConstraints() {
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        tableView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
    }
}
