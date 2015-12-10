//
//  GoldenPythagTableViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/3/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

/*
This is the custom base class for all TableView Controllers used in the app.
*/

struct Settings {
    static let runLengthRange = 1...30
    static let simulatedResultTimer = 5...10
    static let dateOfExpiration = getRandomDateFrom( -10, to: +60) // days from now
}

// MARK: GLOBAL FUNCTIONS
// TBD: probably need to use specific locales for diff.USD,GBP,JPY usage - or should I??
func getPriceFromFormattedString(input: String) -> Price {
    let nf = NSNumberFormatter()
    nf.numberStyle = .CurrencyStyle
    return nf.numberFromString(input) ?? 0.0
}

func getFormattedStringFromPrice(input: Price) -> String {
    let nf = NSNumberFormatter()
    nf.numberStyle = .CurrencyStyle
    return nf.stringFromNumber(input) ?? ""
}

// TBD: probably need to use specific locales for diff.date usage - or should I??
func getDateFromFormattedString(input: String) -> NSDate {
    let nf = NSDateFormatter()
    nf.dateStyle = .MediumStyle
    nf.timeStyle = .NoStyle
    return nf.dateFromString(input) ?? NSDate()
}

func getFormattedStringFromDate(input: NSDate) -> String {
    let nf = NSDateFormatter()
    nf.dateStyle = .MediumStyle
    nf.timeStyle = .NoStyle
    return nf.stringFromDate(input) ?? ""
}

func getStandardPLDescription( pl: PricePivotList ) -> String {
    let model = GoldenPythag.modelData
    let market = model.getMarketWithID(pl.marketId)!
    //let plName = pl.name - NOT used here
    var plDescription = ""
    if let (minDate, maxDate) = pl.minMaxDate() {
        plDescription =  "\(pl.pivotList.count) prices from \(getFormattedStringFromDate(minDate)) to \(getFormattedStringFromDate(maxDate))"
    } else {
        plDescription =  "0 prices"
    }
    let dispText = "\(market.name): \(plDescription)"
    return dispText
}

func getStandardListDescription( items: [AnyObject] ) -> String {
    let model = GoldenPythag.modelData
    let caption = items.count == 1 ? "item" : "items"
    if let marketName = model.currentMarket?.name {
        return "\(marketName): \(items.count) \(caption)"
    } else {
        return "\(items.count) \(caption)"
    }
}

func getStandardPredictionDescription( item: Prediction ) -> String {
    let model = GoldenPythag.modelData
    let market = model.getMarketWithID(item.marketId)?.name ?? "INVALID"
    return "Type \(item.type) run of \(market) market for \(item.lengthInDays) days from \(getFormattedStringFromDate(item.startDate)) (\(item.state) with \(item.pivotData.count) prices and \(item.resultList.count) results)"
}

// MARK - class GoldenPythag TVC
class GoldenPythagTableViewController: UITableViewController {
    
    var model = GoldenPythag.modelData
    
    var beingDisplayed : Bool {
        // if we are the top item on the navigation controller's stack, we're being displayed
        // returns false if we don't have a navigationController item set (UNSUPPORTED USE CASE)
        return navigationController?.topViewController == self ?? false
    }
    
    private var simulatedResultsTimer : NSTimer?
    
    private var savedTitle : String? // initialize to title in viewDidLoad()
    var screenTitle : String? {
        get {
            return title
        }
        set {
            let scrTitle = newValue == nil || newValue == "" ? savedTitle! : "\(savedTitle!) \(newValue!)"
            title = scrTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        //clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // add the edit button to whatever single button the storyboard nav controller has
        navigationItem.rightBarButtonItems?.append(editButtonItem())
    //    navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems?.reverse().flatMap({ $0 }) // the 1st item is leftward of the 2nd
        
        // need to set the title
        navigationItem.title = title
        // and save it for decorated title feature
        savedTitle = title
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // unhide the toolbar for this VC's NC if we are the root VC
        navigationController?.toolbarHidden = false //(self == navigationController?.viewControllers.first as GoldenPythagTableViewController)
    }
    
    // non-Model code used by multiple VC children can be shared here
    func enableEditButton(enabled: Bool) {
        if let eb = navigationItem.rightBarButtonItems?.last {
            eb.enabled = enabled
        }
    }

    func schedulePredictionRequest(rq: Prediction, forResponder rsp: GoldenPythagTableViewController) -> Bool {
        // DEMO VERSION: start a timer to trigger random results
        let seconds = NSTimeInterval(getRandomFrom(Settings.simulatedResultTimer.startIndex, to: Settings.simulatedResultTimer.endIndex))
        //println("started simulated results timer for \(seconds) seconds")
        // set the network activity indicator ON here
        simulatedResultsTimer = NSTimer.scheduledTimerWithTimeInterval(seconds, target: rsp, selector: "receivedResults:", userInfo: rq, repeats: false)
        // NOTE: The completion needs to use the prediction id to get the prediction and call setRandomResults() on it, as well as triggering the badge feature
        // TBD: real world would trigger a background thread to send the request to the server
        return true
    }
    
    func receivedResults(timer: NSTimer) {
        if let request = timer.userInfo as? Prediction {
            // set the network activity indicator OFF here
            request.setRandomResults(NSDate())
        }
    }
    
    // this doesn't seem to work when called from the child.. oh well scrap it!
//    func reload(theTableView: UITableView, titleForHeaderInSection section: Int) {
//        // refresh the section title (lacks size info and is hackish; see:
//        // http://stackoverflow.com/questions/1586420/changing-uitableview-section-header-without-tableviewtitleforheaderinsection
//        if var sectionText = theTableView.headerViewForSection(section)?.textLabel.text {
//                sectionText = tableView(theTableView, titleForHeaderInSection: section)!
//        }
//    }
    
    // MARK: Table view delegate
    // this is required for deletion behavior on children
    // does not support .Insert by default (child can override)
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
