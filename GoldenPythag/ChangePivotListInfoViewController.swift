//
//  ChangePivotListInfoViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/14/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit
/*
This controller is designed to edit just the Name and Notes fields of a provided PivotList.
Edits are only saved when the user presses the Save button, going back cancels all edits.
*/

class ChangePivotListInfoViewController: GoldenPythagTableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var pivotList : PricePivotList!
    var adding = false
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        // copy current UI settings into the edited object
        updateModel()
        // for new PLs, we move on to add prices, else just pop back to the caller VC
        if adding {
            // commit the ID of the object only in the case of adding a new one
            PricePivotList.assignID()
            // add the object to the model's master list
            model.pivotLists.append(pivotList)
            // and move to the VC that allows adding pivots to the new list
            performSegueWithIdentifier("Add Pivots Manual Segue", sender: self)
        } else {
            // for an existing PL, we just pop the NC's VC stack to move back to who called us
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // since we are using static cells, remove the Edit button added by super
        navigationItem.rightBarButtonItems?.removeLast()
        // turn on notifications for changes to the pivot list, if any (name esp.)
        pivotList.notifying = true
        // setup text editing for the name
        // set ourselves as the text field delegate
        nameTextField.delegate = self
        // set the keyboard appearance and behavior
        nameTextField.keyboardType = .Default
        nameTextField.returnKeyType = .Done
        nameTextField.enablesReturnKeyAutomatically = true
        nameTextField.autocapitalizationType = .Words
        nameTextField.autocorrectionType = .No
        nameTextField.spellCheckingType = .No
        nameTextField.placeholder = "Enter a unique price list name"
        // setup text editing for the notes
        // set ourselves as the text field delegate
        notesTextView.delegate = self
        // set the keyboard appearance and behavior
        notesTextView.keyboardType = .Default
        notesTextView.returnKeyType = .Done
        notesTextView.enablesReturnKeyAutomatically = true
        notesTextView.autocapitalizationType = .Sentences
        notesTextView.autocorrectionType = .Yes
        notesTextView.spellCheckingType = .Yes
        //notesTextView.placeholder = "Enter a unique market name"
        updateUI()
    }

    // MARK: UI validation properties
    // these should check that the information onscreen is valid for database use
    private var validName : Bool {
        // should detect if name is unique (not in the model's existing PivotListList)
        return pivotList != nil
    }
    private var validNotes : Bool {
        return pivotList != nil
    }
    private var validUI : Bool {
        return validName && validNotes
        // be sure to && all other valiation bools
    }
    
    func updateUI() {
        title = "Information for \(model.getMarketWithID(pivotList.marketId)!.name) List"
        nameTextField.text = pivotList?.standardName
        notesTextView.text = pivotList?.notes
        saveButtonItem.enabled = validUI
    }
    
    func updateModel() {
        if validName {
            pivotList?.name = nameTextField.text
        }
        if validNotes {
            pivotList?.notes = notesTextView.text
        }
        updateUI()
    }
    
    // this method allows keyboard removal by touching any background in the view
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        setEditing(false, animated: true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateModel() // name field updated and keyboard dismissed
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "Add Pivots Manual Segue" {
            if let dvc = segue.destinationViewController as? SelectPivotViewController {
                // set the data needed for the next VC to add pivots to the PL we are editing
                // also if we are adding, disable its Back button so we don't redo this screen
                dvc.setPivotList(pivotList, enableBack: !adding)
            }
        }
    }
    

}
