//
//  RecipeViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/5/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var details: UITextView!
    var recipe: NSDictionary! = [:]
    var recipeId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getRecipeId() -> Int {
        return self.recipeId!
    }
    
    func setRecipeId(id:Int) {
        print("setting recipe id to be: \(id)")
        self.recipeId = id
    }
    
    func getRecipe(){
        
        if(self.recipeId != nil){
            print("recipe id: \(getRecipeId())")
            let headers = [
                "X-Mashape-Key": "M2bNOAU8Z0mshqvOlAwaG837fTY4p18UbIUjsnq4yKt9ZT6mx0",
                "Accept": "application/json"
            ]
            let url = NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/\(getRecipeId())/information?includeNutrition=false")
            let request = NSMutableURLRequest(
                url: url! as URL,
                cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: nil,
                delegateQueue: OperationQueue.main
            )
            
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest,
                                                            completionHandler: { (dataOrNil, response, error) in
                                                                if let data = dataOrNil {
                                                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                                                        with: data, options:[]) as? NSDictionary {
                                                                        
                                                                        self.recipe = (responseDictionary as? NSDictionary)!
                                                                        
                                                                        
                                                                        
                                                                        if self.recipe["title"] != nil {
                                                                            if self.name != nil {
                                                                                self.name.text = self.recipe["title"] as? String
                                                                            }
                                                                        }
                                                                        //get image
                                                                        if self.recipe["image"] != nil {
                                                                            if self.image != nil {
                                                                                let imageUrl = URL(string: self.recipe["image"] as! String)
                                                                                let data = try? Data(contentsOf: imageUrl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                                                                                self.image.image = UIImage(data: data!)
                                                                            }
                                                                        }
                                                                        
                                                                        if self.recipe["instructions"] != nil {
                                                                            var textString = ""
                                                                            if(self.recipe["aggregateLikes"] != nil){
                                                                                textString.append("Likes: \((String)(self.recipe["aggregateLikes"] as! Int))\n")
                                                                            }
                                                                            if(self.recipe["cookingMinutes"] != nil){
                                                                                textString.append("Cooking Minutes: \((String)(self.recipe["cookingMinutes"] as! Int))\n")
                                                                            }
                                                                            if(self.recipe["preparationMinutes"] != nil){
                                                                                textString.append("Preparation Minutes: \((String)(self.recipe["preparationMinutes"] as! Int))\n")
                                                                            }
                                                                            if(self.recipe["readyInMinutes"] != nil){
                                                                                textString.append("Ready in \((String)(self.recipe["readyInMinutes"] as! Int)) minutes!\n")
                                                                            }
                                                                            if(self.recipe["readyInMinutes"] != nil){
                                                                                textString.append("\nIngredients:\n")
                                                                                let ingr = self.recipe["extendedIngredients"] as! [NSDictionary]
                                                                                for (index, _) in ingr.enumerated() {
                                                                                    textString.append("\(index+1): \((ingr[index] )["originalString"]!)\n")
                                                                                }
                                                                            }
                                                                            if(self.recipe["instructions"] is NSNull){
                                                                                textString.append("\n\nVisit: \((self.recipe["sourceUrl"])!) for recipe instructions!")
                                                                            }else {
                                                                                textString.append("\nInstructions:\n \(self.recipe["instructions"] as! String))")
                                                                            }
                                                                            
                                                                            if self.details != nil{
                                                                                print("final string is now: \(textString)")
                                                                                self.details.text = textString
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                
            });
            
            task.resume()
        }
        else{
            print("recipe id is null")
        }
    }
    
}
