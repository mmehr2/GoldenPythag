//
//  RequestPredictionViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/5/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

// this is a TVC with static data cells to control parameters for a prediction request

/* NOTE: using static cells with autolayout in iOS8 has a new issue, detailed here: http://stackoverflow.com/questions/25902288/detected-a-case-where-constraints-ambiguously-suggest-a-height-of-zero/26359823#26359823
The error generated is such:
2015-03-12 20:55:39.384 GoldenPythag[6767:159447] Warning once only: Detected a case where constraints ambiguously suggest a height of zero for a tableview cell's content view. We're considering the collapse unintentional and using standard height instead.
The solution: always make sure you have enough constraints attaching to all cell edges nearby: top, _bottom_, left, and right
*/

class RequestPredictionViewController: GoldenPythagTableViewController {
    
    var request : Prediction!
    var respondTo : GoldenPythagTableViewController?
    private var rqPivotList : PricePivotList? // prices have to come from somewhere
    
//    private var savedTitle : String? // initialize to title in viewDidLoad()
//    var screenTitle : String? {
//        get {
//            return title
//        }
//        set {
//            let scrTitle = newValue == nil || newValue == "" ? savedTitle! : "\(savedTitle!) \(newValue!)"
//            title = scrTitle
//        }
//    }

    // MARK: - IB outlets
    @IBOutlet weak var runTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var currentMarketLabel: UILabel!
    @IBOutlet weak var currentPriceListLabel: UILabel!
    @IBOutlet weak var startingDateLabel: UILabel!
    @IBOutlet weak var runLengthLabel: UILabel!
    @IBOutlet weak var endingDateLabel: UILabel!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    @IBOutlet weak var daysSlider: UISlider!

    // MARK: IB actions
    @IBAction func saveRequest(sender: UIBarButtonItem) {
        // step 1: assign the prediction ID in use
        let pid = Prediction.assignID()
        // step 2: set the request state to .InProgress [with an appropriate message (OPT)]
        request.state = .InProgress
        // turn on notifications of state changes for this object (after this state change)
        request.notifying = true
        // step 3: shut off notifications for the pivot list data, if any
        if rqPivotList != nil {
            rqPivotList!.notifying = false
            // TBD: we also need to do this for the cancel button.. hmmm
        }
        // step 4: add the request to the model master list
        model.predictions.append(request)
        // step 5: schedule the prediction request to go to the server
        if let rvc = respondTo {
            // NOTE: this should work, since our RVC is the Predictions master list VC
            // we need an object that doesn't immediately go away (self) to be around for the response
            schedulePredictionRequest(request, forResponder: rvc)
        }
        // last step: pop VC off NC stack
        navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func selectMarket(sender: AnyObject) {
        // sets the market SELECTION (used for global list filtering)
        let m = model.currentMarket
        let ac = UIAlertController(title: "Select Market", message: nil, preferredStyle: .ActionSheet)
        for item in model.markets {
            let act = UIAlertAction(title: item.name, style: .Default) { (_) in
                self.model.currentMarket = self.model.getMarketWithID(item.id)
                self.updateUI() // should NOT be required, but see error TBD
            }
            ac.addAction(act)
        }
        let allMarkets = UIAlertAction(title: "All Markets", style: .Default) { (_) in
            self.model.currentMarket = nil
            self.updateUI() // should NOT be required, but see error TBD
        }
        ac.addAction(allMarkets)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            // nothing
        }
        ac.addAction(cancel)
        // TBD: error - completion block executes immediately - figure it out later
        presentViewController(ac, animated: true, completion: updateUI)
    }
    
    @IBAction func selectPivotList(sender: AnyObject) {
        // selects the pivot list, which contains the market to use for the request itself
        let ac = UIAlertController(title: "Select Price List", message: nil, preferredStyle: .ActionSheet)
        for item in model.filteredPivotLists {
            let act = UIAlertAction(title: item.standardName, style: .Default) { (_) in
                self.setAndTrackPivotList(item)
                self.request.marketId = item.marketId
                self.request.pivotData = item.pivotList
                self.updateUI() // should NOT be required, but see error TBD
            }
            ac.addAction(act)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            // nothing
        }
        ac.addAction(cancel)
        // TBD: error - completion block executes immediately - figure it out later
        presentViewController(ac, animated: true, completion: updateUI)
    }
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        if let rq = request {
            let oldDate = rq.startDate
            rq.startDate = sender.date
            if !validStartDate {
                rq.startDate = oldDate
            }
        }
        updateUI()
    }
    
    @IBAction func typeSegmentTouched(sender: UISegmentedControl) {
        // set the run type from the control
        let index = runTypeSegmentedControl.selectedSegmentIndex
        if validType {
            request.type = PredictionType(rawValue: index)!
            //println("requested type set to \(request.type)=\(request.type.rawValue)")
        } else {
            //println("no selected segment")
        }
        updateUI()
    }
    
    @IBAction func daysSliderChanged(sender: UISlider) {
        if let rq = request {
            rq.lengthInDays = Int(sender.value)
        }
        updateUI()
    }

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // save the title for screenTitle feature
//        savedTitle = title
        // since we are using static cells, remove the Edit button added by super
        navigationItem.rightBarButtonItems?.removeLast()
        // no initial segment unless the model says so
        runTypeSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        // set the days slider limits
        daysSlider.minimumValue = Float(Settings.runLengthRange.startIndex)
        daysSlider.maximumValue = Float(Settings.runLengthRange.endIndex)
        // listen for changes to pivot list data we might be tracking
        observer.listen { (_) in
            // update pivot data in request accordingly
            self.request!.pivotData = self.rqPivotList!.pivotList
        }
        updateUI()
    }
    
    // MARK: Model observer
    private var observer  = GPNotification(type: .PivotList)
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        observer.unlisten()
//    }

    private func setAndTrackPivotList( pl: PricePivotList ) {
        if rqPivotList != nil {
            rqPivotList!.notifying = false
        }
        rqPivotList = pl
        if rqPivotList != nil {
            rqPivotList!.notifying = true
        }
    }
    
    // MARK: UI validation properties
    private var validType : Bool {
        return runTypeSegmentedControl.selectedSegmentIndex != UISegmentedControlNoSegment
    }
    private var validMarket : Bool {
        return request?.marketId != nil
    }
    private var validPivots : Bool {
        return rqPivotList != nil
    }
    private var validStartDate : Bool {
        // TBD: eventually this should check that start date is not beyond user's subscription expiration date
        return request?.startDate != nil
    }
    private var validLengthInDays : Bool {
        // TBD: eventually this should also check that end date (start+lengthInDays) is not beyond user's subscription expiration date
        return request != nil && request.lengthInDays >= Settings.runLengthRange.startIndex && request.lengthInDays <= Settings.runLengthRange.endIndex
    }
    private var validUI : Bool {
        return validType && validMarket && validPivots && validStartDate && validLengthInDays
        // be sure to && all other valiation bools
    }

    func updateUI() {
        // send model values to screen, if validated
        // BAD - WRONG USE OF VALIDATION, SHOULD GO OTHER WAY (WHEN POPULATING MODEL FROM SCREEN UI)!!
        if let rq = request {
            // set the screen title depending on market selection
            if let mkn = model.currentMarket?.name {
                screenTitle = "for \(mkn)"
            } else {
                screenTitle = nil
            }
            // set the run type control
            runTypeSegmentedControl.selectedSegmentIndex = rq.type.rawValue
            // set the market selection label
            if validMarket {
                currentMarketLabel.text = model.getMarketWithID(request.marketId!)?.name
            } else {
                currentMarketLabel.text = "Please select a Price List to use"
            }
            // set the price list selection label
            if validPivots {
                currentPriceListLabel.text = rqPivotList!.standardName
            } else {
                currentPriceListLabel.text = "Please select a Price List to use"
            }
            // set the start date and all its related UI (length, end)
            if validStartDate {
                startingDateLabel.text = NSDateFormatter.localizedStringFromDate(rq.startDate, dateStyle: .MediumStyle, timeStyle: .NoStyle)
                if !validLengthInDays {
                    rq.lengthInDays = Settings.runLengthRange.endIndex / 2 // need a default
                    // TBD: may have to adjust length back, depending on user's subscription expiration date
                }
                // set the day slider current value and its associated label
                daysSlider.enabled = true
                daysSlider.value = Float(rq.lengthInDays)
                runLengthLabel.text = "\(rq.lengthInDays) days"
                endingDateLabel.text = NSDateFormatter.localizedStringFromDate(rq.endDate, dateStyle: .MediumStyle, timeStyle: .NoStyle)
            } else {
                currentPriceListLabel.text = "Date is beyond subscription expiration."
                daysSlider.enabled = false
            }
        }
        saveButtonItem.enabled = validUI
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
