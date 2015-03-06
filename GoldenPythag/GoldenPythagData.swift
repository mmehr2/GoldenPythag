//
//  GoldenPythagData.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/3/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import Foundation

/*
This is the class implementing the model for the GoldenPythag app.
It contains all the data needed by the app including:
    > List of prediction runs (historical)
    > List of markets currently in use (default plus custom)
    > List of market locations currently in use (default plus custom)
    > List of price pivot lists currently in use
    > Currently selected market, if any
    > Currently selected price list, if any
*/

class GoldenPythag {
    var predictions : [Prediction] = []
    var markets : [Market] = []
    var marketLocations : [MarketLocation] = []
    var pivotLists : [PricePivotList] = []
    var currentMarket : Market?
    var currentPivotList : PricePivotList?

    func getMarketWithID(id: Int) -> Market? {
        for market in markets {
            if market.id == id {
                return market
            }
        }
        return nil
    }
    
    func getMarketLocationWithID(id: Int) -> MarketLocation? {
        for marketLocation in marketLocations {
            if marketLocation.id == id {
                return marketLocation
            }
        }
        return nil
    }
    
    // this should follow proper singleton pattern (needs update for Swift 1.2)
    // Refer: http://stackoverflow.com/questions/24024549/dispatch-once-singleton-model-in-swift
    class var modelData: GoldenPythag {
        struct Static {
            static let instance: GoldenPythag = GoldenPythag.Get()
        }
        return Static.instance
    }
    
    private class func Get() -> GoldenPythag {
        // current persistence mechanism: None
        // at startup, we generate simulated data for predictions and pivot lists
        // markets and market locations are set back to defaults
        let pdata = GoldenPythag()
        pdata.markets = Market.GetDefaults()
        pdata.marketLocations = MarketLocation.GetDefaults()
        pdata.predictions = Prediction.GetDefaults() // simulated
        pdata.pivotLists = PricePivotList.GetDefaults() // simulated
        return pdata
    }
}