//
//  Team.swift
//  fundü
//
//  Created by Adam Moffitt on 2/6/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON
class Team : NSObject {

    var teamName : String
    var teamID : String
    var teamManager : String
    var members : [String:String] //userid to username
    var pendingMembers : [String:String] = [String:String]()
    var portfolio : Dictionary<String, Any>
    var stockQuantity:Int!
    var userBalance:Float = 0
    var teamScore:Int!
    var participatingLeagues = [League]()
    var teamUsers = [User]()
    var myUserStockPortfolio = [UserStock]()
    var overallStocks = [UserStock]()

    override init() {
        teamName = ""
        teamID = ""
        teamManager = ""
        members = [String:String]()
        portfolio = Dictionary()
    }

    convenience init(snapshot: DataSnapshot) {
        self.init()
        let key = snapshot.key
        let ref = snapshot.ref
        if !(snapshot.value is NSNull) {
            let snapshotValue = snapshot.value as! [String: AnyObject]
            //print(snapshotValue)
            if snapshotValue["teamName"] != nil {
                self.teamName = snapshotValue["teamName"] as! String
            }
            if snapshotValue["teamID"] != nil {
                self.teamID = snapshotValue["teamID"] as! String
            }
            if snapshotValue["members"] != nil {
                //Adam why were these [String:String]? - Jordan
                self.members = snapshotValue["members"] as! [String:String]
            }
            if snapshotValue["portfolio"] != nil {
                print(snapshotValue["portfolio"]!)
                self.portfolio = snapshotValue["portfolio"] as! Dictionary
            }
            if snapshotValue["teamManager"] != nil {
                self.teamManager = snapshotValue["teamManager"] as! String
            }
        }
    }

    convenience init(dictionary: NSDictionary) {
        self.init()
        print("dictionary: \(dictionary)")
            if dictionary["teamName"] != nil {
                self.teamName = dictionary["teamName"] as! String
            }
            if dictionary["teamID"] != nil {
                self.teamID = dictionary["teamID"] as! String
            }
            if dictionary["members"] != nil {
                //Adam why were these [String:String]? - Jordan
                self.members = dictionary["members"] as! [String:String]
            }
        }

    convenience init (member: User) {
        self.init()
        teamName = member.username
        teamID = member.userID
        teamManager = member.userID
        members.updateValue(member.username, forKey: member.userID)
    }

    convenience init (teamID: String, teamName: String, userBalance: Float, stockQuantity: Int){
        self.init()
        self.teamID = teamID
        self.teamName = teamName
        self.userBalance = userBalance
        self.stockQuantity = stockQuantity
    }

    convenience init (name:String, user:User){
        self.init()
        teamName = name
        teamID = user.userID
        teamManager = user.username
        members.updateValue(user.username, forKey: user.userID)
    }

    //Commented for a min
    convenience init (teamID: String, teamName: String, score: Int, leagues:[League], stocks: [UserStock], members: [String:String]){
        self.init()
        self.teamID = teamID
        self.teamName = teamName
        self.teamScore = score
        self.participatingLeagues = leagues
//        self.userStockPortfolio = stocks
        self.members = members
    }

    convenience init (newTeamName: String, members: [String:String], teamManager: String, pending: [String:String], id: String) {
        self.init()
        self.teamName = newTeamName
        self.teamID = id
        self.members = members
        self.pendingMembers = pending
        self.teamManager = teamManager
    }

    func toAnyObject()-> Any {
        return [
            "teamName" : teamName,
            "teamID" : teamID,
            "members" : members,
            "teamManager" : teamManager,
            "pendingMembers" : pendingMembers
        ]
    }
}
