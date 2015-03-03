//
//  Market.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/2/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import Foundation

struct Market {
    // this is the basic market - it pairs a name with an ID
    let id : Int
    let name : String

    private static let names : [String] = [
        "Bonds", "Cocoa", "Silver", "Gold", "Crude Oil"
    ]
    
    static func GetDefaultMarkets() -> [Market]
    {
        var result = [Market]()
        for i in 0..<names.count {
            result.append(Market(id: i, name: names[i]))
        }
        return result
    }
 }