//
//  ChangeMarketLocationViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/14/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

struct Constants {
    static let scaleFactorMinutesPerDegree = 60
    static let scaleFactorMinutesPerHour = 60
    static let longitudeRange = 0.0...180.0
    static let latitudeRange = 0.0...90.0
    static let timeZoneRange = 0.0...24.0
    static let minutesRange = 0.0...60.0
}

class ChangeMarketLocationViewController: GoldenPythagTableViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    var marketLocation : CustomMarketLocation!
    var adding = false
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var longitudePickerView: UIPickerView!
    @IBOutlet weak var latitudePickerView: UIPickerView!
    @IBOutlet weak var timeZonePickerView: UIPickerView!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!

    private var longitude : Double {
        get {
            // combine component values into a double
            var input = (D: 0, M: 0, S: 0.0)
            input.D = longitudePickerView.selectedRowInComponent(0)
            input.M = longitudePickerView.selectedRowInComponent(1)
            return sexagesimalCombine(input)
        }
        set {
            // split the double in newValue into its component values
            let (degrees, minutes, _) = sexagesimalSplit(newValue)
            longitudePickerView.selectRow(degrees, inComponent: 0, animated: true)
            longitudePickerView.selectRow(minutes, inComponent: 1, animated: true)
        }
    }
    
    private var latitude : Double {
        get {
            // combine component values into a double
            var input = (D: 0, M: 0, S: 0.0)
            input.D = latitudePickerView.selectedRowInComponent(0)
            input.M = latitudePickerView.selectedRowInComponent(1)
            return sexagesimalCombine(input)
        }
        set {
            // split the double in newValue into its component values
            let (degrees, minutes, _) = sexagesimalSplit(newValue)
            latitudePickerView.selectRow(degrees, inComponent: 0, animated: true)
            latitudePickerView.selectRow(minutes, inComponent: 1, animated: true)
        }
    }
    
    private var timeZone : Double {
        get {
            // combine component values into a double
            var input = (D: 0, M: 0, S: 0.0)
            input.D = timeZonePickerView.selectedRowInComponent(0)
            input.M = timeZonePickerView.selectedRowInComponent(1)
            return sexagesimalCombine(input)
        }
        set {
            // split the double in newValue into its component values
            let (degrees, minutes, _) = sexagesimalSplit(newValue)
            timeZonePickerView.selectRow(degrees, inComponent: 0, animated: true)
            timeZonePickerView.selectRow(minutes, inComponent: 1, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // delete edit button added in super (we're using static fields)
        navigationItem.rightBarButtonItems?.removeLast()
        // set up the picker view delegates and data sources
        longitudePickerView.delegate = self
        longitudePickerView.dataSource = self
        latitudePickerView.delegate = self
        latitudePickerView.dataSource = self
        timeZonePickerView.delegate = self
        timeZonePickerView.dataSource = self
        // set ourselves as the text field delegate
        nameTextField.delegate = self
        // set the keyboard appearance and behavior
        nameTextField.keyboardType = .Default
        nameTextField.returnKeyType = .Done
        nameTextField.enablesReturnKeyAutomatically = true
        nameTextField.autocapitalizationType = .Words
        nameTextField.autocorrectionType = .No
        nameTextField.spellCheckingType = .No
        nameTextField.placeholder = "Enter a unique market location name"
        // start notifications on the model
        marketLocation.notifying = true
        updateUI()
    }

    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        // copy current UI settings into object
        updateModel()
        // commit new ID if needed
        if adding {
            CustomMarketLocation.assignID()
        }
        // save market object to model at appropriate row
        if let index = model.findMarketLocationIndex(marketLocation) {
            model.marketLocations[index] = marketLocation
            //println("updated market location \(marketLocation.name)")
        } else {
            model.marketLocations.append(marketLocation)
            //println("added new marketLocation \(marketLocation.name)")
        }
        // pop the navigation controller (do the "back" button action)
        navigationController?.popViewControllerAnimated(true)
    }

    private func updateUI() {
        // current market name into text view field
        nameTextField.text = marketLocation.name
        // current market name into screen title
        screenTitle = marketLocation.name
        // set components for longitude picker view
        longitude = marketLocation.longitude
        // set components for latitude picker view
        latitude = marketLocation.latitude
        // set components for time zone picker view
        timeZone = marketLocation.timezone
        // disable Save button if no name has been set
        saveButtonItem.enabled = validatedUI
    }
    
    // MARK: validation tests
    // 1. must have nonblank name field
    private var validatedName : Bool {
        return nameTextField.text != ""
    }
    // overall test to activate the Save button
    private var validatedUI : Bool {
        return validatedName
    }
    
    private func updateModel() {
        if validatedName && marketLocation.name != nameTextField.text {
            // copy current UI settings into object
            marketLocation.name = nameTextField.text
        }
        marketLocation.longitude = longitude
        marketLocation.latitude = latitude
        marketLocation.timezone = timeZone
        updateUI()
    }
    
    private let lonPVTag = 0
    private let latPVTag = 1
    private let tzPVTag = 2
    
    // MARK: Picker View Data Source
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == lonPVTag {
            return component == 0 ? 180 /*degrees*/ : 60 /*minutes*/
        }
        if pickerView.tag == latPVTag {
            return component == 0 ? 90 /*degrees*/ : 60 /*minutes*/
        }
        if pickerView.tag == tzPVTag {
            return component == 0 ? 24 /*hours*/ : 60 /*minutes*/
        }
        return 0
    }
    
    // (this is actually in UIPickerView Delegate instead)
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return "\(row)"
    }
    
    // this method allows keyboard removal by touching any background in the view
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
