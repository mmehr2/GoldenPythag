//
//  Prediction.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/2/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import Foundation

enum PredictionType : Printable  {
    case A, B, AB, NatalCheck
    var description : String {
        switch self {
        case A: return "A"
        case B: return "B"
        case AB: return "AB"
        case NatalCheck: return "NC"
        }
    }
    static func GetRandomItem() -> PredictionType {
        switch arc4random_uniform(3) {
        case 0: return .A
        case 1: return .B
        case 2: return .AB
        default: return .NatalCheck // should never happen as long as 3 is passed
        }
    }
}

enum PredictionState : Printable  {
    case New, InProgress, Completed, Failed
    var description : String {
        switch self {
        case New: return "New"
        case InProgress: return "In Progress"
        case Completed: return "Completed"
        case Failed: return "Failed"
        }
    }
}

class Prediction : Printable {
    // basic data encapsulates the parameters of a prediction request
    var startDate : NSDate = NSDate()
    var lengthInDays : Int = 1
    var type : PredictionType = .A
    let marketId : Int
    var pivotData : [PricePivot] = []
    // data that comes back during or after a prediction run
    var state : PredictionState = .New
    var message : String?
    var resultList : [Int] = []
    var runLength : NSTimeInterval = 0.0
    var runDate : NSDate?
    
    init( typeInput: PredictionType,
        onDate start: NSDate,
        forDays length: Int,
        withPrices pivotListInput: PricePivotList )
    {
        type = typeInput
        startDate = start
        lengthInDays = length
        marketId = pivotListInput.marketId! // must be associated by the time this is called
        pivotData = pivotListInput.pivotList
    }
    
    func setRandomResults( rundate : NSDate ) {
        runDate = rundate
        let fail = getRandomFrom(0, to: 6) == 0 // chance of failure is 1 in X=to
        if (fail) {
            state = .Failed
            message = "Simulated failure result."
            resultList = []
        } else {
            state = .Completed
            message = "Simulated successful result."
            for _ in 0..<lengthInDays {
                resultList.append(getRandomFrom(0, to: 1000))
            }
        }
    }
    
    var description : String {
        let market = Market.GetDefaultName(marketId)!
        return "Type \(type) run of \(market) market for \(lengthInDays) days from \(startDate) (\(state) with \(pivotData.count) prices and \(resultList.count) results)"
    }
    
    class func GetDefaults() -> [Prediction] {
        // create and return an array of random data to play with
        var pdata = [Prediction]()
        let loops = getRandomFrom(4, to: 8)
        for _ in 0..<loops {
            let length = getRandomFrom(5, to: 30)
            let object = Prediction(typeInput: .GetRandomItem(), onDate: getRandomDate(), forDays: length, withPrices: PricePivotList.GetRandomItem())
            object.setRandomResults(getRandomDate())
            pdata.append(object)
        }
        return pdata
    }
}