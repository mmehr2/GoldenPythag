//
//  PricePivot.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/2/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import Foundation

enum PricePivotType : Printable  {
    case Bottom, Top
    var description : String {
        switch self {
        case Bottom: return "B"
        case Top: return "T"
        }
    }
}

struct PricePivot : Printable {
    var date : NSDate
    var price : NSNumber
    var top : Bool
    var description : String {
        return "\(price) \(top) \(date)"
    }
}

struct PricePivotList : Printable {
    var name : String?
    var notes : String?
    var marketId : Int?
    var pivotList : [PricePivot] = []
    
    init(market: Market) {
        marketId = market.id
    }
    
    func minMaxDate() -> (NSDate, NSDate)? {
        if pivotList.count == 0 { return nil }
        let pls = pivotList.sorted({ $0.date < $1.date })
        return (pls.first!.date, pls.last!.date)
    }
    var defaultDescription : String {
        if let (minDate, maxDate) = minMaxDate() {
            return "\(pivotList.count) prices from \(minDate) to \(maxDate)"
        } else {
            return "0 prices"
        }
    }
    var description : String {
        return name ?? defaultDescription
    }
}