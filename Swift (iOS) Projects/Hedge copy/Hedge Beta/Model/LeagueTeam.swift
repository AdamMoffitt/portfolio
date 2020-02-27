//
//  LeagueTeam.swift
//  fundü
//
//  Created by Adam Moffitt on 2/16/18.
//  Copyright © 2018 fundü. All rights reserved.
//

import Foundation
import SwiftyJSON

class LeagueTeam: NSObject {
    
    var teamName : String
    var teamID : String
    var dayChange : Float
    var weekChange : Float
    var monthChange : Float
    var yearChange : Float
    var overallChange : Float
    var teamBalance : Float
    var color : UIColor
    
    override init() {
        teamName = ""
         teamID = ""
         dayChange = 0
         weekChange = 0
         monthChange = 0
         yearChange = 0
         overallChange = 0
         teamBalance = 100000
        color = UIColor.clear
    }
    
    convenience init(dictionary: NSDictionary) {
        self.init()
        
        let json = JSON(dictionary)
            self.teamName = json["teamName"].stringValue
            self.teamID = json["teamID"].stringValue
            self.dayChange = json["dayIncrease"].floatValue
            self.weekChange = json["weekIncrease"].floatValue
            self.monthChange = json["monthIncrease"].floatValue
            self.yearChange = json["yearlyIncrease"].floatValue
            self.overallChange = json["overallIncrease"].floatValue
            self.teamBalance = json["teamBalance"].floatValue
        color = getRandomColor()
    }
    
    // JUST FOR TESTING
    func getRandomColor() -> UIColor{
        //Generate between 0 to 1
        let red:CGFloat = CGFloat(drand48())
        let green:CGFloat = CGFloat(drand48())
        let blue:CGFloat = CGFloat(drand48())
        
        return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }
}

