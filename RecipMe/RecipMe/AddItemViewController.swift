//
//  AddItemViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 8/13/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let sharedRecipMeModel = RecipMeModel.shared
    
    @IBOutlet weak var measurementPickerView: UIPickerView!
    
    @IBOutlet var itemName: UITextField!
    
    @IBOutlet var itemQuantity: UITextField!
    
    @IBOutlet var foodImage: UIImageView!
    
    @IBAction func addItem(_ sender: AnyObject) {
        print("add item")
        if !(itemName.text?.isEmpty)! && !(itemQuantity.text?.isEmpty)! {
            //let image = getItemImage(name: itemName.text!)
            let newFood = FoodItem(name: (itemName.text!.capitalized), quantity: Int(itemQuantity.text!)!, unit: unitsOfMeasurement[measurementPickerView.selectedRow(inComponent: 0)])
            sharedRecipMeModel.addItem(newFood)
            print("added: \(itemName.text!) \(itemQuantity.text!)")
             self.navigationController?.popViewController(animated: true)
        }
        else {
            print("name and quantity not filled in")
        }
        
    }
    
    var unitsOfMeasurement = ["Units", "Cups", "Ounces", "Pounds", "Grams"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemName.becomeFirstResponder()
        
        measurementPickerView.dataSource = self
        measurementPickerView.delegate = self
        
    }
    
    
//    func getItemImage(name: String){
//        
//        let headers = [
//            "X-Mashape-Key": "M2bNOAU8Z0mshqvOlAwaG837fTY4p18UbIUjsnq4yKt9ZT6mx0",
//            "Accept": "application/json",
//    "Content-Type: ": "application/x-www-form-urlencoded"
//        ]
//        let url = NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/visualizeIngredients?defaultCss=YES&ingredientList=3 oz flour&measure=metric&servings=1&showBacklink=YES&view=grid")
//        let request = NSMutableURLRequest(
//            url: url! as URL,
//            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
//            timeoutInterval: 10)
//        request.httpMethod = "POST"
//        request.allHTTPHeaderFields = headers
//        
//        let session = URLSession(
//            configuration: URLSessionConfiguration.default,
//            delegate: nil,
//            delegateQueue: OperationQueue.main
//        )
//        
//        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest,
//                                                        completionHandler: { (dataOrNil, response, error) in
//                                                            if let data = dataOrNil {
//                                                                if let responseDictionary = try! JSONSerialization.jsonObject(
//                                                                    with: data, options:[]) as? NSDictionary {
//                                                                    
//                                                                    self.results = (responseDictionary["results"] as?[NSDictionary])!                          }
//                                                                print(self.results)
//                                                                self.tableView.reloadData()
//                                                            }
//                                                            
//        });
//        
//        task.resume()

   // }

    @IBAction func dismissKeyboardButton(_ sender: AnyObject) {
        if(itemName.isFirstResponder){
            itemName.resignFirstResponder()
        }
        else if (itemQuantity.isFirstResponder){
            itemQuantity.resignFirstResponder()
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
    
    //set font color to be white
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = unitsOfMeasurement[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(unitsOfMeasurement[row])
    }

    
    
}
