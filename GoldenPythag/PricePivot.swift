//
//  PricePivot.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/2/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import Foundation

/*
The PricePivot is an essential concept of the app.
It describes a turning point in the market trading price.
It consists of a price coupled with a date, and an indicator if a Top or Bottom turnaround.

The list class adds a Name and Notes to a PricePivot array, and associates the list with a particular Market.

The GetDefaults() static/class functions are designed to create random test data for use before I fully implement CoreData persistence for the objects.
*/

enum PricePivotType : Printable  {
    case Bottom, Top
    var description : String {
        switch self {
        case Bottom: return "B"
        case Top: return "T"
        }
    }
}

typealias Price = NSNumber

struct PricePivot : Printable {
    var date : NSDate
    var price : Price
    var top : Bool
    var description : String {
        let topStr = top ? "Top" : "Bot"
        return "\(price.doubleValue) \(topStr) \(date)"
    }
    
    private static let maxRandomPrice = 100_000 // $1000, in penny-sized units
    private static let minRandomPrice = 1_000 // $10, in same units
    private static let currencyFactor = 100.0 // divisor for random price generator (100c/$ default)
    
    static func GetDefaults() -> [PricePivot] {
        // create and return an array of random data to play with
        /*
        NOTE: To get usable pivot lists, the prices must behave a certain way.
        They must alternate going up or down from the previous one, and for my own sanity they must remain within the bounds specified by the min/max random price constants.
        Also, the dates must be monotonically increasing
        */
        var result = [PricePivot]()
        let loops = getRandomFrom(2, to: 15)
        let midRandomPrice = Int(Double(minRandomPrice + maxRandomPrice)/2.0)
        let startDate = getRandomDate()
        var interval = 0
        while result.count < loops {
            var next = PricePivot.GetRandomItem()
            next.price = (next.top ?
                GetRandomPriceFrom(midRandomPrice, to: maxRandomPrice) :
                GetRandomPriceFrom(minRandomPrice, to: midRandomPrice) )
            next.date = startDate.addDays(interval)
            interval += getRandomFrom(3, to: 20)
            result.append(next)
        }
        return result
    }

    private static var lastBool : Bool = false
    private static func GetAlternatingBool() -> Bool {
        lastBool = !lastBool
        return lastBool
    }

    private static func GetRandomPriceFrom(min: Int, to max: Int) -> Price {
        let d2 = Double(getRandomFrom(min, to: max)) / currencyFactor
        return NSNumber(double: d2)
    }
    
    private static func GetRandomPrice() -> Price {
        return GetRandomPriceFrom(minRandomPrice, to: maxRandomPrice)
    }
    
    static func GetRandomItem() -> PricePivot {
        return PricePivot(date: getRandomDate(), price: GetRandomPrice(), top: GetAlternatingBool())
    }
}

// MARK: list class
class PricePivotList : Printable {
    var name : String?
    var notes : String?
    var marketId : Int?
    var pivotList : [PricePivot] = []
    
    init(market: Market) {
        marketId = market.id
    }
    
    init(marketID : Int, pivots: [PricePivot])
    {
        marketId = marketID
        pivotList = pivots
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
    
    class func GetRandomItem() -> PricePivotList {
        // create and return an unnamed array of random data to play with
        var pdata = PricePivotList(market: Market.GetRandomItem())
        pdata.pivotList = PricePivot.GetDefaults()
        return pdata
    }
    
    class func GetDefaults() -> [PricePivotList] {
        var result = [PricePivotList]()
        let loops = getRandomFrom(3, to: 10)
        for _ in 0..<loops {
            result.append(PricePivotList.GetRandomItem())
        }
        return result
    }
}