//
//  RecipMeModel.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/3/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class RecipMeModel {

    private var myKitchen: [String: FoodItem]
    private var myUser : User?
    private var users : [String]
    //var ref:FIRDatabaseReference?
    
    
    // Singleton
    
    static var shared = RecipMeModel()
    
    init(){
        myKitchen = [String: FoodItem]();
        users = []
        loadFromPlist()
    }
    
    func setFireBase(ref: FIRDatabaseReference) {
        //self.ref = ref
    }
    
    func getMyKitchen() -> [String:FoodItem] {
        return myKitchen
    }
    
    func getUsers() -> [String] {
        if(users != nil) {
            return users
        }
        else {
            return [""]
        }
    }
    
    func addUser(email: String) {
        print("add user!")
        users.append(email)
    }
    
    func getMyUser()-> User {
        if(myUser != nil) {
            return myUser!
        }
        else {
            return User()
        }
    }
    
    func setMyUser(newUser: User){
        self.myUser = newUser
    }
 
    func addItem(_ newFood: FoodItem ){
        myKitchen.updateValue(newFood, forKey: newFood.name!);
        save()
    }
    
    func removeItem(_ name: String){
        myKitchen.removeValue(forKey: name);
        save()
    }
    
    func printContents() {
        if(myKitchen.isEmpty){
            print("Your Kitchen is empty! Time to go shopping!")
        }
        else{
            for (key,value) in myKitchen{
                print("\(key) - \(value)");
                print("\n");
            }
        }
    }
    
    //returns a string that is used for putting in the url request to spoonacular API
    func getKitchenIngredients() -> String {
        var ingr = ""
        for f in myKitchen{
            print( "Here: \(f.key.replacingOccurrences(of: " ", with: "-"))")
            ingr += f.key.replacingOccurrences(of: " ", with: "-")
            ingr += ","
        }
        print(ingr)
        return ingr
    }
    
    
    func save(){
        
        var kitchen: [String] = []
        
        // Iterate over every FlashCard and create an NSDictionary, appending the result to local flashcards array
        for var kitchenItem in myKitchen{
            kitchen.append(kitchenItem.key)
        }
        
        (kitchen as NSArray).write(toFile: "/Users/adammoffitt/Documents/USC Fall 2016/ITP 342/kitchenSaved", atomically: true)
        
        (users as NSArray).write(toFile: "/Users/adammoffitt/Documents/USC Fall 2016/ITP 342/usersSaved", atomically: true)
    }
    
    // Load flashcard array from plist by converting NSArray -> [Flashcard]
    func loadFromPlist(){
        
        if let kitchen = NSArray(contentsOfFile: "/Users/adammoffitt/Documents/USC Fall 2016/ITP 342/kitchenSaved"){
            print("/Users/adammoffitt/Documents/USC Fall 2016/ITP 342/kitchenSaved")
            for kitchenItem in kitchen{
                
                var newFood = FoodItem(name: kitchenItem as! String, quantity: 1)
                print(newFood.getName())
                myKitchen.updateValue(newFood, forKey: newFood.name!);         }
        }
        
        if let tempUsers = NSArray(contentsOfFile: "/Users/adammoffitt/Documents/USC Fall 2016/ITP 342/usersSaved"){
            self.users = tempUsers as! [String]
            print("users: \(users)")
    }
    
}
}
