//
//  Basics.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/2/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import Foundation

/*
Solution for SourceKitService Terminated errors in XCode 6.1.1:
http://stackoverflow.com/questions/24006206/sourcekitservice-terminated
which says to run this command line to eliminate some cache data:
    rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache
*/

// get random integer in between two numbers (+ve only, from < to)
func getRandomFrom(from: Int, #to: Int) -> Int {
    let arg : UInt32 = UInt32(to - from)
    return Int(arc4random_uniform(arg)) + from
}

// full set of comparison operators for NSDate pairs
func <(d1: NSDate, d2: NSDate) -> Bool {
    let res = d1.compare(d2)
    return res == .OrderedAscending
}

func ==(d1: NSDate, d2: NSDate) -> Bool {
    let res = d1.compare(d2)
    return res == .OrderedSame
}

func >(d1: NSDate, d2: NSDate) -> Bool {
    let res = d1.compare(d2)
    return res == .OrderedDescending
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

// func for getting a random date
func getRandomDate() -> NSDate {
    var date = NSDate()
    let numToAdd = getRandomFrom(0, to: 30)
    date = date.addDays(numToAdd - 365)
    return date
}

// date extension to easily deal with adding days to dates

private let secsPerDay = 24 * 60 * 60

extension NSDate {
    func addDays(days : Int) -> NSDate {
        let time = NSTimeInterval(days * secsPerDay)
        return self.dateByAddingTimeInterval(time)
    }
}