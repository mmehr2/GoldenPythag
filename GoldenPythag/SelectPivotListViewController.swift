//
//  SelectPivotListViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/3/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

class SelectPivotListViewController: GoldenPythagTableViewController {

    private var editedIndexPath : NSIndexPath?
    private var selectedMarket : Market? // for new item; not necessarily == model.currentMarket
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // listen for change notifications for the market selection to update filtering
        observerForMarketSel.listen { (_) in
            self.tableView.reloadData()
            self.updateUI()
        }
        // listen for change notifications for the item list to trigger VC updates
        observerForPLList.listen { (_) in
            //self.tableView.reloadData()
            self.updateUI()
        }
        observerForPivotList.listen { (_) in
            //when the individual item has been edited, reload its cell
            self.updateEditedCell()
        }
        updateUI()
    }
    
    func updateUI() {
        // refresh the subtitle (prompt)
        navigationItem.prompt = getStandardListDescription(model.filteredPivotLists)
        // disable edit button whenever item count is 0
        enableEditButton(model.filteredPivotLists.count != 0)
    }
    
    func updateEditedCell() {
        if let ip = editedIndexPath {
            tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: .Automatic)
        }
    }

    // MARK: UI for add button
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        // if market globally selected, just use this as the market for the new PL
        let segueIdentifier = "Add Pivot List Segue"
        if model.currentMarket != nil {
            selectedMarket = model.currentMarket
            // perform the segue immediately
            performSegueWithIdentifier(segueIdentifier, sender: nil)
        } else {
            // if no market selected, run modal alert to get market selection for this PL only
            // segue will happen after user makes a choice that isn't Cancel
            runSelectMarketAlertFor(segueIdentifier)
        }
    }
    
    private func runSelectMarketAlertFor(segueIdentifier: String) {
        // select market from list (decorated with global selection, if any)
        let ac = UIAlertController(title: "Select Market", message: "You must select a market to use for the new price list.", preferredStyle: .Alert)
        for item in model.markets {
            var titleDecor = ""
            if let currentMarket = model.currentMarket {
                titleDecor = currentMarket.id  == item.id ? " (selected)" : ""
            }
            let act = UIAlertAction(title: item.name + titleDecor, style: .Default) { (_) in
                self.selectedMarket = self.model.getMarketWithID(item.id)
                // now we are ready to perform the segue to add market info
                self.performSegueWithIdentifier(segueIdentifier, sender: nil)
            }
            ac.addAction(act)
        }
        // NOTE: allMarkets is NOT an option here - we need a selection
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            // nothing (will not change selection or perform segue)
        }
        ac.addAction(cancel)
        // TBD: error - completion block executes immediately - figure it out later
        presentViewController(ac, animated: true, completion: nil)
    }
    
    // MARK: Model observer
    private var observerForMarketSel = GPNotification(type: .MarketSelection)
    
    private var observerForPLList = GPNotification(type: .PivotListList)
    
    private var observerForPivotList  = GPNotification(type: .PivotList)
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        // remove all observers before we could be deallocated
//        observerForMarketSel.unlisten()
//        observerForPLList.unlisten()
//        observerForPivotList.unlisten()
//    }

//    override func willMoveToParentViewController(parent: UIViewController?) {
//        if parent == parentViewController {
//            // we are popping back to our parent VC
//            println("popping back to parent")
//            observerForMarketSel.unlisten()
//            observerForPLList.unlisten()
//            observerForPivotList.unlisten()
//        }
//    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return section == 0 ? model.filteredPivotLists.count : 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Pivot List Cell", forIndexPath: indexPath) 

        // Configure the cell...
        let pl = model.filteredPivotLists[indexPath.row]
        let market = model.getMarketWithID(pl.marketId)!
        cell.textLabel?.text = pl.standardName
        cell.detailTextLabel?.text = getStandardPLDescription(pl)

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            // TBD: A possible UI Alert to ask the user if they are sure they want to delete
            // NOTE: This is a single item delete without cascade, since no items are dependent on
            //   PL's; the prediction runs contain snapshots of the pivot data, but are not associated
            //   with the actual PL object after the request is made.
            
            // get the unfiltered index of the item to delete
            let index = model.getUnfilteredPivotListIndex(indexPath.row)
            model.pivotLists.removeAtIndex(index!)
            // then delete the row from the table view
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // if the last visible item was deleted, also clear the editing state of the VC
            if model.filteredPivotLists.count == 0 {
                setEditing(false, animated: true)
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            // MLM - not supported at this time
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

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        if segue.identifier == "Show Pivot List Segue" {
            if let dvc = segue.destinationViewController as? SelectPivotViewController {
                if let cell = sender as? UITableViewCell {
                    let indexPath = tableView.indexPathForCell(cell)!
                    // find which data item is represented by the filtered row chosen
                    let dataItem = model.getUnfilteredPivotListItem(indexPath.row)
                    // Pass the selected object to the new view controller.
                    dvc.setPivotList( dataItem! )
                    // remember which row is being edited to allow updates
                    editedIndexPath = indexPath
                }
            }
        }
        if segue.identifier == "Add Pivot List Segue" {
            if let dvc = segue.destinationViewController as? ChangePivotListInfoViewController {
                // NOTE: due to design of + button to only programmatically segue, we are guaranteed to have a market selection before we start here
                // find which data item is represented by the filtered row chosen
                let dataItem = PricePivotList(ID: PricePivotList.getNextID(), market: selectedMarket!)
                // Pass the selected object to the new view controller.
                dvc.pivotList = dataItem
                dvc.adding = true
                // there is no edited index path here yet (until we implement .Insert properly)
                editedIndexPath = nil
            }
        }
    }
    

}
