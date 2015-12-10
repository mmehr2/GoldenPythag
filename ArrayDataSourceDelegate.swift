//
//  ArrayDataSourceDelegate.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/28/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

// this Data Source is entirely read-only or entirely read-write

class ArrayDataSourceDelegate<T> : NSObject, UITableViewDataSource, UITableViewDelegate
{
    var viewController: UITableViewController?
    var items: [T] = []
    var cellIdentifier: String!
    var configurator: ((T) -> String)!
    var readOnly = true
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return section == 0 ? items.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        cell.textLabel?.text = configurator(items[indexPath.row])
        
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return readOnly
    }
    
    
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if readOnly {
            return
        }
        if editingStyle == .Delete {
            // Delete the row from the data source
            items.removeAtIndex(indexPath.row)
            // Then delete the row in the tableView
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // If the last editable item is gone now, shut off editing mode
            if items.count == 0 {
                viewController?.setEditing(false, animated: true)
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
    
    
}
