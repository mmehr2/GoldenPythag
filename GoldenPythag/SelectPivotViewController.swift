//
//  SelectPivotViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/5/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

class SelectPivotViewController: GoldenPythagTableViewController, UINavigationControllerDelegate {
    
    private var editedIndexPath : NSIndexPath?
    private var readOnly = false
    private var disabledBack = false
    private var pivotList : PricePivotList? // this must be valid when !readOnly
    private var pivotData : [PricePivot]? // this must be valid when readOnly
    private var pivots : [PricePivot]! {
        get {
            return readOnly ? pivotData! : pivotList!.pivotList
        }
        set {
            if readOnly {
                //pivotData! = newValue // should not happen, violates readOnly mode
                print("Attempt to set pivotData violates readOnly mode of SPVC!")
            } else {
                pivotList!.pivotList = newValue
            }
        }
    }

    // MARK: Public interface (for segueing VC)
    func setPivotList( list: PricePivotList, enableBack: Bool = true ) {
        pivotList = list
        pivotData = nil
        readOnly = false
        // special case if we should not return to caller (TBD: questionable design)
        disabledBack = !enableBack
    }
    
    func setPivotData( list: [PricePivot] ) {
        pivotList = nil
        pivotData = list
        readOnly = true
    }

    // MARK: UI setup and refresh
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        title = readOnly ? "Prices" : pivotList!.standardName
        // in read-only mode, there are no edit or add buttons
        if readOnly {
            navigationItem.rightBarButtonItems = []
        }
        // set code to update UI when pivotList changes (RW only)
        if !readOnly {
            pivotList!.notifying = true
            observer.listen { (_) in
                //self.tableView.reloadData()
                self.updateUI()
            }
            observerForPivot.listen { (_) in
                //when the individual item has been edited, reload its cell
                self.updateEditedCell()
            }
        }
        // hide the toolbar when pushed in readOnly mode (DOES NOT WORK!)
        navigationController?.toolbarHidden = readOnly
        // also hide the bottom bar (with the tabBarItems on it) in readOnly mode
        hidesBottomBarWhenPushed = readOnly // BUT DOES NOT WORK (yet)
        //println("SPVC:viewDidLoad()")
        updateUI()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    @IBOutlet weak var infoButtonItem: UIBarButtonItem!
    
    func updateUI() {
        // refresh the subtitle (prompt)
        if !readOnly {
            navigationItem.prompt = getStandardPLDescription(pivotList!)
        }
        // our back button can be optionally disabled (TBD- NOT WORKING YET!)
        navigationItem.leftBarButtonItem?.enabled = !disabledBack
        //println("SPVC:updateUI()")
        // disable edit button whenever item count is 0
        enableEditButton(pivots.count != 0)
        // hide Info button in readOnly mode (TBD: can't hide them? just disable it for now)
        infoButtonItem.enabled = !readOnly
    }
    
    func updateEditedCell() {
        if let ip = editedIndexPath {
            tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: .Automatic)
        }
    }
    
    // MARK: Model observer
    private var observer  = GPNotification(type: .PivotList)
    private var observerForPivot  = GPNotification(type: .Pivot)
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        // if we are no longer in the NC's stack of VC's, back button has been pressed!
//        if let vcs = navigationController?.viewControllers {
//            if (vcs as NSArray).indexOfObject(self) == NSNotFound {
//                //println("back button pressed!")
//                if !readOnly {
//                    pivotList!.notifying = false  ///// **** HMMMM needed???? don't think so ...
//                    observer.unlisten()
//                }
//            }
//        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return section == 0 ? pivots.count : 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = readOnly ? "ReadOnly Pivot Cell" : "Pivot Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) 

        // Configure the cell...
        cell.textLabel?.text = describePivot(pivots[indexPath.row])

        return cell
    }

    func describePivot( pivot: PricePivot ) -> String {
        let topStr = pivot.top ? " Top " : " Bot "
        let result = getFormattedStringFromPrice(pivot.price) + topStr + getFormattedStringFromDate(pivot.date)
        return result
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            pivots.removeAtIndex(indexPath.row)
            // Then delete the row in the tableView
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // If the last editable item is gone now, shut off editing mode
            if pivots.count == 0 {
                setEditing(false, animated: true)
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - suggested new pivot from old
    private func suggestNewPivotForPivotList( list: PricePivotList, atIndex: Int? = nil) -> PricePivot {
        var nextTop: Bool = false
        var nextDate: NSDate = NSDate()
        var nextPrice: Price = 0.0
        // criteria: if PL has any pivotList data,
        //  if no index given, assume end, else assume we are adding at/after given index
        //  the provided index must be in the valid range of 0..<list.pivotList.count
        let maxIndex = list.pivotList.count - 1 // -1 if list is empty
        var givenIndex = maxIndex
        if let atx = atIndex {
            if atx >= 0 && atx <= maxIndex {
                givenIndex = atx
            }
        }
        var givenPivot: PricePivot? = givenIndex >= 0 ? list.pivotList[givenIndex] : nil

        //  new top should be set to opposite of given pivot's top
        //  if no given pivot, top should be randomly set 50-50 either way
        nextTop = !(givenPivot?.top ?? getRandomBool())
        
        //  new date should be set after auto-advance time interval from given pivot's date
        // if no given pivot, set date to now
        let autoAdvanceDays = 7 // get this from a setting
        nextDate = givenPivot?.date.addDays(autoAdvanceDays) ?? NSDate()
        
        // new price should go be set same as price of pivot before pivot at index, if any, else use a default price
        // default price can be some multiplier times price of pivot at given index, added to (bot) or subtracted from (top) given pivot's price
        // if neither pivot exists (1st add to empty list), use a random price in range to go with top/btm (NOT PRODUCTION WORTHY) **OR**
        // keep a running average price pair (tops/bottoms) per user's market and look up
        if let gpiv = givenPivot {
            let defaultPivotSwingPercent = 20.0 // as +ve %, get this from a setting
            let defaultPriceFractionUp = (100.0 + defaultPivotSwingPercent) / 100.0
            let defaultPriceFractionDown = (100.0 - defaultPivotSwingPercent) / 100.0
            let defaultPriceFraction = nextTop ? defaultPriceFractionDown : defaultPriceFractionUp
            nextPrice = gpiv.price.doubleValue * defaultPriceFraction
        }
        let earlierIndex = givenIndex - 1
        givenPivot = earlierIndex >= 0 ? list.pivotList[earlierIndex] : nil
        nextPrice = givenPivot?.price ?? nextPrice
        
        let pivot = PricePivot(date: nextDate, price: nextPrice, top: nextTop)
        return pivot
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "Change Pivot List Info Segue" {
            if let dvc = segue.destinationViewController as? ChangePivotListInfoViewController {
                dvc.pivotList = pivotList! // only allow this segue when we are RW
                dvc.adding = false // editing an existing list
            }
        }
        else if segue.identifier == "Add Pivot Segue" {
            if let dvc = segue.destinationViewController as? ChangePivotViewController {
                // create a pivot
                let pivot = suggestNewPivotForPivotList(pivotList!)
                // pass the new pivot to the editor for changes
                dvc.pivot = pivot // only allow this segue when we are RW
                // set code to add it to our pivotList's data list if user presses Save
                dvc.saver = { (pivotAsEdited) in self.pivotList!.pivotList.append(pivotAsEdited) }
                // there is no edited index path here yet (until we implement .Insert properly)
                editedIndexPath = nil
            }
        }
        else if segue.identifier == "Edit Pivot Segue" {
            if let dvc = segue.destinationViewController as? ChangePivotViewController {
                if let cell = sender as? UITableViewCell {
                    let indexPath = tableView.indexPathForCell(cell)!
                    let row = indexPath.row
                    // pass the existing pivot to the editor for changes
                    dvc.pivot = pivotList!.pivotList[row] // only allow this segue when we are RW
                    // set code to update it in our pivotList's data list if user presses Save
                    dvc.saver = { (pivotAsEdited) in self.pivotList!.pivotList[row] = pivotAsEdited }
                    // remember which row is being edited to allow updates
                    editedIndexPath = indexPath
                }
            }
        }
    }
    

}
