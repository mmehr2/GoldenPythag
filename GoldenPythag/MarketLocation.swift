//
//  MarketLocation.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/5/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import Foundation

/*
The MarketLocation can be thought of as a customization concept.
The basic default markets are opaque to the user as to trading location and origin date, although the locations are known by convention and are described in the manual.
However, customized markets require a trading location be defined in the app. This can be set to be one of the default locations for the convenience of the user, or a totally different location can be defined for market exchanges not covered by the app.

The MarketLocation has an ID that is paired with a name (for the default objects), similar to what is done in Market.
The CustomMarketLocation object adds a redefinable name
*/

class MarketLocation {
    // this is the basic market - it pairs a name with an ID
    let id : Int
    
    // the name is not customizable, so get it from default data directly
    var name : String { return MarketLocation.GetDefaultName(id)! }
    
    init(ID idx: Int) {
        id = idx
    }
    
    // NOTE: in Swift 1.2 this can be a variable/property
    private struct Static {
        static let lastDefaultID = 20050 // room for expansion
    }
    private class func GetData() -> [Int:String] {
        return [
            20001: "New York",
            20002: "Chicago",
            20003: "London",
            20004: "Tokyo",
            20005: "Brussels",
        ]
    }
    
    class func IsDefault(ID : Int) -> Bool {
        return GetData()[ID] != nil
    }
    
    class func GetDefaultName(ID : Int) -> String? {
        return GetData()[ID]
    }
    
    class func GetDefaults() -> [MarketLocation]
    {
        let names = GetData()
        var result = [MarketLocation]()
        for (idx, namex) in names {
            result.append(MarketLocation(ID: idx))
        }
        return result
    }
    
    class func GetNumDefaults() -> Int {
        return GetDefaults().count
    }
    
    class func GetRandomItem() -> MarketLocation {
        return GetDefaults()[ getRandomFrom(0, to: GetNumDefaults()) ]
    }
}

class CustomMarketLocation : MarketLocation {
    /*
    NOTE: the base class name won't work here (no default names), so we add a private property to store the user's custom name, if any, and redefine the name property to allow setting and getting it
    */
    private var customName = "" // don't use this directly, use name instead
    override var name : String { // editable in derived class
        get {
            return customName
        }
        set {
            customName = newValue
        }
    }
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var timezone : Double = 0.0
    
    init(name namex: String, withID idx: Int, andTimeZone tzonex:Double, isAtLatitude locLat:Double, andLongitude locLon: Double)
    {
        latitude = locLat
        longitude = locLon
        timezone = tzonex
        customName = namex
        super.init(ID: idx)
    }
    
    // this cannot be allowed, because (A) we need more info, and (B) base class won't work
    override init(ID idx: Int) {
        fatalError("init(ID:) can not be implemented")
    }
}