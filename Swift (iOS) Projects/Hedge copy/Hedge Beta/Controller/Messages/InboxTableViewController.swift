//
//  MessagesTableViewController.swift
//  Hedge Beta
//
//  Created by Adam Moffitt on 3/30/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
import SCLAlertView

class InboxTableViewController: UITableViewController {
    
    let SharedFunduModel = FunduModel.shared
    var messages: [[String:Any]] = []
    var activityIndicatorView: NVActivityIndicatorView!
    var seen: [String:Bool] = [:]
    var newMessageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = SharedFunduModel.hedgePrimaryColor
        loadMessages()
        setObservers()
        self.title = "Inbox"
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        tableView.register(jordansWayMessagesTableViewCell.self, forCellReuseIdentifier: "jordansWayMessagesTableViewCell")
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: UIBarButtonItemStyle.done, target: self, action: #selector(writeNewMessage)) // get write message icon
        self.navigationController?.navigationBar.barTintColor = FunduModel.shared.hedgePrimaryColor
        self.navigationItem.rightBarButtonItem?.tintColor = .white
        self.tableView.backgroundColor = FunduModel.shared.hedgePrimaryColor
        tableView.separatorStyle = .none
        //you are setting for entire navigation bar
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), type: .ballClipRotateMultiple, color: UIColor.black, padding: 100.0)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
//        createNewMessageButton()
//        setConstraints()
    }
    
//    func createNewMessageButton(){
//        newMessageButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.16, height: self.view.frame.width * 0.16))
//        newMessageButton.layer.cornerRadius = newMessageButton.frame.size.width/2
//        newMessageButton.layer.masksToBounds = true
//        newMessageButton.setBackgroundImage(UIImage(named: "floatingAdd"), for: .normal)
//        newMessageButton.translatesAutoresizingMaskIntoConstraints = false
//        newMessageButton.addTarget(self, action: #selector(writeNewMessage), for: .touchUpInside)
//        newMessageButton.layer.shadowColor = UIColor.white.cgColor
//        newMessageButton.layer.shadowOffset = CGSize(width: 5, height: 5)
//        newMessageButton.layer.shadowRadius = 5
//        newMessageButton.layer.shadowOpacity = 1.0
//        self.view.addSubview(newMessageButton)
//    }
//    
//    func setConstraints(){
//        let margins = view.layoutMarginsGuide
//        newMessageButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
//        newMessageButton.bottomAnchor.constraintEqualToSystemSpacingBelow(margins.topAnchor, multiplier: 77).isActive = true
//        newMessageButton.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.16).isActive = true
//        newMessageButton.heightAnchor.constraint(equalToConstant: self.view.frame.width * 0.16).isActive = true
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadMessages()
        if self.tabBarItem.badgeValue != nil {
            let notificationsBadges = Int(self.tabBarItem.badgeValue!)
            self.tabBarItem.badgeValue = nil
        }
    }
    
    func setNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(newMessage(notification:)), name: Notification.Name(rawValue: "newMessageNotification"), object: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    @objc func newMessage(notification: NSNotification) {
        if self.tabBarItem.badgeValue == nil {
            self.tabBarItem.badgeValue = "1"
        } else {
            self.tabBarItem.badgeValue = String(Int(self.tabBarItem.badgeValue!)! + 1)
        }
        self.loadMessages()
    }
    
    func setObservers() {
        for (message) in SharedFunduModel.messageChannels {
            let channelID = message.first?.key as! String
            
            FunduModel.shared.ref.child("messages").child(channelID).child("users").observe(.childAdded, with: {(snapshot) in
                print("child added: \(snapshot)")
                let userID = snapshot.key
                let userSeen = snapshot.value as! Bool
                if userID == FunduModel.shared.myUser.userID {
                    self.seen[channelID] = userSeen
                    self.tableView.reloadData()
                }
            })
            
            FunduModel.shared.ref.child("messages").child(channelID).child("users").observe(.childChanged, with: {(snapshot) in
                print("child changed: \(snapshot)")
                let userID = snapshot.key
                let userSeen = snapshot.value as! Bool
                if userID == FunduModel.shared.myUser.userID {
                    self.seen[channelID] = userSeen
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func sortMessages() {
        print("reload data")
        self.messages.sort(by: { (message1, message2) -> Bool in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "UTC")
            let formattedDate1 = dateFormatter.date(from: message1["sentDate"] as! String)
            let formattedDate2 = dateFormatter.date(from: message2["sentDate"] as! String)
            let channel1 = message1["channelID"] as! String
            let channel2 = message2["channelID"] as! String
            return formattedDate1! > formattedDate2!
//            return (formattedDate1!, seen[channel1]!) > (formattedDate2!, seen[channel2]!)
        })
        self.tableView.reloadData()
        self.activityIndicatorView.stopAnimating()
    }
    
    func loadMessages() {
        
        for (index, message) in SharedFunduModel.messageChannels.enumerated() {
            
            let channelID = message.first?.key
            let messageName = message.first?.value
            SharedFunduModel.ref.child("messages").child(channelID!).child("messages").queryOrdered(byChild: "timestamp").queryLimited(toLast: 1).observe(.childAdded, with: { snapshot in
                print("SHOW MESSAGE SNAPSHOT: \(snapshot)")
                let json = JSON(snapshot.value)
                let message = [
                    "conversationName": messageName as! String,
                    "messageText": json["messageText"].stringValue,
                    "senderName": json["senderName"].stringValue,
                    "senderID": json["senderID"].stringValue,
                    "sentDate": json["sentDate"].stringValue,
                    "channelID": channelID as! String
                    ] as [String : Any]
                
                    if let index = self.messages.index(where: {
                        $0["conversationName"] as! String == messageName
                    }) {
                        self.messages[index] = message
                    } else {
                        self.messages.insert(message, at: 0)
                    }
                if (index == self.SharedFunduModel.messageChannels.count-1) {
                    self.sortMessages()
                }
            })
        }
    }
    
    
    
    func showChannel(channelID: String) {
        let conversationViewController = ConversationViewController()
        conversationViewController.channelID = channelID
        self.navigationController?.pushViewController(conversationViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jordansWayMessagesTableViewCell", for: indexPath) as!  jordansWayMessagesTableViewCell
//        cell.backgroundColor = UIColor.clear
        
        if indexPath.row < messages.count {
            cell.isImageSet = false
            let message = messages[indexPath.row]
            let senderID = message["senderID"] as! String
            let senderName = message["senderName"] as! String
            var messageText = message["messageText"] as! String
            var title = message["conversationName"] as! String
            let date = message["sentDate"] as! String
            let channelID = message["channelID"] as! String
            
            if title.count > 15 {
                title = title.prefix(14) + "..."
            }
            cell.title = title
            
            if messageText.count > 45 {
                messageText = messageText.prefix(44) + "..."
            }
            cell.message = "\(senderName): \(messageText)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "UTC")
            let formattedDate = dateFormatter.date(from: date)
            dateFormatter.dateFormat = "E, MMM d"
            dateFormatter.locale = NSLocale.current
            let formattedDateString = dateFormatter.string(from: formattedDate!)
            cell.date = formattedDateString
            
            if cell.resultImageButton != nil {
                if seen[channelID] != nil {
                    if seen[channelID] as! Bool {
//                        cell.resultImageButton.badgeString = ""
                    } else {
//                        cell.resultImageButton.badgeString = "1"
                        cell.backgroundColor = FunduModel.shared.hedgeHighlightColor
                    }
                }
            }
            
            FunduModel.shared.ref.child("users").child(senderID).child("imageURL").observeSingleEvent(of: .value, with: {(snapshot) in
                print(snapshot)
                if let value = snapshot.value as? String {
                    let urlString = value
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let data = try? Data(contentsOf: URL(string: urlString )!) {
                            DispatchQueue.main.async {
                                print("got image \(senderName): \(messageText) \(title) \(date) ")
                                if cell.isImageSet == false {
                                    cell.senderImage = UIImage(data: data)! // show image of last sender
                                    //                                cell.resultImage.layer.cornerRadius = cel..resultImage.frame.width/2
                                    //                                cell.resultImage.layer.masksToBounds = true
                                    //                                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                                    cell.reloadInputViews()
                                }
                            }
                        }
                    }
                }
            })
            //            cell.imageView?.image = UIImage(named: "coin")
            cell.setupViews(title: title, message: messageText, date: formattedDateString)
        }
        //        cell.setUpViews()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0//Choose your custom row height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationViewController = ConversationViewController()
        let message = messages[indexPath.row]
        conversationViewController.channelID = message["channelID"] as! String
        //conversationViewController.conversationName = messages[indexPath.row].
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(conversationViewController, animated: true)
    }
    
    @objc func writeNewMessage() {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "hedgeLogo") //Replace the IconImage text with the image name
        let teamName = alert.addTextField("To Member Name: ")
        let messageTV = alert.addTextView()
        alert.addButton("Send Message", backgroundColor: SharedFunduModel.hedgePrimaryColor) {
            //if textfields are both not empty, create new user (in firebase and model) and segway to parties
            if messageTV.text != "" {
                if(teamName.text != "") {
                    // SEARCH TEAMS ON FIREBASE TO CHECK IF EXISTS
                    let userNameEntered = teamName.text!
                    //check member exists
                    var exists = false
                    let query = FunduModel.shared.ref.child("users").queryOrdered(byChild: "username")  //check username already exists
                    query.observeSingleEvent(of: .value, with: { (snapshot) in          // TODO MAKE HUNTER DO THIS IN CLOUD
                        let json = JSON(snapshot.value)
                        for (key,subJson):(String, JSON) in json {
                            if ( subJson.dictionaryValue["username"]?.stringValue == userNameEntered ) {
                                exists = true
                                print("already exists")
                                
                                let messageText = messageTV.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                                let username1 = userNameEntered
                                let username2 = FunduModel.shared.myUser.username
                                let senderID = FunduModel.shared.myUser.userID
                                
                                let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/newChat?messageText=\(String(describing: messageText!))&userNames=\(username1)&userNames=\(username2)&senderID=\(senderID)"
                                let url = URL(string: (urlString))
                                print("get teams url: \(urlString)")
                                let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                                    if error != nil {
                                        print(error!)
                                    }
                                    else {
                                        
                                    }
                                }
                                task.resume()
                                break
                            }
                        }
                        if !exists {
                            // TODO neither team or member exists, invalid entry. Handle
                            SCLAlertView().showError("Team / User doesn't exist", subTitle: "Please enter another team / user name", closeButtonTitle: "Cancel")
                        }
                    })
                }
            }
        }
        
        alert.showInfo("Send Message", subTitle: "", closeButtonTitle: "Cancel", colorStyle: UInt(SharedFunduModel.hedgePrimaryColorInt), colorTextButton: UInt(SharedFunduModel.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
    }
    
    func showInviteFriendsToMessage() {
        
    }
    
}
