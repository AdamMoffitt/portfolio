//
//  PlanMealsViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 10/29/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ShoppingListTableViewController: UITableViewController {

    
    // MARK: Constants
    let listToUsers = "ListToUsers"
    
    // MARK: Properties
    
    var items: [GroceryItem] = []
    let ref = FIRDatabase.database().reference(withPath: "shoppingList-items")
    
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        let today = NSDate()
        print (today)
        items = [
                GroceryItem(n: "Starbursts", q: 1000, addedD: today, completed: false),
                GroceryItem(n: "Moose Tracks Ice Cream", q: 5, addedD: today, completed: false)
        ]
        print("!!!!!!!!!!!! \(items.count) \(items)")
        tableView.allowsMultipleSelectionDuringEditing = false
        
        
        //WHY DOES THIS NOT WORK???
//        let navigationBar = navigationController!.navigationBar
//        let rightBarButton = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ShoppingListTableViewController.myRightSideBarButtonItemTapped(_:)))
//        self.navigationItem.rightBarButtonItem = rightBarButton
        
//        ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
//            var newItems: [GroceryItem] = []
//            
//            for item in snapshot.children {
//                let groceryItem = GroceryItem(snapshot: item as! FIRDataSnapshot)
//                newItems.append(groceryItem)
//            }
//            
//            self.items = newItems
//            self.tableView.reloadData()
//        })
        
//        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
//            guard let user = user else { return }
//            self.user = User(userID: user.uid, email: user.email!)
//        }
    }
    
    // MARK: UITableView Delegate methods
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // default is one
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let groceryItem = items[indexPath.row]
        
        cell.textLabel?.text = groceryItem.getName()
        cell.textLabel?.text
        cell.textLabel?.textColor = UIColor.red
        let dateFormatter = DateFormatter()
        let date = dateFormatter.string(from: groceryItem.getAddedDate() as Date)
        let today = NSDate()
        print(dateFormatter.string(from: today as Date))
        
        cell.detailTextLabel?.text = dateFormatter.string(from: today as Date)
        
        toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
        
        return cell
    }
    
    override
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let food = tableView.cellForRow(at: indexPath)
            // Delete the row from the data source
            
            items.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let groceryItem = items[indexPath.row]
        let toggledCompletion = !groceryItem.completed
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
//        groceryItem.ref?.updateChildValues([
//            "completed": toggledCompletion
//            ])
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.red
            cell.detailTextLabel?.textColor = UIColor.red
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        }
    }
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Grocery Item",
                                      message: "Add an Item",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { _ in
                                        // 1
                                        guard let textField = alert.textFields?.first,
                                            let text = textField.text else { return }
                                        
                                        // 2
                                        let groceryItem = GroceryItem(n: text,
                                                                      q: 1,
                                                                      addedD: NSDate(),
                                                                      completed: false)
                                        // 3
                                        self.items.append(groceryItem)
                                        self.tableView.reloadData()
        }
        self.tableView.reloadData()
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    

   

    
}
