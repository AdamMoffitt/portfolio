//
//  RecipeItem.swift
//  RecipMe
//
//  Created by Adam Moffitt on 2/20/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Recipe: NSObject {

    var imageURL : String
    var image : UIImage
    var title : String
    var info : String
    var id : Int
    var aggregateLikes : Int
    var cookingMinutes : Int
    var preparationMinutes : Int
    var readyInMinutes : Int
    var extendedIngredients : [NSDictionary]
    var missingIngredients : [NSDictionary]
    var missingIngredientsCount : Int
    var usedIngredients : [NSDictionary]
    var usedIngredientsCount : Int
    var sourceURL : String
    var instructions : String
    var extendedInstructions : String
    var isFavorite : Bool
    
    override init() {
        imageURL = ""
        image = UIImage(named: "RecipMeIcon")!
        title = ""
        info = ""
        id = 0
        aggregateLikes = 0
        cookingMinutes = 0
        preparationMinutes = 0
        readyInMinutes = 0
        extendedIngredients = [[String:String]() as NSDictionary]
        missingIngredients = [] //TODO
        missingIngredientsCount = 0
        usedIngredients = [] //TODO
        usedIngredientsCount = 0
        sourceURL = ""
        instructions = ""
        extendedInstructions = ""
        isFavorite = false
    }
    
    convenience init(title: String, image: UIImage, info: String, id: Int){
        self.init()
        self.title = title
        self.image = image
        self.info = info
        self.id = id
    }
    
    convenience init(imageURL: String, title: String, aggregateLikes: Int, cookingMinutes: Int, preparationMinutes: Int, readyInMinutes: Int, extendedIngredients: [NSDictionary], sourceURL: String, instructions: String, extendedInstructions: String){
        self.init()
        self.imageURL = imageURL
        self.title=title
        self.aggregateLikes=aggregateLikes
        self.cookingMinutes=cookingMinutes
        self.preparationMinutes=preparationMinutes
        self.readyInMinutes=readyInMinutes
        self.extendedIngredients=extendedIngredients
        self.sourceURL=sourceURL
        self.instructions=instructions
        self.extendedInstructions = extendedInstructions
    }
    convenience init(title: String, usedIngredientsCount: Int, usedIngredients: [NSDictionary], missingIngredientsCount: Int,  missingIngredients: [NSDictionary], image: UIImage, recipeId: Int, url: String){
        self.init()
        self.title = title
        self.usedIngredientsCount = usedIngredientsCount
        self.usedIngredients = usedIngredients
        self.missingIngredientsCount = missingIngredientsCount
        self.missingIngredients = missingIngredients
        self.id = recipeId
        self.image = image
        self.imageURL = url
    }
    
    convenience init(snapshot: DataSnapshot){
        self.init()
        let value = snapshot.value as? NSDictionary
        if  let title = value?["title"] {
        self.title = title as! String
         print(title)
         self.imageURL = value?["imageURL"] as! String
         self.getImage()
         self.info = value?["info"] as! String
         self.id = value?["id"] as! Int
         self.aggregateLikes = value?["aggregateLikes"] as! Int
         self.cookingMinutes = value?["cookingMinutes"] as! Int
         self.preparationMinutes = value?["preparationMinutes"] as! Int
         self.readyInMinutes = value?["readyInMinutes"] as! Int
         self.sourceURL = value?["sourceURL"] as! String
         self.instructions = value?["instructions"] as! String
         self.extendedInstructions = value?["extendedInstructions"] as! String
         self.isFavorite = value?["isFavorite"] as! Bool
        print(isFavorite)
        if let extendedIngredients = value?["extendedIngredients"] {
            self.extendedIngredients = extendedIngredients as! [NSDictionary]
        }
        
        if let missingIngredients = value?["missingIngredients"] {
            self.missingIngredients = missingIngredients as! [NSDictionary]
        }
        
        if let usedIngredients = value?["usedIngredients"] {
            self.usedIngredients = usedIngredients as! [NSDictionary]
        }
        }
    }
    
    func getImage() {
        //DispatchQueue.main.async {
        print("get image: \(self.imageURL)")
            if let data = try? Data(contentsOf: NSURL(string: self.imageURL)! as URL) {
                print("got image")
                self.image = UIImage(data: data)!
            }
        //}
    }
    
    func toDictionary() -> Any {
        return [
            "imageURL" : self.imageURL,
            "title" :self.title,
            "info" : self.info,
            "id" : self.id,
            "aggregateLikes" : self.aggregateLikes,
            "cookingMinutes" : self.cookingMinutes,
            "preparationMinutes" : self.preparationMinutes,
            "readyInMinutes" : self.readyInMinutes,
            "extendedIngredients" : self.extendedIngredients,
            "missingIngredients" : self.missingIngredients,
            "usedIngredients" : self.usedIngredients,
            "sourceURL" : self.sourceURL,
            "instructions" : self.instructions,
            "extendedInstructions" : self.extendedInstructions,
            "isFavorite" : self.isFavorite
        ]
    }
}
