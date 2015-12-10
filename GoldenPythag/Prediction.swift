//
//  Prediction.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/2/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import Foundation

enum PredictionType : Int, Printable  {
    case A = 0, B, AB, NatalCheck
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

class Prediction {
    let id : Int
    var marketId : Int?
    // basic data encapsulates the parameters of a prediction request
    var startDate : NSDate = NSDate()
    var lengthInDays : Int = 1
    var type : PredictionType = .A
    var pivotData : [PricePivot] = []
    // data that comes back during or after a prediction run
    var state : PredictionState = .New { didSet { notification.broadcast() } }
    var message : String?
    var resultList : [Int] = []
    var runLength : NSTimeInterval = 0.0
    var runDate : NSDate?
    var endDate : NSDate { // computed, read-only property
        return startDate.addDays(lengthInDays)
    }
    
    // custom ID generator
    // Swift 1.2 would use a static/class variable instead of nested struct
    private struct Static {
        static var idCounter = 30000
    }
    class func assignID() -> Int {
        return Static.idCounter++ // commit to using the next ID
    }
    class func getNextID() -> Int {
        return Static.idCounter // get what the next ID would be
    }

    // simple init to allow editor to fill in rest of required parameters
    init(ID idx: Int) {
        id = idx
    }
    
    init(ID idx: Int,
        typeInput: PredictionType,
        onDate start: NSDate,
        forDays length: Int,
        withPrices pivotListInput: PricePivotList )
    {
        id = idx
        type = typeInput
        startDate = start
        lengthInDays = length
        marketId = pivotListInput.marketId
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
    
    // MARK: change notification feature
    var notifying : Bool = false
    private var notification : GPNotification {
        return GPNotification(type: notifying ? .Prediction : .None)
    }
    
//    var description : String {
//        let market = marketId != nil ? Market.GetDefaultName(marketId!)! : "None"
//        return "Type \(type) run of \(market) market for \(lengthInDays) days from \(startDate) (\(state) with \(pivotData.count) prices and \(resultList.count) results)"
//    }
    
    class func GetDefaults() -> [Prediction] {
        // create and return an array of random data to play with
        var pdata = [Prediction]()
        let loops = getRandomFrom(4, to: 8)
        for _ in 0..<loops {
            let length = getRandomFrom(5, to: 30)
            let object = Prediction(ID: assignID(), typeInput: .GetRandomItem(), onDate: getRandomDate(), forDays: length, withPrices: PricePivotList.GetRandomItem())
            object.setRandomResults(getRandomDate())
            pdata.append(object)
        }
        return pdata
    }
}