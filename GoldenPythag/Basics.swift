//
//  Basics.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/2/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import Foundation

// full set of comparison operators for NSDate pairs
func <(d1: NSDate, d2: NSDate) -> Bool {
    let res = d1.compare(d2)
    return res == NSComparisonResult.OrderedAscending
}

func ==(d1: NSDate, d2: NSDate) -> Bool {
    let res = d1.compare(d2)
    return res == NSComparisonResult.OrderedSame
}

func >(d1: NSDate, d2: NSDate) -> Bool {
    let res = d1.compare(d2)
    return res == NSComparisonResult.OrderedDescending
}

func !=(d1: NSDate, d2: NSDate) -> Bool {
    return !(d1 == d2)
}

func >=(d1: NSDate, d2: NSDate) -> Bool {
    return !(d1 < d2)
}

func <=(d1: NSDate, d2: NSDate) -> Bool {
    return !(d1 > d2)
}
