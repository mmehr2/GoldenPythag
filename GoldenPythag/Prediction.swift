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
}