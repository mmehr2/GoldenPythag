//
//  SelectMarketViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/1/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

class SelectMarketViewController: GoldenPythagTableViewController {
    
    private var editedIndexPath : NSIndexPath?

    private let numDefaultMarkets = Market.GetNumDefaults()
    private var numCustomMarkets : Int {
        return (model.markets.count - numDefaultMarkets)
    }
    
    private func indexForIndexPath(path: NSIndexPath) -> Int {
        return path.section * numDefaultMarkets + path.row
    }
    
    private func indexPathForIndex(index: Int) -> NSIndexPath {
        let row = index < numDefaultMarkets ? index : index - numDefaultMarkets
        let section = index < numDefaultMarkets ? 0 : 1
        return NSIndexPath(forRow: row, inSection: section)
    }
    
    // MARK: Model observer
    private var observerForMarketSel = GPNotification(type: .MarketSelection)
    
    private var observerForMarketList = GPNotification(type: .MarketList)
    
    private var observerForMarket  = GPNotification(type: .Market)

    override func viewDidLoad() {
        super.viewDidLoad()
        // listen for change notifications for the market selection to update filtering
        observerForMarketSel.listen { (_) in
            self.tableView.reloadData()
            self.updateUI()
        }
        // listen for change notifications for the item list to trigger VC updates
        observerForMarketList.listen { (_) in
            //self.tableView.reloadData()
            self.updateUI()
        }
        observerForMarket.listen { (_) in
            //when the individual item has been edited, reload its cell
            self.updateEditedCell()
        }
        updateUI()
    }
    
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        // remove all observers before we could be deallocated
//        observerForMarketSel.unlisten()
//        observerForMarketList.unlisten()
//        observerForMarket.unlisten()
//    }
// NOTE: this will never happen
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // if we are no longer in the NC's stack of VC's, back button has been pressed!
        if let vcs = navigationController?.viewControllers {
            if (vcs as NSArray).indexOfObject(self) == NSNotFound {
                // NOTE: this will never happen as long as we are the top of the NC's stack (current design)
                println("SMVC back button pressed!")
            }
        }
    }

    // MARK: user interface
    @IBAction func selectMarket(sender: UIBarButtonItem) {
        // figure out which row is currently selected, if any
        if let indexPath = tableView.indexPathForSelectedRow() {
            // set the model's currentMarket to the market at the selected row
            // NOTE: section 0 is all defaults, 1 is all custom markets, so we need a func
            //   to convert the indexPath to a combined row to index the markets table
            let index = indexForIndexPath(indexPath)
            let market = model.markets[index]
            model.currentMarket = market
            //let secType = indexPath.section == 0 ? "default" : "custom"
            //println("Selected \(secType) market \(market.name) at row \(index)")
        } else {
            model.currentMarket = nil
            //println("No row selected, market selection removed.")
        }
        //tableView.reloadData()
        //println("\(model.markets.count) markets")
    }
    
    func updateUI() {
        // refresh the subtitle (prompt)
        navigationItem.prompt = getStandardListDescription(model.markets)
        // disable edit button whenever item count is equal to the default
        enableEditButton(model.markets.count > numDefaultMarkets)
    }
    
    func updateEditedCell() {
        if let ip = editedIndexPath {
            tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: .Automatic)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return section == 0 ? numDefaultMarkets : numCustomMarkets
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = indexPath.section == 0 ? "Default Market Cell" : "Custom Market Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        let market = model.markets[indexForIndexPath(indexPath)]
        let name = market.name
        let selected = (market.id == model.currentMarket?.id) ?? false
        let selstr = selected ? " (selected)" : ""
        cell.textLabel?.text = "\(name)\(selstr)"

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        // section 1 (#0) is for default markets, non-editable
        // section 2 (#1) is for user's own custom markets
        return indexPath.section == 0 ? false : true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return indexPath.section == 0 ?  .None : .Delete
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // TBD: First, we need to ascertain some facts:
            //   1. how many price pivot lists use this market
            //   2. how many predictions used this market (esp.if in progress)
            // Then we need to ask the user (via Alert controller) whether they
            //   really want to cascade that delete to N PL's and M prediction runs.
            // Finally, if the user says Yes, we need to do the full cascaded delete
            //   of the PLs and the predictions BEFORE we delete the (custom) market
            // In case of a No answer we may want to clean up the UI (editing etc)
            // END OF TBD SECTION
            
            // Delete the row from the data source
            // first, get the index, and compare the deletion candidate to the selected market
            let index = indexForIndexPath(indexPath)
            // if this was also the currently selected market, remove the selection
            if model.markets[index].id == model.currentMarket?.id {
                model.currentMarket = nil
                //println("removed current market selection")
            }
            // perform the model deletion
            //println("removed market \(model.markets[index].name) at row \(index)")
            model.markets.removeAtIndex(index)
            // also perform the UI deletion
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // if the last item was deleted, also clear the editing state of the VC
            if model.markets.count == numDefaultMarkets {
                setEditing(false, animated: true)
                //println("removed editing state (deleted last editable item)")
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
        // Pass the selected object to the new view controller.
        if segue.identifier == "Add Custom Market Segue" {
            if let dvc = segue.destinationViewController as? ChangeMarketViewController {
                // create a new object of the Custom Market type
                // pass it to the editor dvc
                dvc.market = CustomMarket(ID: CustomMarket.getNextID())
                dvc.adding = true // set editor behavior for Add (new object)
            }
        } else if segue.identifier == "Edit Custom Market Segue" {
            if let dvc = segue.destinationViewController as? ChangeMarketViewController {
                // fetch the existing object of the Custom Market type
                if let cell = sender as? UITableViewCell {
                    let indexPath = tableView.indexPathForCell(cell)!
                    // pass it to the editor dvc
                    dvc.market = model.markets[indexForIndexPath(indexPath)] as! CustomMarket
                    dvc.adding = false // set editor behavior for Edit (existing object)
                    // remember which row is being edited to allow updates
                    editedIndexPath = indexPath
               }
            }
        }
    }
    
}
