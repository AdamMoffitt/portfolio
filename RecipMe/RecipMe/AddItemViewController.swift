//
//  AddItemViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 8/13/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AddItemViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    let sharedRecipMeModel = RecipMeModel.shared
    var unitsOfMeasurement = ["Units", "Gallons" , "Cans", "Boxes" , "Cups", "Ounces", "Pounds", "Grams"]
    
    @IBOutlet weak var measurementPickerView: UIPickerView!
    
    @IBOutlet var itemName: UITextField!
    
    @IBOutlet var itemQuantity: UITextField!
    
    @IBOutlet var foodImage: UIImageView!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemName.becomeFirstResponder()
        
        measurementPickerView.dataSource = self
        measurementPickerView.delegate = self
        itemName.delegate = self
    }
    
    @IBAction func addItem(_ sender: AnyObject) {
        ref = Database.database().reference()
        
        //if all needed input is given, add item to kitchen by calling sharedRecipMeModel.addItem function
        if !(itemName.text?.isEmpty)! && !(itemQuantity.text?.isEmpty)! {
            //check that there are no numbers in the item name
            if Int(itemName.text!) != nil {
                self.error(error: "Please enter a valid name")
            }
            if Int(itemQuantity.text!) == nil {
                self.error(error: "Please enter a valid quantity")
            }
            else {
                let name = itemName.text!.capitalized
                let number = Int(itemQuantity.text!)!
                let unit = unitsOfMeasurement[measurementPickerView.selectedRow(inComponent: 0)]
                let todaysDate = Date()
                var dateComponent = DateComponents()
                dateComponent.day = Int(arc4random_uniform(UInt32(24))) //ADD AS MANY DAYS AS TYPICAL FOOD PRODUCT LASTS
                let expirationDate = Calendar.current.date(byAdding: dateComponent, to: Date())
                
                //let image = getItemImage(name: itemName.text!)
                let newFood = FoodItem(name: name, quantity: number, unit: unit, addedDate: todaysDate, expirationDate: expirationDate!)
                sharedRecipMeModel.addItem(newFood)
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            error(error: "Please enter a name and a quantity")
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        itemName.resignFirstResponder()
        self.view.endEditing(true)
        let url = URL(string:
            "https://spoonacular.com/cdn/ingredients_100x100/\((itemName.text?.replacingOccurrences(of: " ", with: "-"))!).jpg" )
        
        if(url == nil){}
        else{
            if let data = try? Data(contentsOf: url!) {
                foodImage.image = UIImage(data: data)
                foodImage.contentMode = UIViewContentMode.scaleAspectFill
            }
        }
        return false
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        //TODO
    }
    
    
    @IBAction func dismissKeyboardButton(_ sender: AnyObject) {
        if(itemName.isFirstResponder){
            itemName.resignFirstResponder()
        }
        else if (itemQuantity.isFirstResponder){
            itemQuantity.resignFirstResponder()
        }
        let url = URL(string:
            "https://spoonacular.com/cdn/ingredients_100x100/\((itemName.text?.replacingOccurrences(of: " ", with: "-"))!).jpg" )
        
        if(url == nil){}
        else{
            if let data = try? Data(contentsOf: url!) {
                foodImage.image = UIImage(data: data)
                foodImage.contentMode = UIViewContentMode.scaleAspectFill
            }
        }
    }
    
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return unitsOfMeasurement.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return unitsOfMeasurement[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, forComponent component: Int) -> String? {
        let temp = itemQuantity.text
        itemQuantity.text = temp?.appending(unitsOfMeasurement[row])
        return unitsOfMeasurement[row]
        
    }
    
    //set font color to be white
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = unitsOfMeasurement[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    
    func error(error: String){
        let alert = UIAlertController(title: "Error",
                                      message: error,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Okay",
                                         style: .default)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
}
