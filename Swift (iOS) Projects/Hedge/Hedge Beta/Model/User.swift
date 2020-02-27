//
//  User.swift
//  fundü
//
//  Created by Adam Moffitt on 2/1/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class User : NSObject {
    var firstName : String
    var lastName : String
    var username : String
    var leagueIDs : [String] // leagues the user is a member of
    // var experience  TODO?
    var leagueNames : [String]
    var teamIDs : [String]
    var teamNames : [String]
    //Will only carry ID's and names
    var teams = [Team]()
    var userID : String
    var email : String
    var password : String
    var portfolio : NSDictionary
    var imageURL : String
    var teamBalances : [String:Double]
    var phoneNumber: String
    var availableBalance: Double
    var userStockPortfolio = [UserStock]()
    
    override init() {
        firstName = ""
        lastName = ""
        username = ""
        userID = ""
        leagueIDs = [String]()
        leagueNames = [String]()
        teamIDs = [String]()
        teamNames = [String]()
        email = ""
        password = ""
        imageURL = ""
        portfolio = [:] // not really used
        teamBalances = [:]
        phoneNumber = ""
        availableBalance = 0.0
    }
    
    convenience init(username: String) {
        self.init()
        self.username = username
    }
    
    convenience init (newFirstName: String, newLastName: String, newUsername: String, newEmail: String, newID: String, newImageURL: String) {
        self.init()
        self.username = newUsername
        self.email = newEmail
        self.userID = newID
        self.imageURL = newImageURL
        self.firstName = newFirstName
        self.lastName = newLastName
        
    }
    
    convenience init (newFirstName: String, newLastName: String, newUsername: String, newEmail: String, newID: String, newImageURL: String, leaguesDict: [String: String], teamsDict: [String: String]) {
        self.init()
        self.username = newUsername
        self.email = newEmail
        self.userID = newID
        self.imageURL = newImageURL
        self.firstName = newFirstName
        self.lastName = newLastName
        for (key,value):(String, String) in leaguesDict {
            //Do something you want
            self.leagueIDs.append(key)
            self.leagueNames.append(value)
        }
        for (key,value):(String, String) in teamsDict {
            //Do something you want
            self.teamIDs.append(key)
            self.teamNames.append(value)
        }
    }
    
    convenience init (newUsername: String, newEmail: String, newPassword: String, newID: String) {
        self.init()
        self.username = newUsername
        self.email = newEmail
        self.password = newPassword
        self.userID = newID
    }
    convenience init(dictionary: NSDictionary) {
        self.init()
        let json = JSON(dictionary)
        self.username = json["username"].stringValue
        self.firstName = json["firstName"].stringValue
        self.lastName = json["lastName"].stringValue
        self.userID = json["userID"].stringValue
        self.imageURL = json["imageURL"].stringValue
        self.email = json["email"].stringValue
        self.phoneNumber = json["phoneNumber"].stringValue
        //If json is .Dictionary
        for (key,subJson):(String, JSON) in json["leagueIDs"].dictionaryValue {
            //Do something you want
            self.leagueIDs.append(key)
            self.leagueNames.append(subJson.stringValue)
        }
        for (key,subJson):(String, JSON) in json["teamIDs"].dictionaryValue {
            //Do something you want
            self.teamIDs.append(key)
            self.teamNames.append(subJson.stringValue)
        }
        
//        availableBalance = json["availableBalance"].doubleValue // TODO GET BACKEND TO SUPPORT AVAILABLE BALANCE
    }
//    
//    convenience init(snapshot: DataSnapshot) {
//        self.init()
//        if !(snapshot.value is NSNull) {
//            let snapshotValue = snapshot.value as! [String: AnyObject]
//            //print(snapshotValue)
//            if snapshotValue["username"] != nil {
//                self.username = snapshotValue["username"] as! String
//            }
//            if snapshotValue["userID"] != nil {
//                self.userID = snapshotValue["userID"] as! String
//            }
//            if snapshotValue["firstName"] != nil {
//                self.firstName = snapshotValue["firstName"] as! String
//            }
//            if snapshotValue["lastName"] != nil {
//                self.lastName = snapshotValue["lastName"] as! String
//            }
//        }
//    }
    
    func toAnyObject() -> Any {
        
        var leaguesDict = NSMutableDictionary()
        for (index, id) in leagueIDs.enumerated() {
            print(id)
            if index < leagueNames.count {
                leaguesDict.setValue(leagueNames[index], forKey: id)
            }
        }
        var teamsDict = NSMutableDictionary()
        for (index, id) in teamIDs.enumerated() {
            print(id)
            if index < leagueNames.count {
                teamsDict.setValue(leagueNames[index], forKey: id)
            }
        }
        //let safeEmail = encodeForFirebaseKey(string: email)
        return [
            "firstName": firstName,
            "lastName": lastName,
            "username": username,
            "userID": userID,
            "leagueIDs": leaguesDict,
            "teamIDs": teamsDict,
            "imageURL" : imageURL,
            "email": email,
            "phoneNumber" : phoneNumber
        ]
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
}
