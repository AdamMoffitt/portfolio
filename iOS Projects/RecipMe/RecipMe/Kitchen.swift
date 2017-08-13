//
//  Kitchen.swift
//  RecipMe
//
//  Created by Adam Moffitt on 8/11/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import Foundation

/*Kitchen class stores the food items that the user owns. Includes addItem function, removeItem function,
* printContents function,
*/


/**
 * @author Adam Moffitt
 *
 */
open class Kitchen {
    
    var myKitchen: [String: FoodItem]; // dictionary
    
    init(){
        myKitchen = [String: FoodItem]();
        print ("Kitchen")
    }

    func add(){
        print ("Add");
    }
    
    func addItem(_ newFood: FoodItem ){
        myKitchen.updateValue(newFood, forKey: newFood.name!);
    }
    
    func removeItem(_ name: String){
        myKitchen.removeValue(forKey: name);
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
}
