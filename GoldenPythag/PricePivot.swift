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

// MARK: basic pivot data types
//enum PricePivotType : Int, Printable  {
//    case Bottom = 0, Top
//    var description : String {
//        switch self {
//        case Bottom: return "B"
//        case Top: return "T"
//        }
//    }
//}

typealias Price = NSNumber

// pivot struct pairs a price with a date, also indicating top or bottom price inflection
struct PricePivot : CustomStringConvertible {
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

// MARK: list class entity
// identified list of pivots associated with a particular market
class PricePivotList : CustomStringConvertible {
    let id : Int
    var marketId : Int
    var name : String? { didSet { notification.broadcast() } }
    var notes : String? { didSet { notification.broadcast() } }
    var pivotList : [PricePivot] = [] { didSet { notification2.broadcast() } }
    
    init(ID: Int, market: Market) {
        id = ID
        marketId = market.id
    }
    
    init(ID: Int, marketID : Int)
    {
        id = ID
        marketId = marketID
    }
    
    // MARK: change notification feature
    var notifying : Bool = false
    private var notification : GPNotification {
        return GPNotification(type: notifying ? .PivotList : .None)
    }
    private var notification2 : GPNotification {
        return GPNotification(type: notifying ? .PivotList : .None)
    }
    
    // MARK: custom ID generator
    // Swift 1.2 would use a static/class variable instead of nested struct
    private struct Static {
        static var idCounter = 1000
    }
    class func assignID() -> Int {
        return Static.idCounter++ // commit to using the next ID
    }
    class func getNextID() -> Int {
        return Static.idCounter // get what the next ID would be
    }

    // MARK: standardized description/name
    // description is pivot count with optional date range
    func minMaxDate() -> (NSDate, NSDate)? {
        if pivotList.count == 0 { return nil }
        let pls = pivotList.sort({ $0.date < $1.date })
        return (pls.first!.date, pls.last!.date)
    }
    var description : String {
        if let (minDate, maxDate) = minMaxDate() {
            return "\(pivotList.count) prices from \(minDate) to \(maxDate)"
        } else {
            return "0 prices"
        }
    }
    
    // standard name if user hasn't entered one (uses name if present)
    var standardName : String {
        return name ?? "List \(id)"
    }

    // MARK: simulated data generation
    class func GetRandomItem() -> PricePivotList {
        // create and return an unnamed array of random data to play with
        let pdata = PricePivotList(ID: assignID(), market: Market.GetRandomItem())
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