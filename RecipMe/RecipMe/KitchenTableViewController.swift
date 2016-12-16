//
//  KitchenTableViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/7/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import FirebaseAuth

class KitchenTableViewController: UITableViewController {
    
      var user: User!
    let sharedRecipMeModel = RecipMeModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        user = sharedRecipMeModel.getMyUser()
        
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(userID: user.uid, email: user.email!)
            self.sharedRecipMeModel.setMyUser(newUser: self.user)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for f in sharedRecipMeModel.getMyKitchen(){
            print("*\(f.key)")
        }
        self.tableView.reloadData()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // default is one
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedRecipMeModel.getMyKitchen().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell {
        
        //Create a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "KitchenFoodItemCell", for: indexPath) as! KitchenTableViewCell
        
        //Runtime for this is awful, bad coding practice but need way to repopulate kitchen and right now kitchen is a dictionary.cant get value at.
        //            for f in sharedRecipMeModel.getMyKitchen(){
        //                Foods.append(f.value)
        //            }
        
        // Keep a copy of dictionary key
        let kitchen = self.sharedRecipMeModel.getMyKitchen()
       var Foods = Array(kitchen.keys)
        // You may want to sort it
        Foods.sorted(by: { (s1: String, s2: String) -> Bool in
            return s1 < s2
            })
        
        
        let foodItem = kitchen[Foods[indexPath.row]]! as FoodItem
        
        cell.foodName.text = foodItem.getName()
        
        let fName = foodItem.getName().replacingOccurrences(of: " ", with: "-")
        print("^^^^\(fName.lowercased())^^^^")
        
        let url = URL(string:
            "https://spoonacular.com/cdn/ingredients_100x100/\(fName.lowercased()).jpg" )
        
        if(url == nil){}
        else{
            if let data = try? Data(contentsOf: url!) {//make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                cell.foodImage.image = UIImage(data: data)
            }
        }
        //
        //            if(foodItem.image != nil){
        //                cell.foodImage.image = UIImage(named: foodItem.image!)
        //            }
        
        cell.foodQuantity.text = String(describing: foodItem.quantity!) as String
        
        //Modify the Cell
        
        
        //Return the cell
        return cell
        
    }

    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        
//        let remove = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
//            print("Remove button tapped")
//            let cell = tableView(<#T##tableView: UITableView##UITableView#>, cellForRowAt: <#T##IndexPath#>)
//            
//            let cell = tableView(tableView, cellForRowAt: indexPath)
//            cell.
//            sharedRecipMeModel.removeItem()
//            
//        }
//        remove.backgroundColor = UIColor.red
//        
////        let addMore = UITableViewRowAction(style: .normal, title: "Add More") { action, index in
////            print("Add more button tapped")
////        }
////        addMore.backgroundColor = UIColor.orange
////        
////        let addToShoppingCart = UITableViewRowAction(style: .normal, title: "Add to shopping cart") { action, index in
////            print("Add to shopping cart button tapped")
////        }
////        addToShoppingCart.backgroundColor = UIColor.blue
//        
//        //return [addToShoppingCart, addMore, remove]
//        
//        return [remove]
//    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let food = tableView.cellForRow(at: indexPath) as! KitchenTableViewCell
            // Delete the row from the data source
            
            sharedRecipMeModel.removeItem(food.foodName.text!)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
}




