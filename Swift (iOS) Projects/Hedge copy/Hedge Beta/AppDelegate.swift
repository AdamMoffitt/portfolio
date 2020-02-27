//
//  AppDelegate.swift
//  fundü
//
//  Created by Nicholas Kaimakis on 11/29/17.
//  Copyright © 2017 fundü. All rights reserved.
//

import UIKit
import SendBirdSDK
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import InstantSearch
import GoogleSignIn
import IQKeyboardManagerSwift
import SCLAlertView
import SwiftyJSON
import UserNotifications
import Fabric
import Crashlytics
import NVActivityIndicatorView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UNUserNotificationCenterDelegate, MessagingDelegate {  

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var activityIndicatorView: NVActivityIndicatorView!
    var fcmToken = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SBDMain.initWithApplicationId("4045412B-A24C-4B9E-8A43-32E2FFA96C36")
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.append(ConversationViewController.self)
        UIApplication.shared.applicationIconBadgeNumber = 0
        /* push notification stuff */
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM

            Messaging.messaging().delegate = self
            Messaging.messaging().shouldEstablishDirectChannel = true

        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        UIApplication.shared.statusBarStyle = .lightContent
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (success, error) in
            if error == nil {
                print("successful authorization")
            }
        })

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshToken(notification:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        /* end push notifications stuff */
        
        
        FirebaseApp.configure()
        
        //        Heap.setAppId("1361409317")
        //        Heap.enableVisualizer()
//        Appsee.start("470360183d0c4436a4fe231d955ac3a4")
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        let ALGOLIA_API_KEY = "2815378d9b95de8aefab224cc5acf10b"
        let ALGOLIA_APP_ID = "T7O9JPBG7J"
        let searcherIDs: [SearcherId] = [SearcherId.init(index: "companies"), SearcherId.init(index: "users"), SearcherId.init(index: "teams"), SearcherId.init(index: "leagues")]
        InstantSearch.shared.configure(appID: ALGOLIA_APP_ID, apiKey: ALGOLIA_API_KEY, searcherIds: searcherIDs)
        
        //create new window (where all view controllers appear)
        window = UIWindow(frame: UIScreen.main.bounds)
        
        //create new instance of view controller
        let loginViewController = AuthViewController()
        
        //set initial VC to our instance
        window?.rootViewController = loginViewController
        
        //present the window
        window?.makeKeyAndVisible()
        
        Fabric.with([Crashlytics.self])
        
        if let frame = self.window?.frame {
            print("frame found")
            activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), type: .ballClipRotateMultiple, color: UIColor.white, padding: 30.0)
        } else {
            print("frame not found")
            activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), type: .ballClipRotateMultiple, color: UIColor.white, padding: 30.0)
        }
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.backgroundColor = FunduModel.shared.funduColor
        self.window?.rootViewController?.view.addSubview(activityIndicatorView)
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            // 2
            let aps = notification["aps"] as! [String: AnyObject]
            // 3
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
         Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        
        print("NOTIFICATION RECEIVED 1 \(userInfo)")
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
         Messaging.messaging().appDidReceiveMessage(userInfo)
        
        print("NOTIFICATION RECEIVED 2 \(userInfo)")
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // silent push, just update app badge 
        if let _ = userInfo["type"] {
                UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
                print("APP BADGE NUMBER AFTER: \(UIApplication.shared.applicationIconBadgeNumber)")
                
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken.base64EncodedString())")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
        
    }
    
    
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        
//        return GIDSignIn.sharedInstance().handle(url,
//                                                 sourceApplication: sourceApplication,
//                                                 annotation: annotation)
//    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("app del error: \(error.localizedDescription)")
            return
        }
        
        print("app del: \(user!.userID)")
        print(user.profile.email)
        print(user.profile.name)
        
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let lastName = user.profile.familyName
        let givenName = user.profile.givenName
        print("given name: ")
        print(givenName!)
        let familyName = user.profile.familyName
        let username = givenName! + familyName!
        let email = user.profile.email
        let imageURL = String(describing: user.profile.imageURL(withDimension: 120)!)
        print(imageURL)
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                SCLAlertView().showError("Whoops!", subTitle: error.localizedDescription)
                return
            }
            
            let uid = Auth.auth().currentUser?.uid
            let newUser = User(newFirstName: givenName!, newLastName: lastName!, newUsername: username, newEmail: email!, newID: uid!, newImageURL : imageURL)
            
            self.promptChangeUsernameThenSegue(newUser: newUser)
        }
    }
    
    func sendHunterFCMToken(newUserID : String, token: String) {
        let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/fcmTokenMaybeAdd?userID=\(newUserID)&token=\(token)"
        let url = URL(string: (urlString))
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            else {
                print(data)
            }
        }
        task.resume()
    }

    func promptChangeUsernameThenSegue(newUser : User) {
        //TODO if user doesnt exists in database, create account
        Database.database().reference().child("users").child(newUser.userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()) {
                print("user is in database")
                self.sendHunterFCMToken(newUserID: newUser.userID, token: self.fcmToken)
                self.loadUserFromFirebaseThenSegue()
            } else {
                print("user not in database")
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alert = SCLAlertView(appearance:appearance)
                let usernameTF = alert.addTextField("New username")
                let alertViewIcon = UIImage(named: "hedgeLogo") //Replace the IconImage text with the image name

                alert.addButton("Change Username") {
                    if usernameTF.text != "" {
                        let newUsername = usernameTF.text!
                        var exists = false
                        let query = FunduModel.shared.ref.child("users").queryOrdered(byChild: "username")  //check username already exists
                        query.observeSingleEvent(of: .value, with: { (snapshot) in          // TODO MAKE HUNTER DO THIS IN CLOUD
                            let json = JSON(snapshot.value)
                            for (key,subJson):(String, JSON) in json {
                                if ( subJson.dictionaryValue["username"]?.stringValue == newUsername ) {
                                    exists = true
                                    print("already exists")
                                    let errorAlert = SCLAlertView(appearance: appearance)
                                    errorAlert.addButton("Okay") {
                                        self.promptChangeUsernameThenSegue(newUser : newUser)
                                    }
                                    errorAlert.showError("Great minds think alike!", subTitle: "That username is already taken. Choose another!")
                                    break
                                }
                            }
                            if !exists {
                                print("doesnt exist")
                                newUser.username = newUsername
                                
                                // TODO GET PHONE NUMBER
                                let appearance = SCLAlertView.SCLAppearance(
                                    showCloseButton: false
                                )
                                let phoneAlert = SCLAlertView(appearance:appearance)
                                let numberTF = phoneAlert.addTextField("Enter phone number")
                                phoneAlert.addButton("Next", action: {
                                    newUser.phoneNumber = numberTF.text!
                                    FunduModel.shared.setMyUser(newUser:newUser)
                                    FunduModel.shared.addNewUser(newUser: newUser, fcmToken: self.fcmToken)
                                    
                                    self.registerForRemoteNotifications()
                                    
                                    self.chooseGiftStock()
                                    
                                })
                                phoneAlert.addButton("Back") {
                                    self.promptChangeUsernameThenSegue(newUser : newUser)
                                }

                                phoneAlert.showEdit("Enter Phone Number", subTitle: "Don't worry, we won't send you any hotline bling. This is just for authentication purposes.", colorStyle: UInt(FunduModel.shared.hedgePrimaryColorInt), colorTextButton: UInt(FunduModel.shared.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
                            }
                        })
                    } else {
                        SCLAlertView().showError("Enter a value for username", subTitle: "")
                    }
                }
                alert.addButton("I like my name. Skip!") {
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let phoneAlert = SCLAlertView(appearance:appearance)
                    let numberTF = phoneAlert.addTextField("Enter phone number")
                    phoneAlert.addButton("Next", action: {
                        newUser.phoneNumber = numberTF.text!
                    
                        FunduModel.shared.setMyUser(newUser:newUser)
                        FunduModel.shared.addNewUser(newUser: newUser, fcmToken: self.fcmToken)
                        self.chooseGiftStock()
                    })
                    phoneAlert.addButton("Back") {
                        self.promptChangeUsernameThenSegue(newUser : newUser)
                    }
                    phoneAlert.showEdit("Enter Phone Number", subTitle: "This is just for authentication purposes. No hotline bling we promise.", colorStyle: UInt(FunduModel.shared.hedgePrimaryColorInt), colorTextButton: UInt(FunduModel.shared.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
                }
                alert.showEdit("Set your username", subTitle: "Right now your username is \(newUser.username). Change it below if you want!", colorStyle: UInt(FunduModel.shared.hedgePrimaryColorInt), colorTextButton: UInt(FunduModel.shared.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
                
            }
        })
    }
    
    func loadUserFromFirebaseThenSegue() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                print(dict)
                let SharedFunduModel = FunduModel.shared
                if let username = (dict["username"] as? String), let email = (dict["email"] as? String), let firstName = (dict["firstName"] as? String), let lastName = (dict["lastName"] as? String), let imageURL = (dict["imageURL"] as? String), let leaguesDict = (dict["leagueIDs"] as? [String:String]), let teamsDict = (dict["teamIDs"] as? [String:String]) {
                    let newUser = User(newFirstName: firstName, newLastName: lastName, newUsername: username, newEmail: email, newID: uid!, newImageURL: imageURL, leaguesDict: leaguesDict, teamsDict: teamsDict)
                    SharedFunduModel.setMyUser(newUser:newUser)
                    SharedFunduModel.loadUserTeams()
                } else {
                    print("ERROR LOADING USER FROM FIREBASE")
                }
            }
            print("should segue to main screen")
            
            self.moveToDashboardView()
            
        }, withCancel: nil)
        
    }
    
    func chooseGiftStock() {
        let pickerFrame: CGRect = CGRect(x:0, y:0, width: 200, height: 100); // CGRectMake(left), top, width, height) - left and top are like margins
        let picker: UIPickerView = UIPickerView(frame: pickerFrame)
        //set the pickers datasource and delegate
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(0, inComponent: 0, animated: true)
        picker.layer.borderColor = FunduModel.shared.funduColor.cgColor
        picker.layer.borderWidth = 1         //Add the picker to the alert controller
        
        let labelWidth = picker.frame.width
        let label: UILabel = UILabel.init(frame: CGRect(x:0,y: 0, width: labelWidth, height: 20))
        label.text = "Choose free stock"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        picker.addSubview(label)
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: picker.frame.size.width + 28.0,
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "hedgeLogo") 
        alert.customSubview = picker
        
        alert.addButton("Get started!") {
            var ticker = "AAPL"
            switch (picker.selectedRow(inComponent: 0)) {
            case 0: ticker = "AAPL"
            Answers.logCustomEvent(withName: "user chose Apple gift stock")
                
            case 1: ticker = "DIS"
            Answers.logCustomEvent(withName: "user chose Disney gift stock")
                
            case 2: ticker = "GOOG"
            Answers.logCustomEvent(withName: "user chose Google gift stock")
                
            case 3: ticker = "FB"
            Answers.logCustomEvent(withName: "user chose Facebook gift stock")
                
            default: ticker = "AAPL"
            }
            self.activityIndicatorView.startAnimating()
            FunduModel.shared.giftStockToUser(stockTicker: ticker, userID: FunduModel.shared.myUser.userID, teamID: FunduModel.shared.myUser.userID, completion: {
                self.registerForRemoteNotifications()
                
                //MOVE TO ONBOARDINGC
                let onboarding = OnboardingViewController()
                DispatchQueue.main.async {
                    self.window?.rootViewController = onboarding
                    self.window?.makeKeyAndVisible()
                    self.activityIndicatorView.stopAnimating()
                }
                
                //                self.moveToDashboardView()
            })
            
        }
        
        alert.showTitle("Congratulations on joining Hedge!", subTitle: "Here is $5,000 of stock to start with! Choose a company:", style: SCLAlertViewStyle.info, colorStyle: UInt(FunduModel.shared.hedgePrimaryColorInt), colorTextButton: UInt(FunduModel.shared.hedgeMainTextColorInt), circleIconImage: alertViewIcon)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let giftStocks = ["Apple", "Disney", "Google", "Facebook"]
        return giftStocks[row]
    }
    
    func moveToDashboardView() {
        print("moveToDashboardView")
        let tabBarVC = TabBarViewController()
        self.window?.rootViewController = tabBarVC
        self.window?.makeKeyAndVisible()
    }
    
    func registerForRemoteNotifications() {
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        // [END register_for_notifications]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("FROM PUSH: \(userInfo)")
        print(response.notification)
        print(2)
        print(response.notification.request.content)
        print(3)
        print(response.actionIdentifier)
        print(4)

        let aps = userInfo["aps"] as! [String: AnyObject]
        print(aps)
        
            if let type = userInfo["type"] {
                print(type)
                if type as! String == "teamInvite" {
                    // send to notifications view
                    (window?.rootViewController as? UITabBarController)?.selectedIndex = 3
                } else if type as! String == "leagueInvite" {
                    // send to notifications view
                    (window?.rootViewController as? UITabBarController)?.selectedIndex = 3
                } else if type as! String == "messageNotification" {
                    // send to messages view
                    let channelID = userInfo["channelID"] as! String
                    (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
                    if let inboxVC = ((window?.rootViewController as? UITabBarController)?.selectedViewController as? InboxTableViewController){
                        inboxVC.showChannel(channelID: channelID)
                    }
                } else {
                    (window?.rootViewController as? UITabBarController)?.selectedIndex = 2
                }
        }
        
        completionHandler()
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("app del  disconnect error: \(error.localizedDescription)")
            return
        }
        print("app del disconnect")
    }
    
    
    /* MESSAGING */
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("remote message: \(remoteMessage.appData)")
    }

    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token UNENCRYPTED: \(fcmToken)")
//        print("Firebase registration token: \(FunduModel.shared.encodeForFirebaseKey(string: fcmToken))")
        self.fcmToken = fcmToken
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]

    @objc func refreshToken(notification: NSNotification) {
        let refreshToken = InstanceID.instanceID().token()!
        print("*** \(refreshToken) ***")

        FBHandler()
    }

    func FBHandler() {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    /* END  MESSAGING */
}

