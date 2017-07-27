//
//  KitchenTableViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/7/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import FirebaseAuth
import DGElasticPullToRefresh
import FoldingCell
import GTProgressBar
import SCLAlertView

/* 
 KitchenTableViewController stores all of the user's kitchen items. From here, users can choose to add new items manually, add by speech, or add by camera. 
 */
class KitchenTableViewController: UITableViewController {
    
    var user: User!
    let sharedRecipMeModel = RecipMeModel.shared
    
    /************************************************/
    //Old kitchen table view code - non folding

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        
        self.navigationItem.leftBarButtonItems = [self.editButtonItem]
        
        //load kitchen first
        sharedRecipMeModel.loadFromFirebase()
        
        user = sharedRecipMeModel.getMyUser()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData() //reload the kitchen table
        //if kitchen is empty, show error message
        /*if(sharedRecipMeModel.getMyKitchen().isEmpty){
            let alert = UIAlertController(title: "Empty Kitchen!",
                                          message: "Looks like your kitchen is empty! Click the Add button on the top right to add items to your kitchen and get recipe suggestions!",
                                          preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Okay",
                                             style: .default)
            
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }*/
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedRecipMeModel.getMyKitchen().count //number of items the user has in the kitchen
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell {
        
        //Create a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "KitchenFoodItemCell", for: indexPath) as! KitchenTableViewCell
        
        // Keep a copy of dictionary key
        let kitchen = self.sharedRecipMeModel.getMyKitchen()
        var Foods = Array(kitchen.keys)
        
        // Sort the foods array. Right now sorting by string, but could sort by other criteria if wanted
        Foods = Foods.sorted(by: { (s1: String, s2: String) -> Bool in
            return s1 < s2
        })
        
        
        let foodItem = kitchen[Foods[indexPath.row]]! as FoodItem
        
        cell.foodName.text = foodItem.getName()
        
        cell.foodQuantity.text = "\(String(describing: foodItem.quantity!)) \(String(describing: foodItem.unitOfMeasurement!))"

        
        //get dates till expires
        let date = Date()
        //let userCalendar = Calendar.current
        
        if(foodItem.expirationDate == nil){
           
            let num = CGFloat(arc4random_uniform(100))/100.0
            cell.expandedFreshBar.progress = num
            cell.expandedFreshBar.barFillColor = UIColor.green
            //cell.expandedFreshBar.barFillColor = UIColor.init(colorLiteralRed: Float(255 * cell.expandedFreshBar.progress), green: Float(255 * (1-cell.expandedFreshBar.progress)), blue: 0, alpha: 1)
        }
        else{
            
            let daysLeft = date.interval(ofComponent: .day, fromDate: Date(), toDate: foodItem.expirationDate!)
            
            var freshColor = UIColor.green
            if(foodItem.addedDate != nil && foodItem.expirationDate != nil) {
                let totalDays = date.interval(ofComponent: .day, fromDate: foodItem.addedDate!, toDate: foodItem.expirationDate!)
                let percentLeft = Double(daysLeft) / Double(totalDays)
                cell.expandedFreshBar.progress = CGFloat(percentLeft)
                freshColor = UIColor(red: CGFloat(2.0 * (1 - percentLeft)), green: CGFloat(2.0 * percentLeft), blue: CGFloat(0), alpha: CGFloat(1.0));
                cell.expandedFreshBar.barFillColor = freshColor
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                cell.addedOnDate.text = dateFormatter.string(from: foodItem.addedDate!)
                cell.expirationDate.text = dateFormatter.string(from: foodItem.expirationDate!)
            }
            else {
                let num = CGFloat(arc4random_uniform(100))/100.0
                cell.expandedFreshBar.progress = num
                freshColor = UIColor(red: CGFloat(2.0 * (1 - num)), green: CGFloat(2.0 * num), blue: CGFloat(0), alpha: CGFloat(1.0));
                cell.expandedFreshBar.barFillColor = freshColor
                cell.addedOnDate.text = String(describing: Date())
                cell.expirationDate.text = "soon..."
            }
        }

        //Return the cell
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let foodCell = tableView.cellForRow(at: indexPath) as! KitchenTableViewCell
            // Delete the row from the data source
            
            sharedRecipMeModel.removeItem(foodCell.foodName.text!)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // TO-DO: Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }
    
    // the cells we would like the actions to appear in need to be editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    //TO-DO: Add actions to table view selected cells: swipe to remove, add more quantity of that food item, or add to shopping cart.
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = tableView.cellForRow(at: indexPath) as! KitchenTableViewCell
        
        let remove = UITableViewRowAction(style: .destructive, title: "Remove") { action, index in
            let alertView = SCLAlertView()
            alertView.addButton("Remove") {
                let foodCell = tableView.cellForRow(at: indexPath) as! KitchenTableViewCell
                // Delete the row from the data source
                self.sharedRecipMeModel.removeItem(foodCell.foodName.text!)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            alertView.showWarning("Remove \(cell.foodName.text!)?", subTitle: "")
        }
        remove.backgroundColor = UIColor.red
        
        let addMore = UITableViewRowAction(style: .normal, title: "Change\nQuantity") { action, index in
            let alertView = SCLAlertView()
            let stepper = UIStepper()
            alertView.customSubview = stepper
            alertView.showEdit("Change Quantity of\n\(String(describing: cell.foodItem.name!))", subTitle: "")
        }
        addMore.backgroundColor = UIColor.orange
        
        let addToShoppingCart = UITableViewRowAction(style: .normal, title: "Shopping\nCart") { action, index in
            SCLAlertView().showSuccess("\(String(describing: cell.foodItem.name!)) Added to shopping cart!", subTitle: "")
        }
        addToShoppingCart.backgroundColor = UIColor.blue
        
        return [addToShoppingCart, addMore, remove]
    }
 
     /************************************************/
 

     /************************************************/
    //FOLDING TABLE VIEW CELL CODE
    /*
    
    let kCloseCellHeight: CGFloat = 100
    let kOpenCellHeight: CGFloat = 300
    var kRowsCount = 0
    //number of items the user has in the kitchen
    
    var cellHeights = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.leftBarButtonItems = [self.editButtonItem]
        
        //load kitchen first
        sharedRecipMeModel.loadFromFirebase()

        
        print("# in kitchen \(kRowsCount)")
        
        user = sharedRecipMeModel.getMyUser()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sharedRecipMeModel.loadFromFirebase()
        self.tableView.reloadData() //reload the kitchen table
        //if kitchen is empty, show error message
        /*if(sharedRecipMeModel.getMyKitchen().isEmpty){
         let alert = UIAlertController(title: "Empty Kitchen!",
         message: "Looks like your kitchen is empty! Click the Add button on the top right to add items to your kitchen and get recipe suggestions!",
         preferredStyle: .alert)
         
         let cancelAction = UIAlertAction(title: "Okay",
         style: .default)
         
         alert.addAction(cancelAction)
         
         present(alert, animated: true, completion: nil)
         }*/
    }
    
    // MARK: configure
    func createCellHeightsArray() {
        kRowsCount = sharedRecipMeModel.getMyKitchen().count
        print("# in kitchen1 \(kRowsCount)")
        for _ in 0...kRowsCount { //***
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("user has \(sharedRecipMeModel.getMyKitchen().count) items in the kitchen")
        createCellHeightsArray()
        return sharedRecipMeModel.getMyKitchen().count //number of items the user has in the kitchen
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard case let cell as KitchenFoldingCell = cell else {
            return
        }
        
        cell.backgroundColor = UIColor.clear
        
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //create a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "KitchenFoldingCell", for: indexPath) as! KitchenFoldingCell
        
        // Keep a copy of dictionary key
        let kitchen = self.sharedRecipMeModel.getMyKitchen()
        var Foods = Array(kitchen.keys)
        
        // Sort the foods array. Right now sorting by string, but could sort by other criteria if wanted
        Foods = Foods.sorted(by: { (s1: String, s2: String) -> Bool in
            return s1 < s2
        })
        
        
        let foodItem = kitchen[Foods[indexPath.row]]! as FoodItem
        cell.foodItem = foodItem
        
        cell.foodName.text = foodItem.getName()
        cell.expandedFoodName.text = foodItem.getName()
        
        let fName = foodItem.getName().replacingOccurrences(of: " ", with: "-")
        
        let url = URL(string:
            "https://spoonacular.com/cdn/ingredients_100x100/\(fName.lowercased()).jpg" )
        
        if(url == nil){}
        else{
            if let data = try? Data(contentsOf: url!) {
                cell.foodImageView.image = UIImage(data: data)
            }
        }
        
        cell.foodQuantity.text = String(describing: foodItem.quantity!) as String + " " + foodItem.unitOfMeasurement!
        cell.expandedFoodQuantity.text = String(describing: foodItem.quantity!) as String + " " + foodItem.unitOfMeasurement!
        
        //get dates till expires
        let date = Date()
        //let userCalendar = Calendar.current
        
        if(foodItem.expirationDate == nil){
            cell.daysLeftLabel.text = "\(String(arc4random_uniform(12))) days left"
            let num = CGFloat(arc4random_uniform(100))/100.0
            cell.expandedFreshBar.progress = num
            cell.expandedFreshBar.barFillColor = UIColor.green
            //cell.expandedFreshBar.barFillColor = UIColor.init(colorLiteralRed: Float(255 * cell.expandedFreshBar.progress), green: Float(255 * (1-cell.expandedFreshBar.progress)), blue: 0, alpha: 1)
        }
        else{
            
            let daysLeft = date.interval(ofComponent: .day, fromDate: Date(), toDate: foodItem.expirationDate!)
            
            print("daysLeft: \(daysLeft)")
            
            var freshColor = UIColor.green
            cell.daysLeftLabel.text = String(daysLeft) + " days left"
            if(foodItem.addedDate != nil && foodItem.expirationDate != nil) {
                let totalDays = date.interval(ofComponent: .day, fromDate: foodItem.addedDate!, toDate: foodItem.expirationDate!)
                let percentLeft = Double(daysLeft) / Double(totalDays)
                print("FRESH BAR: \(percentLeft)")
                cell.expandedFreshBar.progress = CGFloat(percentLeft)
                freshColor = UIColor(red: CGFloat(2.0 * (1 - percentLeft)), green: CGFloat(2.0 * percentLeft), blue: CGFloat(0), alpha: CGFloat(1.0));
                cell.expandedFreshBar.barFillColor = freshColor
                cell.freshColor = freshColor.cgColor
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy" //Your date format

                cell.addedOnDate.text = dateFormatter.string(from: foodItem.addedDate!)
                cell.expirationDate.text = dateFormatter.string(from: foodItem.expirationDate!)
            }
            else {
                let num = CGFloat(arc4random_uniform(100))/100.0
                print("FRESH BAR: \(num)")
                cell.expandedFreshBar.progress = num
                freshColor = UIColor(red: CGFloat(2.0 * (1 - num)), green: CGFloat(2.0 * num), blue: CGFloat(0), alpha: CGFloat(1.0));
                cell.expandedFreshBar.barFillColor = freshColor
                cell.freshColor = freshColor.cgColor
                cell.addedOnDate.text = String(describing: Date())
                cell.expirationDate.text = "soon..."
            }
            cell.shapeLayer.fillColor = freshColor.cgColor
            cell.freshnessIndicatorCircle.reloadInputViews()
        }
        
        //nutritional facts
        
        //Return the cell
        return cell

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    // MARK: Table vie delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight { // open cell
            cellHeights[(indexPath as NSIndexPath).row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[(indexPath as NSIndexPath).row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let foodCell = tableView.cellForRow(at: indexPath) as! KitchenFoldingCell
            // Delete the row from the data source
            
            sharedRecipMeModel.removeItem(foodCell.foodName.text!)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    // the cells we would like the actions to appear in need to be editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
*/*/
     /************************************************/
}

extension Date {
    
    func interval(ofComponent comp: Calendar.Component, fromDate date1: Date, toDate date2: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date1) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: date2) else { return 0 }
        return end - start
    }
}


