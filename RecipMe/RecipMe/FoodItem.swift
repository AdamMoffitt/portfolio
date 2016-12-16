//
//  Food.swift
//  RecipMe
//
//  Created by Adam Moffitt on 10/24/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit

class FoodItem: NSObject {

    var image : String?
    var name : String?
    var quantity : Int?
    var addedDate : NSDate?
    var expirationDate : NSDate?
    var unitOfMeasurement : String?
    var id : Double?
    var unitPrice: Double = 0.00;
    
    func getName () -> String {
        return self.name!
    }
    func set(Image: String) {
        image = Image
    }
    
    func set(Name: String){
        name = Name
    }
    
    func set(quantity : Int){
        self.quantity = quantity
    }
    
    func getQuantity() -> Int {
        return quantity!
    }
    
    func increase(Quantity: Int) {
        quantity! += Quantity
    }
    
    func set(addedDate : NSDate){
        self.addedDate = addedDate
    }
    
    func getaddedDate() -> NSDate {
        return addedDate!
    }
    
    
    
    /*
     * Base Constructor
     */
    override init(){
        super.init()
        self.name = ""
        self.quantity = 1;
        self.unitPrice = 0;
    }
    
    /*
     * Constructor 1
     */
    convenience init (name: String) {
        self.init()
        self.name = name
    }
    
    /*
     * Constructor 2
     */
    convenience init(name: String, quantity: Int){
        self.init(name: name)
        self.quantity = quantity
    }
    
    /*
     * Constructor 2
     */
    convenience init(name: String, quantity: Int, unit: String){
        self.init(name: name)
        self.quantity = quantity
        self.unitOfMeasurement = unit
    }
    
    /*
    * Constuctor 3
    */
   convenience init(name: String, image: String){
        self.init(name: name);
        self.image = image
    }
    
    /*
     * Constructor 4
     */
    convenience init (name: String, quantity: Int,  unitSize: String, unitPrice: Double, priority: Int) {

        self.init()
        self.name = name;
        self.quantity = quantity;
        self.unitPrice = unitPrice;
    }
    
    /*
     * Constructor 5
     */
    convenience init (name: String, quantity: Int,  addedDate: NSDate) {
        self.init()
        self.name = name;
        self.quantity = quantity;
        self.addedDate = addedDate
    }
    
    //@Override
    func toString() -> String {
        var stringA = "\n \tName: " + name!;
        stringA += " days \n \t Quantity: " + String(describing: quantity);
        stringA += "\n \t Price= $" + String(unitPrice);
        return stringA;
    }

}
