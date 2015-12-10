//
//  SelectMarketLocationViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/5/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

class SelectMarketLocationViewController: GoldenPythagTableViewController {
    
    private var editedIndexPath : NSIndexPath?

    private let numDefaultMarketLocations = MarketLocation.GetNumDefaults()
    private var numCustomMarketLocations : Int {
        return (model.marketLocations.count - numDefaultMarketLocations)
    }
    
    private var selectedRow : Int?
    
    private func indexForIndexPath(path: NSIndexPath) -> Int {
        return path.section * numDefaultMarketLocations + path.row
    }
    
    private func indexPathForIndex(index: Int) -> NSIndexPath {
        let row = index < numDefaultMarketLocations ? index : index - numDefaultMarketLocations
        let section = index < numDefaultMarketLocations ? 0 : 1
        return NSIndexPath(forRow: row, inSection: section)
    }
    
    func setSelectedLocation( location: MarketLocation ) {
        // find index of provided location in marketLocations model array
        selectedRow = GoldenPythag.modelData.findMarketLocationIndex(location)
        // convert to index path
        if let row = selectedRow {
            let indexPath = indexPathForIndex(row)
            // set selected cell using index path
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        }
    }
    
    // MARK: Model observer
    private var observerForMarketLocationList = GPNotification(type: .MarketLocationList)
    
    private var observerForMarketLocation  = GPNotification(type: .MarketLocation)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // listen for change notifications for the item list to trigger VC updates
        observerForMarketLocationList.listen { (_) in
            //self.tableView.reloadData()
            self.updateUI()
        }
        observerForMarketLocation.listen { (_) in
            //when the individual item has been edited, reload its cell
            self.updateEditedCell()
        }
        updateUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        // if we are no longer in the NC's stack of VC's, back button has been pressed!
//        if let vcs = navigationController?.viewControllers {
//            if (vcs as NSArray).indexOfObject(self) == NSNotFound {
//                println("SMLVC back button pressed!")
//            }
//        }
    }
    
    func updateUI() {
        // refresh the subtitle (prompt)
        navigationItem.prompt = getStandardListDescription(model.markets)
        // disable edit button whenever item count is equal to the default
        enableEditButton(model.marketLocations.count > numDefaultMarketLocations)
    }
    
    func updateEditedCell() {
        if let ip = editedIndexPath {
            tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: .Automatic)
        }
    }

    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexForIndexPath(indexPath)
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return indexPath.section == 0 ?  .None : .Delete
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return section == 0 ? numDefaultMarketLocations : numCustomMarketLocations
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = indexPath.section == 0 ? "Default Market Location Cell" : "Custom Market Location Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) 
        
        // Configure the cell...
        cell.textLabel?.text = model.marketLocations[indexForIndexPath(indexPath)].name
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        // section 1 (#0) is for default markets, non-editable
        // section 2 (#1) is for user's own custom markets
        return indexPath.section == 0 ? false : true
    }

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let index = indexForIndexPath(indexPath)
            // Delete the row from the data source
            model.marketLocations.removeAtIndex(index)
            // remove the row in the table view
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // if we deleted the last editable item, shut off editing mode
            if model.marketLocations.count == numDefaultMarketLocations {
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
//        if segue.identifier == "Unwind Market Location Segue" {
//            if let dvc = segue.destinationViewController as? ChangeMarketViewController {
//                if let row = selectedRow {
//                    dvc.market.location = model.marketLocations[row]
//                }
//            }
//        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "Add Custom Market Location Segue" {
            if let dvc = segue.destinationViewController as? ChangeMarketLocationViewController {
                // create a new object of the Custom Market Location type
                // pass it to the editor dvc
                dvc.marketLocation = CustomMarketLocation(ID: CustomMarketLocation.getNextID())
                dvc.adding = true // set editor behavior for Add (new object)
                // remove any edited index so we don't respond to notifications
                editedIndexPath = nil
            }
        } else if segue.identifier == "Edit Custom Market Location Segue" {
            if let dvc = segue.destinationViewController as? ChangeMarketLocationViewController {
                // fetch the existing object of the Custom Market Location type
                if let cell = sender as? UITableViewCell {
                    let indexPath = tableView.indexPathForCell(cell)!
                    // pass it to the editor dvc
                    dvc.marketLocation = model.marketLocations[indexForIndexPath(indexPath)] as! CustomMarketLocation
                    dvc.adding = false // set editor behavior for Edit (existing object)
                    // remember which row is being edited to allow updates
                    editedIndexPath = indexPath
                }
            }
        }
    }
    

}
