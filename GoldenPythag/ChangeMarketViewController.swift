//
//  ChangeMarketViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/6/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

class ChangeMarketViewController: UIViewController, UITextFieldDelegate {

    let model = GoldenPythag.modelData
    var market : CustomMarket!
    var adding = false
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var originDatePicker: UIDatePicker!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!

    @IBAction func setMarketLocation(sender: UIButton) {
        // sets the market SELECTION (used for global list filtering)
        let m = market.location
        let ac = UIAlertController(title: "Select Market Location", message: nil, preferredStyle: .ActionSheet)
        for item in model.marketLocations {
            let act = UIAlertAction(title: item.name, style: .Default) { (_) in
                self.market.location = self.model.getMarketLocationWithID(item.id)!
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
    
    private var savedTitle : String? // initialize to title in viewDidLoad()
    var screenTitle : String? {
        get {
            return title
        }
        set {
            let scrTitle = newValue == nil || newValue == "" ? savedTitle! : "\(savedTitle!) \(newValue!)"
            title = scrTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // set ourselves as the text field delegate
        nameTextField.delegate = self
        // set the keyboard appearance and behavior
        nameTextField.keyboardType = .Default
        nameTextField.returnKeyType = .Done
        nameTextField.enablesReturnKeyAutomatically = true
        nameTextField.autocapitalizationType = .Words
        nameTextField.autocorrectionType = .No
        nameTextField.spellCheckingType = .No
        nameTextField.placeholder = "Enter a unique market name"
        // disallow future dates for market origin
        //originDatePicker.maximumDate = NSDate()
        // MLM - chose not to do the above since it would disable  entering dates left to right in some cases
        // better to use validation function
        
        // save the title for decorated title feature
        savedTitle = title
        // start notifications on the model
        market.notifying = true
        updateUI()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        // if we are no longer in the NC's stack of VC's, Back or Save button has been pressed!
//        if let vcs = navigationController?.viewControllers {
//            if (vcs as NSArray).indexOfObject(self) == NSNotFound {
//                println("CMVC back button pressed!")
//            }
//        }
    }
    
    // validation tests:
    // 1. must have nonblank name field
    private var validatedName : Bool {
        guard let nameField = nameTextField.text else {
            return false
        }
        return nameField != ""
    }
    // 2. no future dates for origin
    private var validatedDate : Bool {
        return originDatePicker.date < NSDate()
    }
    // overall test to activate the Save button
    private var validatedUI : Bool {
        return validatedName && validatedDate
    }
    
    func updateUI() {
        // current market name into text view field
        nameTextField.text = market.name
        // current market name into screen title
        screenTitle = market.name
        // current market location name into label text
        locationNameLabel.text = market.location.name
        // current market origin date into date picker
        originDatePicker.date = market.origin
        // disable Save button if no name has been set
        saveButtonItem.enabled = validatedUI
    }
    
    func updateModel() {
        if validatedName && market.name != nameTextField.text! {
            // copy current UI settings into object
            market.name = nameTextField.text!
        }
        if validatedDate && market.origin != originDatePicker.date {
            // copy current UI settings into object
            market.origin = originDatePicker.date
        }
        //if validatedUI {
        //}
        updateUI()
    }
    
    @IBAction func saveEdits(sender: UIBarButtonItem) {
        // copy current UI settings into object
        updateModel()
        //market.location = //has already been updated by the unwind segue
        // commit new ID if needed
        if adding {
            CustomMarket.assignID()
        }
        // save market object to model at appropriate row
        if let index = GoldenPythag.modelData.findMarketIndex(market) {
            GoldenPythag.modelData.markets[index] = market
            //println("updated market \(market.name)")
        } else {
            GoldenPythag.modelData.markets.append(market)
            //println("added new market \(market.name)")
        }
        // pop the navigation controller (do the "back" button action)
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func unwind(segue: UIStoryboardSegue) {
        // unwind segue got here, market location was just updated
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
        if segue.identifier == "Set Market Location Segue" {
            // Get the new view controller using segue.destinationViewController.
            if let dvc = segue.destinationViewController as? SelectMarketLocationViewController {
                // get the currently selected Market Location object
                // Pass the selected object to the new view controller.
                dvc.setSelectedLocation(market.location)
                // update the model from the UI before we leave
                updateModel()
            }
        }
    }
    

}
