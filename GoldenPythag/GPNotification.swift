//
//  GPNotification.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/9/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import Foundation

/*
My notification system is designed to let the VCs know when model changes are of interest.
There are two types: 
    keeping a VC's tableView loaded with all the right names (and number of entries), AND
    keeping a VC doing editing aware of changes to its data (and making others aware when it changes an object)
The model level master lists always send notifications when they are updated. Same goes for the market selection filter.
The individual data objects can also be set to send notifications, but they default to off.
There is a special type of object (.None) that never sends notifications. This is to make it easy to set up data that will "send" something in any case, but can switch to not sending on the fly.

USAGE NOTES:
MLM, 3/13/2015 -
The objects are designed to be created as temporaries to broadcast, or can be held and turned into observers by calling the listen({}) method.
To self-observe, when the listen() method is called (specifying a block to execute), the observer returned is held in the object until unlisten() is called, which will then call removeObserver: for you.
There is also a deinit() that calls unlisten() as well. Unfortunately, I get no evidence that this is ever called. So manual unlisten() calls are needed. C++ has a nice pattern, based on destructor calls, called RUII for Resource Usage Is Initialization (I think). Won't work in Swift if deinit() never gets called.
The unlisten() calls therefore need to be made when the NavigationController stack is popped (back or save buttons, for example). I am unsure how to do this, and will check this out. There does not seem to be a view{Will|Did}Unload() method on any view controller, which would be ideal. And as mentioned, deinit() never seems to be called. Is this an ARC problem, i.e. memory cycles? I don't know yet.
There is also a need to call unlisten() and listen() during app life cycle events. For this, a notification system would be ideal, but we're trying to shut it off. Hmmm...I guess we need a list of active objects that we can call unlisten and listen on for these events. This can be at the class/static level (once Swift 1.2 comes out - this summer?), and we can use the Singleton Trick (see GoldenPythagData.swift) until then.
*/

// The types of notifications
enum GPNotificationType {
    case None // disabled for broadcasting
    // individual object notifications
    case Market, MarketLocation, Prediction, Pivot, PivotList
    // model level notifications: list data
    case MarketList, MarketLocationList, PredictionList, PivotListList
    // model level notifications: selections
    case MarketSelection//, PivotListSelection
}

// Simple Notification system (model "radio station")
class GPNotification : Printable {
    private var _type: GPNotificationType
    private var observer : AnyObject?
    private var debug : Bool {
        return true // turn on debug printouts; no storage in object required:)
    }
    
    init(type: GPNotificationType) {
        _type = type;
    }

    // convenience init to automatically broadcast the new object (could be temporary)
    init(broadcast type: GPNotificationType) {
        _type = type;
        broadcast()
    }

    // IMPORTANT: if still observing at deinit time, unlisten to remove the observer
    deinit {
        unlisten()
    }
    
    var type : GPNotificationType {
        return _type
    }
    
    var name : String {
        let header = "GPNotify:"
        switch _type {
        case .Market: return header + "Market"
        case .MarketLocation: return header + "MarketLocation"
        case .Prediction: return header + "Prediction"
        case .Pivot: return header + "Pivot"
        case .MarketList: return header + "MarketList"
        case .MarketLocationList: return header + "MarketLocationList"
        case .PredictionList: return header + "PredictionList"
        case .PivotList: return header + "PivotList"
        case .PivotListList: return header + "PivotListList"
        case .MarketSelection: return header + "MarketSelection"
            //case .PivotListSelection: return header + "PivotListSelection"
        default: return header + "None"
        }
    }
    // Printable conformance
    var description : String {
        return name
    }
    
    func broadcast() {
        if _type != .None {
            if debug { println("Sent \(self)") }
            NSNotificationCenter.defaultCenter().postNotificationName(name,
                object: nil)
        }
    }
    
    // recommend to do this in viewDidAppear() or viewWillAppear()
    // save the return value to pass to unlistenFor: later
    func listen(completion: (NSNotification!) -> Void) {
        if _type != .None {
            if debug { println("Awaiting \(self)") }
            observer = NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: completion)
        }
    }
    
    // recommend to do this in viewWillDisappear() or viewDidDisappear()
    // pass the object returned from the above call to listenFor:completion:
    func unlisten() {
        if observer != nil {
            if debug { println("Unawaiting \(self)") }
            NSNotificationCenter.defaultCenter().removeObserver(observer!)
            observer = nil
        }
    }
    
    class func unlistenAll() {
        // to be called in app lifecycle when going to background
    }
    
    class func listenAll() {
        // to be called in app lifecycle when reviving from background
        // TBD: NEED TO KEEP ALL THE BLOCKS AROUND AFTER ALL - or ... ??
    }
}

