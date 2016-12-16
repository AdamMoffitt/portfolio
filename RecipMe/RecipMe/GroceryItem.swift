//
//  Food.swift
//  RecipMe
//
//  Created by Adam Moffitt on 10/24/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GroceryItem: FoodItem {

    var completed: Bool
    var ref: FIRDatabaseReference?
    
    override init(){
        self.completed = false
        self.ref = nil
        super.init()
    }
    
    init(n: String, q: Int, addedD: NSDate, completed: Bool) {
        self.completed = completed
        self.ref = nil
        super.init()
        super.set(Name: n)
        super.set(quantity: q)
        super.set(addedDate: addedD)
    }
    
    
    convenience init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.init()
        super.set(Name: (snapshotValue["name"] as? String)!)
        super.set(addedDate: (snapshotValue["addedDate"] as? NSDate)!)
        self.completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "Added on": addedDate,
            "completed": completed
        ]
    }

    override func getName () -> String {
        return super.name!
    }
    
    override func set(Name: String){
        super.name = Name
    }
    
    override func set(quantity : Int){
        super.quantity = quantity
    }
    
    override func getQuantity() -> Int {
        return super.quantity!
    }
    
    override func increase(Quantity: Int) {
        super.quantity! += Quantity
    }
    func getAddedDate() ->NSDate {
        return super.addedDate!
    }
    func setAddedDate(date: NSDate) {
        super.addedDate = date
    }
    
}
