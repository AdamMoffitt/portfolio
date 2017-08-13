//
//  ManualAddViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 4/16/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit
import SCLAlertView

class ManualAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var addItemsTableView: UITableView!
    
    @IBOutlet var unitsOfMeasurementPickerView: UIPickerView!
    
    @IBOutlet var foodNameTextField: UITextField!
    
    let sharedRecipMeModel = RecipMeModel.shared
    var itemsToAdd : [[String : String]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodNameTextField.becomeFirstResponder()
        
        unitsOfMeasurementPickerView.dataSource = self
        unitsOfMeasurementPickerView.delegate = self
        foodNameTextField.delegate = self
        addItemsTableView.delegate = self
        addItemsTableView.dataSource = self
       

        addItemsTableView.rowHeight = UITableViewAutomaticDimension
        addItemsTableView.estimatedRowHeight = 100
//        
        //resizeTableView()
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let name = foodNameTextField.text!
        let quantity = unitsOfMeasurementPickerView.selectedRow(inComponent: 0) + 1
        let unit = sharedRecipMeModel.unitsOfMeasurement[unitsOfMeasurementPickerView.selectedRow(inComponent: 1)]
        itemsToAdd.append([name: String(quantity) + " " + unit])
        addItemsTableView.reloadData()
        
        //move tableview down to last added item
        let numberOfSections = self.addItemsTableView.numberOfSections
        let numberOfRows = self.addItemsTableView.numberOfRows(inSection: numberOfSections-1)
        let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
        addItemsTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
    
        //clear text field
        foodNameTextField.text = ""
        
        //resizeTableView()
    }

    @IBAction func finishButtonPressed(_ sender: Any) {
        //show alert to confirm adding items
        // Get started
        var subtitle = "Add the following items to your kitchen?\n"
        for item in itemsToAdd {
            let name = [String](item.keys)
            let quantity = [String](item.values)
            let temp = quantity[0] + " of " + name[0]
            subtitle.append("\(temp)\n")
        }
        
        let alertView = SCLAlertView()
       
        alertView.addButton("Add Items"){
            for element in self.itemsToAdd {
                let names = [String](element.keys)
                let name = names[0]
                let quantities = [String](element.values)
                let quantity = quantities[0]
                
                //break quantity into number and unit of measurement
                let strArr = quantity.components(separatedBy: " ")
                var number = 0
                var unit = "units"
                for item in strArr {
                    if let intVal = Int(item){
                        number = intVal
                    }
                    else {
                        unit = item
                    }
                    let todaysDate = Date()
                    var dateComponent = DateComponents()
                    dateComponent.day = Int(arc4random_uniform(UInt32(24))) //ADD AS MANY DAYS AS TYPICAL FOOD PRODUCT LASTS
                    let expirationDate = Calendar.current.date(byAdding: dateComponent, to: Date())
                    
                    //let image = getItemImage(name: itemName.text!)
                    let newFood = FoodItem(name: (name.capitalized), quantity: number, unit: unit, addedDate: todaysDate, expirationDate: expirationDate!)
                    self.sharedRecipMeModel.addItem(newFood)
                }
            }
        }
        alertView.showInfo("Confirm Add", subTitle: subtitle, closeButtonTitle: "Cancel", circleIconImage: UIImage(named: "RecipMeIcon"))
    }
    
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if ( component == 0) {
            return 20
        }
        else if( component == 1) {
            return sharedRecipMeModel.unitsOfMeasurement.count
        }
        return 10
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if( component == 0) {
            return String(row+1)
        } else if ( component == 1) {
            return sharedRecipMeModel.unitsOfMeasurement[row]
        }
        return "units"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return itemsToAdd.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addedItemsCell") as! AddedItemsTableViewCell
        if(itemsToAdd.count > 0){
            let item = itemsToAdd[indexPath.row]
            let names = [String](item.keys)
            let quantities = [String](item.values)
            cell.foodNameLabel.text = names[0]
            cell.foodQuantityLabel.text = quantities[0]
        }
        return cell
    }
    
    func resizeTableView() {
        var height = self.addItemsTableView.rowHeight
        height *= CGFloat(itemsToAdd.count)
        
        var tableFrame = self.addItemsTableView.frame
        tableFrame.size.height = height
        self.addItemsTableView.frame = tableFrame
        self.addItemsTableView.setNeedsDisplay()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

