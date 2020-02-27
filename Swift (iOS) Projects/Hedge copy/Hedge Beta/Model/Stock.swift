//
//  Stock.swift
//  fundü
//
//  Created by Hunter Hurja on 2/6/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import Foundation
import UIKit

class Stock {
    var name: String?
    var price: String?
    var action: String?
    var symbol: String?
    var isOwned: Bool?
    var change: Float?
    var numShares: Int?
    
    init() {
        name = ""
        action = ""
        price = ""
        symbol = ""
    }
    
    init(stockData: [String: AnyObject]) {
        if let n = stockData["stockName"] as? String {
            name = n
        }
        if let a = stockData["action"] as? String {
            action = a
        }
        if let p = stockData["stockPrice"] as? Float {
            price = NSString(format: "%.2f", p) as String
        }
        if let s = stockData["stockSymbol"] as? String {
            symbol = s
        }
    }
    
    init(name:String, action:String, price:Float, symbol:String, change:Float){
        self.name = name
        self.action = action
        self.price = NSString(format: "%.2f", price) as String
        self.symbol = symbol
        self.change = change
    }
    
    var backgroundColor: UIColor {
        if action == "sell" {
            return UIColor.lightGray
        }
        return UIColor.blue
    }
    
    var typeColor: UIColor {
        if action == "sell" {
            return UIColor.black
        }
        return UIColor.purple
    }
    
    var priceLabelColor: UIColor {
        if action == "sell" {
            return UIColor.darkGray
        }
        return UIColor.green
    }
}

