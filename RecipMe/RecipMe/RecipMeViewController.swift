//
//  RecipMeViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 10/29/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import Foundation

class RecipMeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UINavigationControllerDelegate {

    let sharedRecipMeModel = RecipMeModel.shared
    var kitchen : [String: FoodItem]?
    var results: [NSDictionary] = []
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //info from plist!!!!
        
        
        print("recipmeViewController!!!!!!!")
        kitchen = sharedRecipMeModel.getMyKitchen()

        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(RecipMeViewController.refreshControlAction), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        searchData()
        
        
        
        
    }
    
    func viewWillAppear() {
        print("recipmeViewController view will appear!!!!!!!")
        searchData()
    }
    
    func viewDidAppear() {
        print("recipmeViewController view did appear!!!!!!!")
        searchData()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.viewWillAppear(true)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        viewController.viewDidAppear(true)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        print("refresh")
        searchData()
    }
    
    func searchData(){
        //get current ingredients in kitchen
        let ingredients = sharedRecipMeModel.getKitchenIngredients()
        print("ingredients: " + ingredients)
        
        let headers = [
            "X-Mashape-Key": "M2bNOAU8Z0mshqvOlAwaG837fTY4p18UbIUjsnq4yKt9ZT6mx0",
            "Accept": "application/json"
        ]
        let url = NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/searchComplex?addRecipeInformation=false&fillIngredients=true&includeIngredients=\(ingredients)&limitLicense=false&number=30&offset=0&ranking=2")
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
                                                                    
                                                                    self.results = (responseDictionary["results"] as?[NSDictionary])!                          }
                                                               //print(self.results)
                                                                //self.sortResults()
                                                                self.sort()
                                                                print("-------------------------------------------------------------------------------------------")
                                                                print("-------------------------------------------------------------------------------------------")
                                                                print("-------------------------------------------------------------------------------------------")
                                                                print("-------------------------------------------------------------------------------------------")
                                                                print("-------------------------------------------------------------------------------------------")
                                                                print("-------------------------------------------------------------------------------------------")
                                                                print("-------------------------------------------------------------------------------------------")
                                                                print("-------------------------------------------------------------------------------------------")
                                                                print("-------------------------------------------------------------------------------------------")
                                                                
                                                                //print(self.results)
                                                                self.tableView.reloadData()
                                                            }
                                                            self.tableView.reloadData()
        });
        
        task.resume()
    }
    
    
    func sort(){
        print ("let's sort this business!")
        let tempR = self.results
        self.results = tempR.sorted(by: { //sort by fewest missed ingredients
            return ($0["missedIngredientCount"] as? Int)! < ($1["missedIngredientCount"] as? Int)!
        })
    }
    
    func sortResults() {
        print ("let's sort this business!")
        let tempR = self.results
        self.results = tempR.sorted(by: { //sort by how many ingredients used first, then by how many likes
            if ($0["missedIngredientCount"] as? Int)! != ($1["missedIngredientCount"] as? Int)! {
                return ($0["missedIngredientCount"] as? Int)! < ($1["missedIngredientCount"] as? Int)!
            }
            else if ($0["usedIngredientCount"] as? Int)! != ($1["usedIngredientCount"] as? Int)! {
                return ($0["usedIngredientCount"] as? Int)! > ($1["usedIngredientCount"] as? Int)!
            }
            else {
                return ($0["likes"] as? Int)! > ($1["likes"] as? Int)!
            }
            })
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Create a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Recipe Cell", for: indexPath) as! RecipMeTableViewCell

        
        if (results.isEmpty){
            print("no recipes")
        }
        else{
            let count = indexPath.row
            let recipe = self.results[count] as NSDictionary
            cell.recipeName.text = recipe["title"]! as? String
            
            //Get Missed recipe count
            let missed = recipe["missedIngredients"]! as! [NSDictionary]
            let used = recipe["usedIngredientCount"]! as! Int
            
            if(missed.count == 0){
                cell.ownedIngredients.text = "You have all the ingredients to make this recipe!"
            }
            else{
                cell.ownedIngredients.text = "You only need \(missed.count) more ingredients to make this recipe!"
            }
            
           //get image
            let url = URL(string: recipe["image"]! as! String)
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            cell.recipeImage.image = UIImage(data: data!)
            
            cell.setRecipeId(id: recipe["id"] as! Int)
        }
        
        //Return the cell
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(results.count < 1){
            return 0
        }
        else {
            return results.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell selected, lets perform a segue")
 
        //self.performSegue(withIdentifier: "ShowRecipeSegue", sender: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?){
        print("PREPARE FOR SEGUE")
        if  segue.identifier == "ShowRecipeSegue",
            let destination = segue.destination as? RecipeViewController,
            let recipeIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.setRecipeId(id: results[recipeIndex].value(forKey: "id") as! Int)
            destination.getRecipe()
            print("****\(recipeIndex)")
            print("****\(results[recipeIndex].value(forKey: "id") as! Int)")
            print("****\(destination.getRecipeId())")
        }

    }

}
