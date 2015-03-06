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

class GoldenPythagTableViewController: UITableViewController {

    var oldEditAction: Selector!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Uncomment the following line to preserve selection between presentations
        clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        let pbiAdd = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "doAdd:")
        let pbiEdit = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "doEdit:")
        let pbiEdit2 = editButtonItem()
//        oldEditAction = pbiEdit2.action
//        pbiEdit2.action = "doEdit:"
        navigationItem.rightBarButtonItems = [ pbiAdd, pbiEdit2 ]
        
        // need to set the title
        navigationItem.title = title
        
        // unhide the toolbar for this VC's NC
        navigationController?.toolbarHidden = false
    }
    
    @objc func doAdd(sender: AnyObject?) {
        println("added \(title)")
    }
    
    @objc func doEdit(sender: AnyObject?) {
        println("edited \(title)")
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
