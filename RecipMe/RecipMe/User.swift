//
//  User.swift
//  RecipMe
//
//  Created by Adam Moffitt on 8/11/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import Foundation
import Firebase

/*
 * User
 */
class User {
    
        var history: [String] //History???????
        var superMarketId: Double
        var name: String
        var username: String
        var password: String
        var email:String
        var age:Int
        var gender: Character
        var userId: String

   init(){
        history = []
        superMarketId = 0
        //info
        name = "Default User"
        username = ""
        password = ""
        email = ""
        age = 0
        gender = "U"
        userId = ""

    }
    
    convenience init(email: String, pw: String){
        self.init()
        self.email = email
        self.password = pw
    }
    
    convenience init(username: String, email: String){
        self.init()
        self.username = username
        self.email = email
    }
    
    
    convenience init(userID: String, email: String){
        self.init()
        self.userId = userID
        self.email = email
    }
    
    convenience init(userID: String, username: String, email: String){
        self.init()
        self.username = username
        self.userId = userID
        self.email = email
    }


//    convenience init(authData: FIRUser) {
//        self.init()
//        userId = authData.uid
//        email = authData.email!
//    }
    
    func getSuperMarketId() -> Double {
        return superMarketId;
    }
    
    func setSuperMarketId(_ superMarketId: Double) {
        self.superMarketId = superMarketId;
    }
    func getName() -> String{
        return name;
    }
    
    func setName(_ name: String) {
        self.name = name;
    }
    
    func getPassword() -> String {
        return password;
    }
    
    func setPassword(_ password: String) {
        self.password = password;
    }
    func getEmail() -> String{
        return email;
    }
    
    func setEmail(_ email: String) {
        self.email = email;
    }
    
    //Preferences
    
    
    
}
