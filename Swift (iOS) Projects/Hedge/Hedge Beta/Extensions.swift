//
//  Extensions.swift
//  Hedge Beta
//
//  Created by Adam Moffitt on 3/31/18.
//  Copyright © 2018 Adam's Apps. All rights reserved.
//


import Foundation

extension Array {
    func difference<T: Equatable>(otherArray: [T]) -> [T] {
        var result = [T]()
        
        for e in self {
            if let element = e as? T {
                if !otherArray.contains(element) {
                    result.append(element)
                }
            }
        }
        
        return result
    }
    
    func intersection<T: Equatable>(otherArray: [T]) -> [T] {
        var result = [T]()
        
        for e in self {
            if let element = e as? T {
                if otherArray.contains(element) {
                    result.append(element)
                }
            }
        }
        
        return result
    }
    
    mutating func rearrange(from: Int, to: Int) {
        precondition(from != to && indices.contains(from) && indices.contains(to), "invalid indexes")
        insert(remove(at: from), at: to)
    }
}


extension Formatter {
    static let withComma: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension BinaryInteger {
    var formattedWithComma: String {
        return Formatter.withComma.string(for: self) ?? ""
    }
}

extension String {
    func capitalizeFirst() -> String {
        if !self.isEmpty {
            let firstIndex = self.index(startIndex, offsetBy: 1)
            return self.substring(to: firstIndex).capitalized + self.substring(from: firstIndex).lowercased()
        } else {
            return ""
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

