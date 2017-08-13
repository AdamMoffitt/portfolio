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

/*
 TODO: There is a lot more functionality that we can add in here, right now it is just a very basic table view that serves as a shopping list. This should be saved to firebase as one of the user's properties, and more integrated with other parts of the app.
 */
class ShoppingListTableViewController: UITableViewController {

    let listToUsers = "ListToUsers"
    var items: [FoodItem] = []
    let ref = Database.database().reference(withPath: "shoppingList-items")
    
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        let today = NSDate()
        items = []
        tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    // UITableView Delegate methods
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
        cell.textLabel?.textColor = UIColor.red
        let dateFormatter = DateFormatter()
        //let date = dateFormatter.string(from: groceryItem.getaddedDate() as Date)
        let today = NSDate()
        
        cell.detailTextLabel?.text = dateFormatter.string(from: today as Date)
        
        //toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
        
        return cell
    }
    
    override
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            items.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //guard let cell = tableView.cellForRow(at: indexPath) else { return }
        //let groceryItem = items[indexPath.row]
        //let toggledCompletion = !groceryItem.completed
       // toggleCellCheckbox(cell, isCompleted: toggledCompletion)
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
                                        let groceryItem = FoodItem()
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
