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
//    > Currently selected price list, if any
*/

// MARK: model facade class
class GoldenPythag {
    var predictions : [Prediction] = [] { didSet { GPNotification(broadcast: .PredictionList) } }
    var markets : [Market] = [] { didSet { GPNotification(broadcast: .MarketList) } }
    var marketLocations : [MarketLocation] = [] { didSet { GPNotification(broadcast: .MarketLocationList) } }
    var pivotLists : [PricePivotList] = [] { didSet { GPNotification(broadcast: .PivotListList) } }
    var currentMarket : Market? // used in filtering predictions and pivotList lists
     { didSet { GPNotification(broadcast: .MarketSelection) } }
    //var currentPivotList : PricePivotList? // used in filtering predictions list??
    // { didSet { broadcast(.PivotListSelection) } }
    
    // MARK: filtered lists
    var filteredPredictions : [Prediction] {
        get {
            return predictions.filter { (item) in
                self.currentMarket == nil ? true :
                    item.marketId == self.currentMarket!.id
            }
        }
    }
    var filteredPivotLists : [PricePivotList] {
        get {
            return pivotLists.filter { (item) in
                self.currentMarket == nil ? true :
                    item.marketId == self.currentMarket!.id
            }
        }
    }

    func getUnfilteredPredictionIndex( filteredRow: Int ) -> Int? {
        // find which data item is represented by the filtered row chosen
        let dataItem = filteredPredictions[filteredRow]
        // find the index of that item in the entire underlying list
        let underlyingIndex = findPredictionIndex(dataItem)
        return underlyingIndex
    }
    
    func getUnfilteredPredictionItem( filteredRow: Int ) -> Prediction? {
        // find the index of that item in the entire underlying list
        let underlyingIndex = getUnfilteredPredictionIndex(filteredRow)
        // get the underlying item at that index
        let underlyingItem = predictions[underlyingIndex!]
        return underlyingItem
    }
    
    func getUnfilteredPivotListIndex( filteredRow: Int ) -> Int? {
        // find which data item is represented by the filtered row chosen
        let dataItem = filteredPivotLists[filteredRow]
        // find the index of that item in the entire underlying list
        let underlyingIndex = findPivotListIndex(dataItem)
        return underlyingIndex
    }
    
    func getUnfilteredPivotListItem( filteredRow: Int ) -> PricePivotList? {
        // find the index of that item in the entire underlying list
        let underlyingIndex = getUnfilteredPivotListIndex(filteredRow)
        // get the underlying item at that index
        let underlyingItem = pivotLists[underlyingIndex!]
        return underlyingItem
    }

    // MARK: model statistics
    func average( input: [Double] ) -> Double? {
        if input.count == 0 {
            return nil
        }
        let total = input.reduce(0.0) { (total, item) in
            total + item
        }
        let result = total / Double(input.count)
        return result
    }
    
    func getTopPivotPrices( list: PricePivotList ) -> [Double] {
        return list.pivotList.filter { (item) in item.top }.map { (item) in item.price.doubleValue }
    }
    
    func getBottomPivotPrices( list: PricePivotList ) -> [Double] {
        return list.pivotList.filter { (item) in !item.top }.map { (item) in item.price.doubleValue }
    }

    // WARNING: The following several functions scan the entire model database and might require background threading
    func getPivotListsUsingMarketID( marketID: Int ) -> [PricePivotList] {
        return pivotLists.filter{ (item) in item.marketId == marketID }
    }
    
    func getPredictionsUsingMarketID( marketID: Int ) -> [Prediction] {
        return predictions.filter{ (item) in item.marketId == marketID }
    }
    
    func getPivotListIDsUsingMarketID( marketID: Int ) -> [Int] {
        return getPivotListsUsingMarketID( marketID ).map{ (item) in item.id }
    }
    
    func getPredictionIDsUsingMarketID( marketID: Int ) -> [Int] {
        return getPredictionsUsingMarketID( marketID ).map{ (item) in item.id }
    }

    func getAvgTopPrice( marketID: Int ) -> Double? {
        let pls = getPivotListsUsingMarketID(marketID) // [PricePivotList]
        let pps = pls.map{ (item) in self.getTopPivotPrices(item) } // [[Double]]
        return average(pps.reduce([]){ (total, arrayItem) in total + arrayItem})
    }
    
    func getAvgBottomPrice( marketID: Int ) -> Double? {
        let pls = getPivotListsUsingMarketID(marketID) // [PricePivotList]
        let pps = pls.map{ (item) in self.getBottomPivotPrices(item) } // [[Double]]
        return average(pps.reduce([]){ (total, arrayItem) in total + arrayItem})
    }
    
    // MARK: generic access methods
    // NOTE: these should truly be Swift generics, if I can figure out how
    func getMarketWithID(id: Int?) -> Market? {
        if let id = id {
            return getMarketWithID(id)
        }
        return nil
    }
    
    func getMarketWithID(id: Int) -> Market? {
        for item in markets {
            if item.id == id {
                return item
            }
        }
        return nil
    }
    
    func findMarketIndex( item: Market ) -> Int? {
         for index in 0 ..< markets.count {
            if item.id == markets[index].id {
                return index
            }
        }
        return nil
    }
    
    func getMarketLocationWithID(id: Int) -> MarketLocation? {
        for item in marketLocations {
            if item.id == id {
                return item
            }
        }
        return nil
    }
    
    func findMarketLocationIndex( item: MarketLocation ) -> Int? {
        for index in 0 ..< marketLocations.count {
            if item.id == marketLocations[index].id {
                return index
            }
        }
        return nil
    }
    
    func getPredictionWithID(id: Int) -> Prediction? {
        for item in predictions {
            if item.id == id {
                return item
            }
        }
        return nil
    }
    
    func findPredictionIndex( item: Prediction ) -> Int? {
        for index in 0 ..< predictions.count {
            if item.id == predictions[index].id {
                return index
            }
        }
        return nil
    }
    
    func findIndexOfPredictionWithID( predictionID: Int ) -> Int? {
        for index in 0 ..< predictions.count {
            if predictionID == predictions[index].id {
                return index
            }
        }
        return nil
    }
    
    func getPivotListWithID(id: Int) -> PricePivotList? {
        for item in pivotLists {
            if item.id == id {
                return item
            }
        }
        return nil
    }
    
    func findPivotListIndex( item: PricePivotList ) -> Int? {
        for index in 0 ..< pivotLists.count {
            if item.id == pivotLists[index].id {
                return index
            }
        }
        return nil
    }

    // MARK: singleton object
    // this should follow proper singleton pattern (needs update for Swift 1.2)
    // Refer: http://stackoverflow.com/questions/24024549/dispatch-once-singleton-model-in-swift
//    class var modelData: GoldenPythag {
//        struct Static {
//            static let instance: GoldenPythag = GoldenPythag.Get()
//        }
//        return Static.instance
//    }
    static let modelData = GoldenPythag.Get() // Swift 1.2 and above
    
    private class func Get() -> GoldenPythag {
        // current persistence mechanism: None
        // at startup, we generate simulated data for predictions and pivot lists
        // markets and market locations are set back to defaults
        let pdata = GoldenPythag()
        pdata.markets = Market.GetDefaults()
        pdata.marketLocations = MarketLocation.GetDefaults()
        // we could make the simulated data an optional setting or something
        pdata.predictions = Prediction.GetDefaults() // simulated
        pdata.pivotLists = PricePivotList.GetDefaults() // simulated
        return pdata
    }
}