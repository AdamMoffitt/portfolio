//
//  FeedEvent.swift
//  fundü
//
//  Created by Jordan Coppert on 12/5/17.
//  Copyright © 2017 fundü. All rights reserved.
//

import Foundation

enum FeedType {
    case company(String)
    case other
}

struct FeedEvent{
    var image:String
    var message:String
    var time:String
    var type:FeedType
}
