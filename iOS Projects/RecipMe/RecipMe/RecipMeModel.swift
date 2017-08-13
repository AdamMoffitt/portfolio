//
//  RecipMeModel.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/3/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class RecipMeModel {
    
    var myKitchen: [String: FoodItem]
    var myUser : User?
    var users : [String]
    var favorites : [Recipe]
    
    var kitchenChanged : Bool
    //var ref:FIRDatabaseReference?
    var results: [NSDictionary] //array of recipe dictionaries that is retrieved from JSON API queries
    var recipeResults: [Recipe] //array of recipe items, filled in as recipes from results are queried individually for more information
    var imageNotFoundImage : UIImage?
    var ref : DatabaseReference!
    var unitsOfMeasurement = ["Units", "Gallons" , "Cans", "Boxes" , "Cups", "Ounces", "Pounds", "Grams"]
    var storage : Storage
    var storageRef : StorageReference
    
    var isSearching: Bool
    // Singleton
    
    static var shared = RecipMeModel()
    
    init(){
        
        ref = Database.database().reference()
        // Get a reference to the storage service using the default Firebase App
        storage = Storage.storage()
        // Create a storage reference from our storage service
        storageRef = storage.reference()
        
        myKitchen = [String: FoodItem]();
        users = []
        favorites = []
        results = []
        recipeResults = []
        //loadFromPlist()
        kitchenChanged = true
        isSearching = false
        
        // set image not found image
        let url = URL(string:
            "https://spoonacular.com/cdn/ingredients_636x393/imageNotFound.jpg" )
        
        if(url == nil){}
        else{
            if let data = try? Data(contentsOf: url!) {
                imageNotFoundImage = UIImage(data: data)
            }
        }
        
        searchData(completionHandler: {_ in self.isSearching=false})
    }
    
    func setFireBase(ref: DatabaseReference) {
        self.ref = ref
    }
    
    func getMyKitchen() -> [String:FoodItem] {
        return myKitchen
    }
    
    func checkEmptyKitchen() -> Bool {
        return (self.getMyKitchen().isEmpty)
    }
    
    func addUser(email: String) {
        users.append(email)
    }
    
    func getMyUser()-> User {
        if(myUser != nil) {
            return myUser!
        }
        else {
            return User()
        }
    }
    
    func setMyUser(newUser: User){
        self.myUser = newUser
    }
    
    func saveUserProfilePic(image: UIImage) {
        
        let tempRef = Database.database().reference().child("Users").child((self.myUser?.uid)!)
        
        tempRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            //delete previous photo before adding new one
            if let prevPhotoID = value?["profilePictureID"] as? String{
                // Create a reference to the file to delete
                let desertRef = self.storageRef.child(prevPhotoID)
                // Delete the file
                desertRef.delete { error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                    } else {
                        // File deleted successfully
                    }
                }
                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    
        let tempImageName = NSUUID().uuidString
        let tempStorageRef = storageRef.child("\(tempImageName).png")
        var tempSavedImageURL = ""
        if let uploadData = UIImageJPEGRepresentation(image, 0.1) {
            tempStorageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print (error ?? "Error")
                    return
                }
                //save the firebase image url in order to download the image later
                tempSavedImageURL = (metadata?.downloadURL()?.absoluteString)!
                self.myUser?.profilePictureImageURL = tempSavedImageURL
                self.myUser?.profilePictureID = "\(tempImageName).png"
                tempRef.child("profilePictureID").setValue("\(tempImageName).png")
                tempRef.child("profilePictureImageURL").setValue(tempSavedImageURL)
            })
        }
    }
    
    //Add Food item to kitchen
    func addItem(_ newFood: FoodItem ){
        kitchenChanged = true
        myKitchen.updateValue(newFood, forKey: newFood.name!);
        saveKitchen()
    }
    
    //Remove Food Item from kitchen
    func removeItem(_ name: String){
        kitchenChanged = true
        myKitchen.removeValue(forKey: name);
        saveKitchen()
    }
    
    func addFavorite(recipe: Recipe, index: Int) {
        
        if !favorites.contains(where: {$0.id==recipe.id}) {
            recipe.isFavorite = true
            if(index != -1){
                recipeResults[index].isFavorite = true
            }
            if let rIndex = recipeResults.index(where: {$0.id==recipe.id}) {
                recipeResults[rIndex].isFavorite = true
            }
            favorites.append(recipe)
            saveFavorites()
        }
    }
    
    
    func removeFavorite(index: Int) {
        let recipeId = favorites[index].id
        self.favorites.remove(at: index)
        if let rIndex = recipeResults.index(where: {$0.id==recipeId}) {
            recipeResults[rIndex].isFavorite = false
        }
        saveFavorites()
    }
    
    //returns a string that is used for putting in the url request to spoonacular API
    func getKitchenIngredients() -> String {
        var ingr = ""
        for f in myKitchen{
            ingr += f.key.replacingOccurrences(of: " ", with: "-")
            ingr += ","
        }
        return ingr
    }
    
    
    //for saving to plist
    func saveKitchen(){
        
        var kitchen: [String] = []
        
        let uid = Auth.auth().currentUser?.uid
        ref = Database.database().reference().child("Users").child(uid!).child("FoodItems")
        for kitchenItem in myKitchen{
            //make array of kitchen items to save to plist
            kitchen.append(kitchenItem.key)
            
            //save to firebase
            let name = kitchenItem.key
            let quantity = kitchenItem.value.quantity
            let unit = kitchenItem.value.unitOfMeasurement
            
            self.ref.child(name)
                .child("FoodItemName").setValue(name)
            self.ref.child(name)
                .child("Quantity").setValue(Int(quantity!))
            self.ref.child(name)
                .child("Unit").setValue(unit)
            
            
            //convert dates to strings to save in firebase
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            if(kitchenItem.value.addedDate != nil) {
                let addedDate = kitchenItem.value.addedDate!
                let addedDateString = dateFormatter.string(from:addedDate)
                self.ref.child(name)
                    .child("AddedDate").setValue(addedDateString)
            }
            
            if(kitchenItem.value.expirationDate != nil) {
                let expirationDate = kitchenItem.value.expirationDate!
                let expirationDateString = dateFormatter.string(from:expirationDate)
                self.ref.child(name)
                    .child("ExpirationDate").setValue(expirationDateString)
            }
            
        }
    }
    
    func saveFavorites() {
        let uid = Auth.auth().currentUser?.uid
        let fRef = Database.database().reference().child("Users").child(uid!).child("Favorites")
        
        for recipe in self.favorites {
            fRef.child(recipe.title).setValue(recipe.toDictionary())
        }
    }
    
    func loadFavorites() {
        let uid = Auth.auth().currentUser?.uid
        ref = Database.database().reference().child("Users").child(uid!).child("Favorites")
        ref.observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            if !snapshot.exists() { return }
            
            for child in (snapshot.children.allObjects as? [DataSnapshot])! {
                let recipe = Recipe(snapshot: child)
                if(!self.favorites.contains(recipe)){
                    self.favorites.append(recipe)
                }
            }
        })
    }
    
    func loadFromFirebase() {
        let uid = Auth.auth().currentUser?.uid
        ref = Database.database().reference().child("Users").child(uid!).child("FoodItems")
        ref.observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            if !snapshot.exists() { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy" //Your date format
            
            for child in (snapshot.children.allObjects as? [DataSnapshot])! {
                let value = child.value as? NSDictionary
                if let itemName = value?["FoodItemName"] as? String,
                let itemQuantity = value?["Quantity"] as? Int,
                let itemUnit = value?["Unit"] as? String,
                let aDate = value?["AddedDate"] as? String,
                let eDate = value?["ExpirationDate"] as? String{
                    let addedDate = dateFormatter.date(from: aDate) //according to date format your date string
                    let expirationDate = dateFormatter.date(from: eDate)
                    if (addedDate != nil  && expirationDate != nil){
                        let newFood = FoodItem(name: (itemName.capitalized), quantity: itemQuantity, unit: (itemUnit.capitalized), addedDate: addedDate!, expirationDate: expirationDate!)
                        if self.myKitchen.index(forKey: itemName) == nil {
                        self.myKitchen.updateValue(newFood, forKey: newFood.name!)
                    }
                    self.kitchenChanged = true
                }
                }
            }
        })
        
    }
    
    func searchData(completionHandler: @escaping (_ success:Bool) -> Void){
        
        if (isSearching == false) {
            
            //Set status of isSearching to true
            isSearching = true
            
            //Only run the query if the kitchen has been changed (something added or removed) or their are no current suggested recipes for the user in the results array of dictionaries, AND the kitchen is not empty
            if ((kitchenChanged == true || results.count < 1) && myKitchen.count > 0) {
                //run on background thread so app doesn't freeze
                DispatchQueue.global(qos: .background).async {
                    
                    //get current ingredients in kitchen
                    var ingredients = self.getKitchenIngredients().replacingOccurrences(of: " ", with: "")
                    
                    let headers = [
                        "X-Mashape-Key": "M2bNOAU8Z0mshqvOlAwaG837fTY4p18UbIUjsnq4yKt9ZT6mx0",
                        "Accept": "application/json"
                    ]
                    let url = NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/searchComplex?addRecipeInformation=false&fillIngredients=true&includeIngredients=\(ingredients)&limitLicense=false&number=20&offset=0&ranking=2")
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
                                                                            //TODO: iterate through all the results, if one of them doesn't have a picture, remove from the image results
                                                                            
                                                                        self.sortResults()
                                                                        self.convertToRecipes()
                                    }
                                                                        self.isSearching = false
                                                                    completionHandler(true)
                    })
                    
                    task.resume()
                }
                kitchenChanged = false
            }
            else {
                isSearching = false
            }
        }
    }
    
    func sortResults() {
        let tempR = self.results
        self.results = tempR.sorted(by: { //sort by 1) fewest missing ingreedients, 2) most used ingredients 3) how many likes
            if (($0["missedIngredients"] as! NSArray).count != ($1["missedIngredients"] as! NSArray).count) {
                
                return ($0["missedIngredients"] as! NSArray).count < ($1["missedIngredients"] as! NSArray).count
            }
            else if (($0["usedIngredients"] as! NSArray).count != ($1["usedIngredients"] as! NSArray).count) {
                
                return ($0["usedIngredients"] as! NSArray).count > ($1["usedIngredients"] as! NSArray).count
            }
            else {
                return ($0["likes"] as? Int)! > ($1["likes"] as? Int)!
            }
        })
    }
    
    //Take the results array of dictionaries and convert it into an array of Recipe objects
    func convertToRecipes() {
        for recipe in results {
            if let recipeName = recipe["title"] as? String,
                let usedIngredientsCount = recipe["usedIngredientCount"] as? Int,
                let usedIngredients = recipe["usedIngredients"] as? [NSDictionary],
                let missingIngredientsCount = recipe["missedIngredientCount"] as? Int,
                let missingIngredients = recipe["missedIngredients"] as? [NSDictionary],
                let recipeId = recipe["id"] as? Int {
                var image = UIImage(named: "RecipMeIcon")
                let imageURL = "https://spoonacular.com/recipeImages/\(String(describing: recipeId))-636x393.jpg"
                let url = URL(string: imageURL)
                if(url != nil) {
                    if let data = try? Data(contentsOf: url!) {
                        image = UIImage(data: data)
                    }
                }
                let r = Recipe(title: recipeName, usedIngredientsCount: usedIngredientsCount, usedIngredients: usedIngredients, missingIngredientsCount: missingIngredientsCount, missingIngredients: missingIngredients, image: image!, recipeId: recipeId, url: imageURL)
                recipeResults.append(r)
            }
            else {}
        }
    }
    
    //TODO: deal with the completion handlers here so that get recipe function will return recipe when done
    func getRecipe(recipeId: Int, completionHandler: @escaping ((_ recipe: Recipe)->())) {
        
        var newRecipe = Recipe()
        
        //check if extended recipe has already been queried by checking if the desires recipe already has extended instructions
        for recipe in recipeResults {
            if(recipe.id == recipeId){
                newRecipe = recipe
                if(recipe.extendedInstructions != ""){
                    completionHandler(recipe)
                }
            }
        }
        
        if(recipeId != nil){
            let headers = [
                "X-Mashape-Key": "M2bNOAU8Z0mshqvOlAwaG837fTY4p18UbIUjsnq4yKt9ZT6mx0",
                "Accept": "application/json"
            ]
            let url = NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/\(recipeId)/information?includeNutrition=false")
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
                                                                        
                                                                        let recipe = (responseDictionary)
                                                                        
                                                                        
                                                                        if recipe["title"] != nil {
                                                                            newRecipe.title = (recipe["title"] as? String)!
                                                                        }
                                                                        
                                                                        let urlString =  "https://spoonacular.com/recipeImages/\(String(describing: recipeId))-636x393.jpg"
                                                                        let url = URL(string: urlString)
                                                                        newRecipe.imageURL = urlString
                                                                        if(url != nil) {
                                                                            if let data = try? Data(contentsOf: url!) {
                                                                                newRecipe.image = UIImage(data: data)!
                                                                            }
                                                                        }
                                                                        //get instructions
                                                                        if recipe["instructions"] != nil {
                                                                            var textString = ""
                                                                            if(recipe["aggregateLikes"] != nil){
                                                                                
                                                                                let likes = recipe["aggregateLikes"] as! Int
                                                                                
                                                                                newRecipe.aggregateLikes = likes                }
                                                                            if(recipe["cookingMinutes"] != nil){
                                                                                
                                                                                let cookingMins = recipe["cookingMinutes"] as! Int
                                                                                
                                                                                newRecipe.cookingMinutes = cookingMins
                                                                                textString.append("Cooking Minutes: \((String)(cookingMins))\n")
                                                                            }
                                                                            if(recipe["preparationMinutes"] != nil){
                                                                                
                                                                                let prepMins = recipe["preparationMinutes"] as! Int
                                                                                
                                                                                newRecipe.preparationMinutes = prepMins
                                                                                textString.append("Preparation Minutes: \((String)(prepMins))\n")
                                                                            }
                                                                            if(recipe["readyInMinutes"] != nil){
                                                                                
                                                                                let readyInMinutes = recipe["readyInMinutes"] as! Int
                                                                                newRecipe.readyInMinutes = readyInMinutes
                                                                                textString.append("Ready in \((String)(readyInMinutes)) minutes!\n")
                                                                            }
                                                                            if(recipe["extendedIngredients"] != nil){
                                                                                textString.append("\nIngredients:\n")
                                                                                let ingr = recipe["extendedIngredients"] as! [NSDictionary]
                                                                                
                                                                                newRecipe.extendedIngredients = ingr
                                                                                for (index, _) in ingr.enumerated() {
                                                                                    textString.append("\(index+1): \((ingr[index] )["originalString"]!)\n")
                                                                                }
                                                                            }
                                                                            if let sourceURL = recipe["sourceUrl"]{
                                                                                
                                                                                newRecipe.sourceURL = (sourceURL as? String)!
                                                                                //if there are no instructions included with the recipe
                                                                                if(recipe["instructions"] is NSNull){
                                                                                    textString.append("\n\nVisit: \(sourceURL) for recipe instructions!")
                                                                                }else {
                                                                                    let instructions = recipe["instructions"] as! String
                                                                                    newRecipe.instructions = instructions
                                                                                    textString.append("\nInstructions:\n \(instructions))")
                                                                                }
                                                                            }
                                                                            newRecipe.extendedInstructions = textString
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                                completionHandler(newRecipe)
            })
            
            task.resume()
        }
        else{
            //print("recipe id is null")
        }
    }
    
    func handleSignOut(){
        do{
            try Auth.auth().signOut()
            let userDefaults = UserDefaults.standard
            userDefaults.setValue("", forKey: "email")
            userDefaults.setValue("", forKey: "password")
        }catch let logoutError {
            print(logoutError)
        }
    }
    
    //INTERESTING API FEATURE THAT FINDS FOOD NAMES IN SEGMENT OF TEXT
    //    func parseIngredients(String text) {
    //
    //        let headers = [
    //            "X-Mashape-Key": "M2bNOAU8Z0mshqvOlAwaG837fTY4p18UbIUjsnq4yKt9ZT6mx0",
    //            "Accept": "application/json"
    //        ]
    //        let params = [
    //            "text": "I like to eat delicious tacos. Only cheeseburger with cheddar are better than that. But then again, pizza with pepperoni, mushrooms, and tomatoes is so good!"
    //        ]
    //        let url = NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/detect")
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
    //                                                                    var ingredients = (responseDictionary["results"] as?[NSDictionary])!                          }
    //                                                                print(ingredients)
    
    //                                                            }
    //        });
    //        
    //        task.resume()
    //    }
    
}
