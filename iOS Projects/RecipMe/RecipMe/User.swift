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
        var fname: String
        var lname: String
        var username: String
        var password: String
        var email:String
        var age:Int
        var gender: String
        var uid: String
    var profilePicture: UIImage?
    var profilePictureImageURL: String
    var profilePictureID: String
    var cookingLevel: String

   init(){
        history = []
        superMarketId = 0
        //info
        fname = "Default"
        lname = "User"
        username = ""
        password = ""
        email = ""
        age = 0
        gender = "U"
        uid = ""
        cookingLevel = ""
        profilePicture = nil
        profilePictureImageURL = ""
        profilePictureID = ""
    }
    
    convenience init(email: String, pw: String){
        self.init()
        self.email = email
        self.password = pw
    }
    
    convenience init(email: String){
        self.init()
        self.email = email
    }
    
    convenience init(username: String, email: String){
        self.init()
        self.username = username
        self.email = email
    }
    
    convenience init(username: String, pass: String, email: String,
                     fname: String, lname: String, age: Int, gender: String, cookingLevel: String){
        self.init()
        self.username = username
        self.email = email
        self.password = pass
        self.age = age
        self.fname = fname
        self.lname = lname
        self.gender = gender
        self.cookingLevel = cookingLevel
        
    }
    
    convenience init(uid: String, email: String){
        self.init()
        self.uid = uid
        self.email = email
    }
    
    convenience init(uid: String, username: String, email: String){
        self.init()
        self.username = username
        self.uid = uid
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
        return fname.appending(lname);
    }
    
    func setFirstName(_ fname: String) {
        self.fname = fname;
    }
    
    func setLastName(_ lname: String) {
        self.lname = lname;
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
    
    func setUsername(_ username: String){
        self.username = username
    }
    func getUsername() -> String {
        return username
    }
    func setAge(_ age: Int){
        self.age = age
    }
    func getAge() -> Int {
        return age
    }
    func setCookingLevel(_ cookingLevel: String) {
        self.cookingLevel = cookingLevel
    }
    func getCookingLevel() -> String {
        return cookingLevel
    }
    func setGender(_ gender: String){
        self.gender = gender
    }
    func getGender() -> String{
        return gender
    }
    func setProfilePictureImageURL(_ url: String) {
        self.profilePictureImageURL = url
        if let data = try? Data(contentsOf: NSURL(string: url)! as URL) {
            print("got profile image")
            self.profilePicture = UIImage(data: data)!
        }
    }
    
    func toDictionary() -> Any {
        return [
            "FirstName":fname,
            "LastName":lname,
            "Username": username,
            "Password": password,
            "Email": email,
            "Age": age,
            "Gender":gender,
            "ProfilePictureImageURL": profilePictureImageURL,
            "Kitchen": []
        ]
    }
    
}
