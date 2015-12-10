//
//  PredictionViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/3/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

class PredictionViewController: GoldenPythagTableViewController {

    private var requestedID : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // listen for change notifications for the market selection to update filtering
        observerForMarketSel.listen { (_) in
            self.tableView.reloadData()
            self.updateUI()
        }
        // listen for change notifications for the prediction list to trigger VC updates
        observerForPredictionList.listen { (_) in
            //self.tableView.reloadData()
            self.updateUI()
        }
        // listen for state change notifications on the prediction itself to tell when it's done
        observerForPrediction.listen { (_) in
            //self.tableView.reloadData()
            self.updateRequestedCell()
        }
        updateUI()
    }
    
    // MARK: Model observer
    private var observerForMarketSel = GPNotification(type: .MarketSelection)
    
    private var observerForPredictionList = GPNotification(type: .PredictionList)
    
    private var observerForPrediction = GPNotification(type: .Prediction)
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        // remove all observers before we could be deallocated
//        observerForMarketSel.unlisten()
//        observerForPredictionList.unlisten()
//    }
    
    private func updateRequestedCell() {
        if let predictionID = requestedID {
            let row = model.findIndexOfPredictionWithID(predictionID)
            if let cellRow = row {
                // NOTE: only allows one request at a time for now
                // this should probably be an array of IPs, if we can tell the responses apart
                // or we can just update all at once; but how to tell which one to delete??
                let path = NSIndexPath(forRow: cellRow, inSection: 0)
                tableView.reloadRowsAtIndexPaths([path], withRowAnimation: .Automatic)
                requestedID = nil
            }
        }
    }

    // MARK: - update user interface
    func updateUI() {
        // refresh the subtitle (prompt)
        navigationItem.prompt = getStandardListDescription(model.filteredPredictions)
        // disable edit button whenever item count is 0
        enableEditButton(model.filteredPredictions.count != 0)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return section == 0 ? model.filteredPredictions.count : 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Prediction Cell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = getStandardPredictionDescription(model.filteredPredictions[indexPath.row])

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
            //   Predictions.
            
            // get the unfiltered index of the item to delete
            let index = model.getUnfilteredPredictionIndex(indexPath.row)
            model.predictions.removeAtIndex(index!)
            // then delete the row from the table view
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // if the last visible item was deleted, also clear the editing state of the VC
            if model.filteredPredictions.count == 0 {
                setEditing(false, animated: true)
                println("removed editing state (deleted last editable item)")
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
        if segue.identifier == "Add Prediction Segue" {
            if let dvc = segue.destinationViewController as? RequestPredictionViewController {
                // set up a scratch item to use for the prediction request
                // only use the next ID, don't assign it here (user could cancel)
                let pid = Prediction.getNextID()
                dvc.request = Prediction(ID: pid)
                dvc.respondTo = self
                // remember what request(s) to update when result comes back
                requestedID = pid
            }
        } else if segue.identifier == "Show Prediction Segue" {
            if let dvc = segue.destinationViewController as? DisplayPredictionViewController {
                if let cell = sender as? UITableViewCell {
                    let indexPath = tableView.indexPathForCell(cell)!
                    let dataItem = model.getUnfilteredPredictionItem(indexPath.row)
                    // Pass the selected object to the new view controller.
                    dvc.prediction = dataItem!
                }
            }
        }
    }
    

}
