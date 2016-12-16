//
//  testKitchen.swift
//  RecipMe
//
//  Created by Adam Moffitt on 8/12/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import Foundation

open class testKitchen {
    
    let sharedRecipMeModel = RecipMeModel.shared
    
    init(){
        
    }
    

    func add(){
        
        let tomato = FoodItem(name: "tomato", quantity: 10);
        let doritoes = FoodItem(name: "Doritoes - Sour Cream and Onion", quantity: 50, unitSize: "Ounces", unitPrice: 1.50, priority: 5);
        let Guacamole = FoodItem(name: "Guacamole", quantity: 5, unitSize: "Pounds", unitPrice: 5.99, priority: 1);
    
        sharedRecipMeModel.addItem(tomato);
        sharedRecipMeModel.addItem(Guacamole);
        sharedRecipMeModel.addItem(doritoes);
    }
    
    func remove(){
        
    }
    
    func print(){
    
    }
}
