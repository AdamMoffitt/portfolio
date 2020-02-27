//
//  FunduModel.swift
//  fundü
//
//  Created by Adam Moffitt on 2/2/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SwiftyJSON
import Crashlytics
import Alamofire

protocol newLeagueDelegate
{
    func leagueAdded()
}

protocol newTeamDelegate
{
    func teamAdded()
}


class FunduModel {

    var ref: DatabaseReference!
    var partiesChanged = true
    var storage : Storage
    var storageRef : StorageReference
    var myUser : User
    var userLeagues : [League]
    var allLeagues : [League]
    var funduColor = UIColor(red: 58/255, green: 77/255, blue: 95/255, alpha: 1)
    var funduColorInt: UInt = UInt(0xA429FF) // TODO Change
    var funduTitleFont = UIFont(name: "DidactGothic-Regular", size: 28)
    var teamBalanceAddedHandle : DatabaseHandle?
    var teamBalanceChangedHandle : DatabaseHandle?
    var teamBalanceRemovedHandle : DatabaseHandle?
    var userTeamsPortfolios : [String:NSDictionary] //dictionary of overall and team portfolio values for that user
    var popularStocks = ["AAPL", "TSLA", "GOOG", "FB", "AMZN","SNAP", "NFLX", "NIKE", "BABA", "F", "GM", "PG", "DIS"]
    var watchedStocks: [String] = []
    let hedgeSoloLeagueID = "F5D5C146-F534-4D73-B049-BF51AD6D40C5"
    var leaderboardTeams = [[LeagueTeam]]()
    var messageChannels: [[String:String]]
    var newMessages = 0
    //singleton
    static var shared = FunduModel()
    var newLeagueDelegate: newLeagueDelegate?
    var newTeamDelegate: newTeamDelegate?

    // Colors
    var hedgePrimaryColor = UIColor(red: 58/255, green: 77/255, blue: 95/255, alpha: 1) //background
    var hedgePrimaryColorInt = 3820895
    var hedgeSecondaryColor = UIColor(red: 71/255, green: 89/255, blue: 106/255, alpha: 1) //(For cells and menubar and searchers)
    var hedgeHighlightColor = UIColor(red: 58/255, green: 77/255, blue: 95/255, alpha: 1) //(for selection or highlight)
    var hedgeMainTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1) //for text colors, main text
    var hedgeMainTextColorInt = 16777215
    var hedgeMinorTextColor = UIColor(red: 129/255, green: 134/255, blue: 139/255, alpha: 1) //minor text colors
    var hedgeMinorTextColorInt = 8488587
    var hedgeGainColor = UIColor(red: 5/255, green: 220/255, blue: 174/255, alpha: 1) // Green 5,220,174
    var hedgeLossColor = UIColor(red: 248/255, green: 33/255, blue: 98/255, alpha: 1) // Red is 248,33,98


    init() {
        ref = Database.database().reference()

        // Get a reference to the storage service using the default Firebase App
        storage = Storage.storage()
        // Create a storage reference from our storage service
        storageRef = storage.reference()

        myUser = User()
        userLeagues = []
        allLeagues = []
        userTeamsPortfolios = [:]
        messageChannels = []
        loadAllLeaguesFromFirebase(completionHandler: { print("load all leagues from firebase model completion") })
    }

    deinit {
        print("deinit")

        if let refHandleAdd = teamBalanceAddedHandle {
            self.ref.child("user").child(myUser.userID).child("team_balances").removeObserver(withHandle: refHandleAdd)
        }
        if let refHandleRemove = teamBalanceRemovedHandle {
            self.ref.child("user").child(myUser.userID).child("team_balances").removeObserver(withHandle: refHandleRemove)
        }
        if let refHandleObserve = teamBalanceChangedHandle {
            self.ref.child("user").child(myUser.userID).child("team_balances").removeObserver(withHandle: refHandleObserve)
        }
    }

    func setMyUser(newUser: User) {
        myUser = newUser
        loadUserFromFirebase(completionHandler: {
            print("completion")
            self.observeUserTeamBalances()
            self.loadUserLeaguesFromFirebase(completion: {
                print("load all leagues from firebase model completion")
                self.getLeaderboardTeams(completion: {
                    print("get leaderboard teams completion")
                    self.observeUserLeagueIDs()
                    self.observeUserTeamIDs()
                })
            })
            self.getUserTeamPortfolios()
        })
    }

    func addNewUser(newUser: User, fcmToken: String) {
        ref.child("users").child(newUser.userID).setValue(newUser.toAnyObject())
        ref.child("users").child(newUser.userID).child("notificationToken").child(fcmToken).setValue(true)
        let team = Team(member: newUser)
        newTeam(team: team)
        //Now doing stock gifting from app delegate
        //        let upper = self.popularStocks.count
        //        let randomNumber = arc4random_uniform(UInt32(upper))
        //        let s = popularStocks[Int(randomNumber)]
        //        giftStockToUser(stockTicker: s, userID: newUser.userID, teamID: team.teamID)
        addteamIDToUser(userID: newUser.userID, teamID: team.teamID, teamName: team.teamName)
        addTeamToHedgeLeague(newTeam: team)
    }

    func removeNotification(notificationID: String) {
        ref.child("users").child(myUser.userID).child("notifications").child(notificationID).removeValue()
    }

    func addUserToTeam(userID: String, teamID: String) {

        let urlString = URL(string: "https://us-central1-hedge-beta.cloudfunctions.net/addUserToTeam?userID=\(userID)&teamID=\(teamID)")
        print(urlString ?? "")
        if let url = urlString {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let usableData = data {
                        print(usableData) // JSONSerialization
                        let json = JSON(data!)
                        print(json.stringValue)
                    }
                }
            }
            task.resume()
        }
        self.ref.child("team").child(teamID).observeSingleEvent(of: .value, with: {(snapshot) in
            if let dict = (snapshot.value! as? NSDictionary) {
                if let teamName = dict["teamName"] {
                    self.addteamIDToUser(userID: userID, teamID: teamID, teamName: teamName as! String)
                }
            }
        })
    }

    func newLeague(league: League) {
        print("add league: \(league.leagueID) \(league.toAnyObject())")
        self.ref.child("leagues").child(league.leagueID).setValue(league.toAnyObject())
    }

    func addTeamToLeague(newTeamID: String, newTeamName: String, leagueID: String) {
        print("add team to league \(newTeamName) \(newTeamID) \(leagueID)")
        self.ref.child("leagues").child(leagueID).child("teams").child(encodeForFirebaseKey(string: newTeamID)).setValue(newTeamName)
    }

    // Every user should be added to the overall Hedge League when they are created
    func addTeamToHedgeLeague(newTeam: Team) {
        self.ref.child("leagues").child(hedgeSoloLeagueID).child("teams").child(encodeForFirebaseKey(string: newTeam.teamID)).setValue(newTeam.teamName)
        addLeagueIDToUser(userID: myUser.userID, leagueID: hedgeSoloLeagueID, leagueName: "Hedge League")
    }

    func addTeamToHedgeTeamsLeague(newTeam: Team) {
        self.ref.child("leagues").child("341837B0-9E31-4F9A-A2B2-433A876DDBA7").child("teams").child(encodeForFirebaseKey(string: newTeam.teamID)).setValue(newTeam.teamName)
        addLeagueIDToUser(userID: myUser.userID, leagueID: "341837B0-9E31-4F9A-A2B2-433A876DDBA7", leagueName: "HedgeTeams")
    }

    func addLeagueIDToUser(userID: String, leagueID: String, leagueName: String) {
        print("add leagueID to \(userID) with league name \(leagueName)")
        self.ref.child("users").child(userID).child("leagueIDs").child(leagueID).setValue(leagueName)
        myUser.leagueIDs.append(leagueID)
        myUser.leagueNames.append(leagueName)
    }

    func addteamIDToUser(userID: String, teamID: String, teamName: String) {
        self.ref.child("users").child(userID).child("teamIDs").child(teamID).setValue(teamName)
        myUser.teamIDs.append(teamID)
        myUser.teamNames.append(teamName)
        let t = Team()
        t.teamID = teamID
        t.teamName = teamName
        myUser.teams.append(t)
    }

    func newTeam(team: Team) {
        self.ref.child("teams").child(team.teamID).setValue(team.toAnyObject())
    }

    func addWatchStockToUser(stockTicker: String) {
        //TODO error check to not put repeat stocks
        self.ref.child("users").child(myUser.userID).child("marketWatch").child(stockTicker).setValue(true)
    }

    func giftStockToUser(stockTicker: String, userID: String, teamID: String, completion: @escaping () -> ()) {
        // TODO hit Hunter with call to give user free stock
        Answers.logCustomEvent(withName: "user gets gift stock")

        let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/giftStock?ticker=\(stockTicker)&value=\(5000)&user=\(userID)&team=\(teamID)&gift=true"
        let url = URL(string: (urlString))
        print("buy: \(String(describing: url))")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            else {
                let urlContent = JSON(data)
                do {
                    print(urlContent)
                    self.getUserTeamPortfolios()
                    completion()
                } catch {
                    print("error processing JSON")
                }
            }
        }
        task.resume()
    }

    func getUserTeamBalance(teamID: String, completion: @escaping (Double)->()) { // get user balance for a team from teams branch of database
        let urlString = URL(string: "https://us-central1-hedge-beta.cloudfunctions.net/userPortfolio?user=\(teamID)")
        print(urlString ?? "")
        if let url = urlString {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let usableData = data {
                        print(usableData) // JSONSerialization
                        let json = JSON(data!)
                        let balance = json.doubleValue
                        print("BALANCE: \(balance)")
                        completion(balance)
                    }
                }
            }
            task.resume()
        }
    }

    func getUserTeamPortfolios() {
        let urlString = URL(string: "https://us-central1-hedge-beta.cloudfunctions.net/userPortfolio?user=\(myUser.userID)")
        print(urlString!)
        if let url = urlString {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error ?? "")
                } else {
                    if let usableData = data {
                        print(usableData) // JSONSerialization
                        let json = JSON(data as Any)
                        // If json is .Dictionary
                        for (key1,subJson1):(String, JSON) in json {
                            var team : [String:NSDictionary] = [:]
                            for (key2,subJson2):(String, JSON) in subJson1 {
                                var stock : [String:Any] = [:]
                                stock.updateValue(key2, forKey: "stockName")
                                stock.updateValue(subJson2["quantity"].intValue, forKey:"quantity" )
                                stock.updateValue(subJson2["total_value"].floatValue, forKey: "total_value")
                                team.updateValue(stock as NSDictionary, forKey: key2)
                            }
                            self.userTeamsPortfolios.updateValue(team as NSDictionary, forKey: key1)
                        }
                        print("done getUserTeamPortfolio")
                    }
                }
            }
            task.resume()
        }
    }

    func getUserTeamPortfolioValue(teamID: String) -> Double {
        if let teamPortfolio = userTeamsPortfolios[teamID] {
            let json = JSON(teamPortfolio)
            var moneyValue = 0.0
            for (_, subjson) in json {
                moneyValue = moneyValue + subjson["total_value"].doubleValue
            }
            return moneyValue
        }
        return 0.0
    }

    func getUserTeamForLeague(leagueID: String) -> String {
        let league = userLeagues.first(where: { $0.leagueID == leagueID })
        let team = league?.teams.first(where: {
            myUser.teamIDs.contains($0)
        })
        if team != nil {
            return team!
        } else {
            return ""
        }
    }

    func loadTeam(teamID: String, completion: @escaping (Team) -> Void){
        let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/testMissionControl?userID=\(myUser.userID)&teamID=\(teamID)"
        print("teammissioncontrol: \(urlString)")
        Alamofire.request(urlString).validate().responseJSON { (response) in
            let json = JSON(response.value as Any)
            var userTeam = Team()
            userTeam.teamID = teamID
            //Parse teams
            let team = json["portfolios"].dictionaryValue
            print(json["portfolios"].dictionaryValue)
            for (key,subJson):(String, JSON) in team {

                let user = User()
                user.userID = key

                //Parse team portfolio
                for (key2, subJson2) in (team[key]?.dictionaryValue)! {
                    let totalValue = subJson2["totalValue"].floatValue
                    let numShares = subJson2["numShares"].intValue
                    let ticker = key2
                    let price = subJson2["price"].floatValue
                    let percentChange = subJson2["percentChange"].floatValue
                    let companyName = subJson2["companyName"].stringValue
                    user.userStockPortfolio.append(UserStock(price: price, quantity: numShares, ticker: ticker, totalValue: totalValue, percentChange: percentChange, companyName: companyName, username: ""))
                }
                if(user.userID == self.myUser.userID){
                    userTeam.myUserStockPortfolio = user.userStockPortfolio
                }
                userTeam.teamUsers.append(user)
            }
            //Parse leagues
            for(key3, subJson3) in json["leagues"]{
                let league = League()
                print(subJson3)
                league.leagueID = key3
                league.leagueName = subJson3["leagueName"].stringValue
                league.teamRank = subJson3["rank"].intValue
                league.teamPercentChange = subJson3["changePercent"].floatValue
                userTeam.participatingLeagues.append(league)
            }
            var userCount = 0
            for user in userTeam.teamUsers {
                self.fetchUser(userID: user.userID, completionHandler: { (retrievedUser) in
                    user.username = retrievedUser.username
                    if(user.userID != self.myUser.userID){
                        for stock in user.userStockPortfolio {
                            userTeam.overallStocks.append(UserStock(price: stock.price, quantity: stock.quantity, ticker: stock.ticker, totalValue: stock.totalValue, percentChange: stock.percentChange, companyName: stock.companyName, username: user.username))
                        }
                    }
                    if userCount == userTeam.teamUsers.count - 1 {
                        completion(userTeam)
                    } else {
                        userCount = userCount + 1
                    }
                })
            }
            //I think here
            if(userTeam.teamUsers.count == 0 ) {
                completion(userTeam)
            }
        }
    }

    //subJson2["quantity"].intValue
    func loadUserTeams(){
        let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/teamMissionControl?userID=\(myUser.userID)"
        print("teammissioncontrol: \(urlString)")
        Alamofire.request(urlString).validate().responseJSON { (response) in
            let json = JSON(response.value as Any)
            var userTeams = [Team]()

            //Parse teams
            let team = json["teams"].dictionaryValue
            print("teams JSON")
            print(urlString)
            print(json["teams"].dictionaryValue)
            for (key,subJson):(String, JSON) in team {

                //Ignore aggregate from Hunter for now
                if key == "overall" {
                    continue
                }

                //Setup containers
                var stocks = [UserStock]()
                var teamLeagues = [League]()
                var teammates = [String:String]()

                //Parse leagues the team participates in
                for (key2, subJson2) in subJson["leagues"].dictionaryValue {
                    var l = League(name: key2)
                    l.teamRank = subJson2.intValue
                    teamLeagues.append(l)

                }

                //Parse team portfolio
                for(key3, subJson3) in subJson["teamPortfolio"]{
//                    stocks.append(UserStock(price: subJson3["total_value"].floatValue / subJson3["quantity"].floatValue, quantity: subJson3["quantity"].intValue, ticker: key3, totalValue: subJson3["total_value"].floatValue, percentChange: subJson3["changePercent"].floatValue))
                }

                //Get teammates
                for(key4, subJson4) in subJson["teammates"].dictionaryValue {
                    teammates.updateValue(subJson4.stringValue, forKey: key4)
                }

                //Populate Team objects
                let t = Team(teamID: subJson["teamID"].stringValue, teamName: subJson["teamName"].stringValue, score: subJson["score"].intValue, leagues: teamLeagues, stocks: stocks, members: teammates)

                userTeams.append(t)
            }
            print(userTeams)
            var tArray = [String]()
            var idArray = [String]()
            var teamsSorted = [Team]()
            
            //Sort data
            for t in self.myUser.teamNames {
                for uT in userTeams {
                    if(uT.teamName == t){
                        tArray.append(uT.teamName)
                        idArray.append(uT.teamID)
                        teamsSorted.append(uT)
                    }
                }
            }
            self.myUser.teamNames = tArray
            self.myUser.teamIDs = idArray
            self.myUser.teams = teamsSorted
        }
    }

    func checkOwnership(ticker:String, completion: @escaping ([Team], Bool) -> Void){
        let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/userHasStock?userID=\(FunduModel.shared.myUser.userID)&ticker=\(ticker)"
        print("userHasStock: \(urlString)")
        var owned:Bool = false
        var userTeams = [Team]()
        Alamofire.request(urlString).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    if let teams = json["teams"].array {
                        if json["isOwned"].boolValue {
                            owned = true
                        }
                        for team in teams {
                            let t = Team(teamID: team["teamID"].string!, teamName: team["teamName"].string!, userBalance: team["userBalance"].float!, stockQuantity: team["quantity"].int!)
                            userTeams.append(t)
                        }
                    }
                }
                completion(userTeams, owned)
            case .failure(let error):
                print(error)
            }
        }
    }

    func observeUserTeamBalances() { // keep team balances updated by observing team balances in users branch of database
        print("observe user team balances")
        teamBalanceChangedHandle = self.ref.child("users").child(myUser.userID).child("team_balances").observe(.childChanged, with: {
            (snapshot) in
            print("child changed: \(String(describing: snapshot.value))")
            //let json = JSON(snapshot.value!)
            let key = snapshot.key
            if let value = snapshot.value as? NSNumber {
                self.myUser.teamBalances[key] = (value.doubleValue).rounded(toPlaces: 2)
            }
        })
        teamBalanceAddedHandle = self.ref.child("users").child(myUser.userID).child("team_balances").observe(.childAdded, with: {
            (snapshot) in
            print("child added: \(String(describing: snapshot.value!))")
            //let json = JSON(snapshot.value!)
            let key = snapshot.key
            if let value = snapshot.value as? NSNumber {
                self.myUser.teamBalances[key] = (value.doubleValue).rounded(toPlaces: 2)
            }
        })
        teamBalanceRemovedHandle = self.ref.child("users").child(myUser.userID).child("team_balances").observe(.childRemoved, with: {
            (snapshot) in
            print("child removed: \(String(describing: snapshot.value))")
            //let json = JSON(snapshot.value!)
            let key = snapshot.key
            self.myUser.teamBalances[key] = 0
        })
    }

    func fetchUser(userID: String, completionHandler: @escaping (User) -> Void) {
        ref.child("users").child(userID).observe(DataEventType.value, with: { (snapshot) in
            if !snapshot.exists() {
                return
            }
            completionHandler(User(dictionary: snapshot.value as! NSDictionary))
        })
    }
    
    func observeUserLeagueIDs() {
        self.ref.child("users").child(myUser.userID).child("leagueIDs").observe(.childAdded, with: {
            (snapshot) in
            let leagueID = snapshot.key
            if !self.myUser.leagueIDs.contains(leagueID) {
                self.loadUserLeaguesFromFirebase(completion: {
                    self.getLeaderboardTeams(completion: {
                        self.newLeagueDelegate?.leagueAdded()
                    })
                })
            }
        })
    }
    
    func observeUserTeamIDs() {
        self.ref.child("users").child(myUser.userID).child("teamIDs").observe(.childAdded, with: {
            (snapshot) in
            let teamID = snapshot.key
            if !self.myUser.teamIDs.contains(teamID) {
    //            self.loadUserTeams()
                self.newTeamDelegate?.teamAdded()
            }
        })
    }

    /******************* load leagues from firebase - observe *******************/
    func loadUserFromFirebase(completionHandler: @escaping () -> Void) {
        print("userID: \(myUser.userID)")
        ref.child("users").child(myUser.userID).observe(DataEventType.value, with: { (snapshot) in
            if !snapshot.exists() {
                return
            }
            self.myUser = User(dictionary: snapshot.value as! NSDictionary)
            print(self.myUser.toAnyObject())
            completionHandler()
        })
        completionHandler()
    }
    /****************************************************************************/

    /******************* load leagues from firebase - observe *******************/
    func loadAllLeaguesFromFirebase(completionHandler: @escaping () -> Void) {
        ref.child("leagues").observe(DataEventType.value, with: { (snapshot) in
            if !snapshot.exists() {
                return
            }
            var newLeagues : [League] = []
            for child in (snapshot.children.allObjects as? [DataSnapshot])! {
                let league = League(snapshot: child )
                print(league.leagueName)
                newLeagues.append(league)
            }
            self.allLeagues = newLeagues
        })
        completionHandler()
    }
    /****************************************************************************/


    func inviteUserToTeam(invitedID: String, teamID: String) {
        Answers.logCustomEvent(withName: "user invites other user to team")

        let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/sendTeamInvite?inviterID=\(myUser.userID)&invitedID=\(invitedID)&imageString=\(myUser.imageURL)&type=teamInvite&team=\(teamID)"
        if let url = URL(string: (urlString)) {
            print("invite: \(String(describing: url))")
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                }
                else {
                    let urlContent = JSON(data)
                    print(urlContent.stringValue)
                }
            }
            task.resume()
        }
    }

    func inviteTeamToLeague(invitedTeamID: String, leagueID: String, leagueName: String) {
        Answers.logCustomEvent(withName: "user invites other user to league")

        let urlString = ("https://us-central1-hedge-beta.cloudfunctions.net/sendLeagueInvite?inviterName=\(myUser.username)&inviterID=\(myUser.userID)&teamID=\(invitedTeamID)&imageString=\(myUser.imageURL)&leagueID=\(leagueID)&leagueName=\(leagueName)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: (urlString)!) {
            print("invite to league: \(String(describing: url))")
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                }
                else {
                    let urlContent = JSON(data)
                    print(urlContent.stringValue)
                }
            }
            task.resume()
        }
    }

    //    func getUserIDFromName(username: String) -> String {
    //
    //        ref.child("users").observeSingleEvent(of: .value, with: {(snapshot) in
    //            let json = JSON(snapshot.value)
    //            for (key, subJson) in json {
    //                 let name = subJson["username"].stringValue
    //                    if name == username {
    //                        let id = subJson["userID"].stringValue
    //                        return id
    //                    }
    //            }
    //        })
    //    }

    /**************************************************************************/
    func loadUserLeaguesFromFirebase(completion: @escaping () -> Void) {

        print("load user leagues")
        var counterDone = 0
        for (index,leagueID) in myUser.leagueIDs.enumerated() {
            // check that league is not already in user leagues
            if let _ = userLeagues.index(where: {
                $0.leagueID == leagueID
            }) {
                print("league already in model")
                counterDone = counterDone + 1
                if (counterDone == myUser.leagueIDs.count-1) {
                    completion()
                }
            } else {
                ref.child("leagues").child(leagueID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                    if snapshot.exists() {

                        let league = League(snapshot: snapshot )

                        print("load league: \(league.leagueName)")
                        if !self.userLeagues.contains(where: { $0.leagueID == league.leagueID }) {
                            self.userLeagues.append(league)
                            self.leaderboardTeams.append([])
                            counterDone = counterDone + 1
                            if (counterDone == self.myUser.leagueIDs.count-1) {
                                completion()
                            }
                        }
                    }
                })
            }
        }
    }
    /**************************************************************************/

    /****************************************************************************/
    func buyStock(stockSymbol: String, numberShares: Int,sharePrice: Float, teamID: String, completion: @escaping ()->Void) {
        Answers.logCustomEvent(withName: "user buy stock")

        let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/transferStocks?ticker=\(stockSymbol)&amount=\(numberShares)&price=\(sharePrice)&user=\(myUser.userID)&team=\(teamID)&buy=true"
        let url = URL(string: (urlString))
        print("buy: \(String(describing: url))")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            else {
                let urlContent = JSON(data)
                do {
                    print(urlContent)
                    self.getUserTeamPortfolios()
                    completion()
                } catch {
                    print("error processing JSON")
                }
            }
        }
        task.resume()
    }

    func sellStock(stockSymbol: String, numberShares: Int, sharePrice: Float, teamID: String, completion: @escaping ()->Void) {
        Answers.logCustomEvent(withName: "user sell stock")
        let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/transferStocks?ticker=\(stockSymbol)&amount=\(numberShares)&price=\(sharePrice)&user=\(myUser.userID)&team=\(teamID)&buy=false"
        let url = URL(string: (urlString))
        print("buy: \(String(describing: url))")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            else {
                if let urlContent = data {
                    do {
                        print(urlContent)
                        let result = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        print(result)
                        self.getUserTeamPortfolios()
                        completion()
                    } catch {
                        print("error processing JSON")
                    }
                }
            }
        }
        task.resume()
    }

    func userOwnsStock(stockName: String) -> Bool {
        print(stockName)
        for (_, teamDict) in userTeamsPortfolios {
            for (name, _) in teamDict {
                if stockName.caseInsensitiveCompare(name as! String) == ComparisonResult.orderedSame {
                    return true
                }
            }
        }
        return false
    }

    func observeMessageChannels() {

        self.ref.child("users").child(myUser.userID).child("messageIDs").observe(.childAdded, with: {
            (snapshot) in
            let messageID = snapshot.key
            let messageTitle = snapshot.value! as! String
            print("message id added: \(String(describing: messageID))")

            if !self.messageChannels.contains([messageID:messageTitle]) {
                self.messageChannels.append([messageID:messageTitle])
                self.ref.child("messages").child(messageID).child("users").observe(.childChanged, with: {(snapshot) in
                    let json = JSON(snapshot.value)

                    NotificationCenter.default.post(name: Notification.Name(rawValue: "newMessageNotification"), object: nil)
                    //                            self.newMessages = self.newMessages+1
                })
            }
        })
    }

    func observeNotifications() {

        //        let unseenNotificationsQuery =  self.ref.child("users").child(myUser.userID).child("notifications").queryEqual(toValue: false, childKey: "seen")
        //        print("UNSEEN NOTIFICATIONS: \(unseenNotificationsQuery)")

        self.ref.child("users").child(myUser.userID).child("notifications").observe(.childAdded, with: {
            (snapshot) in
            let notificationID = snapshot.key
            print("notification added: \(String(describing: notificationID))")
            let json = JSON(snapshot.value)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "newNotification"), object: nil, userInfo: json.dictionaryObject)
        })
    }

    func isTeamNameUnique(teamName: String, completion: @escaping (Bool) -> Void) {
        var urlString = "https://us-central1-hedge-beta.cloudfunctions.net/isNameUnique?teamName=\(FunduModel.shared.encodeForFirebaseKey(string: teamName))"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Alamofire.request(urlString).validate().responseString { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    completion(Bool(value)!)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func isUserNameUnique(teamName: String, completion: @escaping (Bool) -> Void) {
        var urlString = "https://us-central1-hedge-beta.cloudfunctions.net/isNameUnique?userName=\(FunduModel.shared.encodeForFirebaseKey(string: teamName))"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Alamofire.request(urlString).validate().responseString { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    completion(Bool(value)!)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func isLeagueNameUnique(teamName: String, completion: @escaping (Bool) -> Void) {
        var urlString = "https://us-central1-hedge-beta.cloudfunctions.net/isNameUnique?leagueName=\(FunduModel.shared.encodeForFirebaseKey(string: teamName))"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Alamofire.request(urlString).validate().responseString { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    completion(Bool(value)!)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    // get teams that are in each league that the user belongs to in order to display them in leaderboards tab
    func getLeaderboardTeams (completion: @escaping () -> Void) {
        var counterDone = 0
        for (index, league) in self.userLeagues.enumerated() {
            let leagueID = league.leagueID
            let urlString = "https://us-central1-hedge-beta.cloudfunctions.net/leagueValues?leagueID=\(leagueID)"
            let url = URL(string: (urlString))
            print("get teams url: \(urlString)")
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil {
                    print(error!)
                }
                else {
                    if let urlContent = data {
                        print(urlContent)
                        let json = JSON(urlContent)

                        for (_,subJson):(String, JSON) in json {
                            for (_,subJson1):(String, JSON) in subJson {
                                let leagueTeam = LeagueTeam(dictionary: subJson1.dictionaryObject! as NSDictionary)
                                print("League team: \(leagueTeam.teamName)")
                                if index < self.leaderboardTeams.count {
                                    if !self.leaderboardTeams[index].contains(where: { $0.teamID == leagueTeam.teamID }) {
                                        self.leaderboardTeams[index].append(leagueTeam)
                                    }
                                }
                            }
                        }
                        counterDone = counterDone + 1
                        if (counterDone >= self.userLeagues.count-1) {
                            completion()
                        }
                    }
                }
            }
            task.resume()
        }
    }

    func encodeForFirebaseKey(string: String) -> (String){
        var string1 = string.replacingOccurrences(of: "_", with: "__")
        string1 = string1.replacingOccurrences(of: ".", with: "_P")
        string1 = string1.replacingOccurrences(of: "$", with: "_D")
        string1 = string1.replacingOccurrences(of: "#", with: "_H")
        string1 = string1.replacingOccurrences(of: "[", with: "_O")
        string1 = string1.replacingOccurrences(of: "]", with: "_C")
        string1 = string1.replacingOccurrences(of: "/", with: "_S")
        return string1
    }

    func decodeFromFireBaseKey (string: String) -> (String) {
        var string1 = string.replacingOccurrences(of: "__" , with: "_")
        string1 = string1.replacingOccurrences(of: "_P", with: ".")
        string1 = string1.replacingOccurrences(of: "_D", with: "$")
        string1 = string1.replacingOccurrences(of: "_H", with: "#")
        string1 = string1.replacingOccurrences(of: "_O", with: "[")
        string1 = string1.replacingOccurrences(of: "_C", with: "]")
        string1 = string1.replacingOccurrences(of: "_S", with: "/")
        return string1
    }
}
