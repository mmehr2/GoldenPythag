//
//  ChangePivotViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/14/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

// this VC is designed to edit the values of a single price pivot (date, price, Top/Bottom)
// the caller provides the mechanism (closure code) to save the pivot on some pivot list at the proper point

// No notification is needed due to this scheme (the caller provides code to update itself).
// However, if we need this in the future, the .Pivot notifier is provided for when changes are made.

class ChangePivotViewController: GoldenPythagTableViewController, UITextFieldDelegate {

    // MARK: Public API
    // NOTE: MUST SET THESE BEFORE CALLING
    var pivot : PricePivot! { didSet { notifying ? notifier.broadcast() : () } }
    var saver : ((PricePivot) -> ())!
    
    @IBOutlet weak var priceTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var pivotDatePicker: UIDatePicker!
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var priceSliderMinLabel: UILabel!
    @IBOutlet weak var priceSliderMaxLabel: UILabel!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        // update the object from the screen if needed
        updateModel()
        // commit the save
        saver(pivot)
        // pop the stack of the VC's NC
        navigationController!.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // enable notifications to other VCs about model object being edited
        notifying = true
        // remove edit button (last right button) since we are using static cells
        navigationItem.rightBarButtonItems?.removeLast()
        // set up slider scale factors
        sendScaleFactorsToSlider(maxScaleFactorCoarse)
        // setup text editing for the name
        // set ourselves as the text field delegate
        priceTextField.delegate = self
        // set the keyboard appearance and behavior
        priceTextField.keyboardType = .NumbersAndPunctuation
        priceTextField.returnKeyType = .Done
        priceTextField.enablesReturnKeyAutomatically = false
        priceTextField.autocapitalizationType = .None
        priceTextField.autocorrectionType = .No
        priceTextField.spellCheckingType = .No
        priceTextField.placeholder = "Enter a price for the market pivot"
        updateUI()
    }
    
    private var notifier = GPNotification(type: .Pivot)
    private var notifying = false
    private let segmentIndexOfTop = 1 // from the UI as currently designed in storyboard
    private let segmentIndexOfBottom = 0 // from the UI as currently designed in storyboard
    
    private func updateUI() {
        // send model to screen (model is validated, so no conditionals needed)
        priceTypeSegmentedControl.selectedSegmentIndex = pivot.top ? segmentIndexOfTop : segmentIndexOfBottom
        priceTextField.text = getFormattedStringFromPrice(pivot.price)
        pivotDatePicker.date = pivot.date
        saveButtonItem.enabled = validUI
        navigationItem.prompt = "" // intended for validation error messages
    }
    
    // MARK: - Model validation
    var validTBSetting : Bool {
        return priceTypeSegmentedControl.selectedSegmentIndex != UISegmentedControlNoSegment
    }
    var validPrice : Bool {
        // criteria:
        // if Top:
        //   should be > than price of previous and/or next pivot in PL, if any
        // if Bottom:
        //   should be < than price of previous and/or next pivot in PL, if any
        // NOTE: these should only issue warning messages and prevent validUI Saves, not prevent editing
        // should have a valid numeric value preceded by the right currency symbol ($ now)
        return true
    }
    var validDate : Bool {
        // criteria:
        // must be > date of previous pivot in PL, if any
        // must be < date of next pivot in PL, if any
        // NOTE: these should only issue warning messages and prevent validUI Saves, not prevent editing
        return true
    }
    var validUI : Bool {
        return validTBSetting && validPrice && validDate
    }
    
    private func updateModel() {
        let oldNotify = notifying
        notifying = false // shut off individial notifications
        if validDate {
            pivot.date = pivotDatePicker.date
        }
        if validPrice {
            pivot.price = getPriceFromFormattedString(priceTextField.text!)
        }
        if validTBSetting {
            pivot.top = priceTypeSegmentedControl.selectedSegmentIndex == segmentIndexOfTop
        }
        // batch notification update
        notifying = oldNotify // put the old notifying state back (could be off)
        if validUI  {
            // if the UI is all valid, trigger a single notification to cover it
            pivot.price = pivot.price
        }
    }
    
    // MARK: - Price slider feature
    // current plan for slider:
    // The default position will be middle (100%)
    // The price scaling will be proportional, setting a multiplier for the current price when the start event occurs
    // When tracking starts, the current price is captured to the base price variable
    // As tracking continues with value changes, the value is changed into a scale factor and applied to the base price, then set to the UI
    // When tracking is complete, the value is committed to the model and the slider is reset to middle range (100%)
    // If tracking is canceled, just reset the slider and ignore the rest
    // The minimum will be 25% (settable in a setting)
    // The maximum will be 400% (settable in a setting)
    // There is a simple equation to get Y (scale factor) from X (value)
    // This is a log scale where value = log(scaleFactor) + C
    // This scale isn't linear, so perhaps some indicator would help?
    private var basePrice : Double = 0.0
    private var newPrice : Double = 0.0
    private var maxScaleFactorCoarse = 4.0
    private var maxScaleFactorFine = 1.1
    private var scaleFactorLinearRange = -1.0...1.0
    private var scaleFactorRange = -1.0...1.0
    private var scaleFactorLogRange = -1.0...1.0
    
    @IBAction func priceSliderTouchDown() {
        // start the tracking: capture the current UI price value, make sure the scale factor percentages are set to the UI
        //basePrice = getPriceFromFormattedString(priceTextField.text).doubleValue
        basePrice = pivot.price.doubleValue
        //println("PS touch DOWN - start tracking at \(getFormattedStringFromPrice(basePrice))")
    }
    @IBAction func priceSliderTouchUpInside(sender: AnyObject) {
        // stop the tracking with completion:
        // update the UI tracking change (same as the value changed function)??
        // then update the model with the current tracking value UI changes
        // reset the slider to its middle position (LSF = 0, SF = 100%) -- same as CANCEL
        //println("PS touch UP inside - update UI + model + reset slider")
        priceSlider.value = 0.0
    }
    @IBAction func priceSliderTouchUpOutside() {
        // stop the tracking with cancel:
        // reset the UI from the (unchanged) model
        updateUI()
        // reset the slider to its middle position (LSF = 0, SF = 100%)
        //println("PS touch UP cancel - reset slider to middle")
        priceSlider.value = 0.0
    }
    @IBAction func priceSliderValueChanged(sender: AnyObject) {
        // update the tracking as each new value comes in
        let trackValue = priceSlider.value
        // convert the slider position (-1.00 to +1.00 linear) into log scale factor (-log(MSF) to +log(MSF), linear)
        let valueLog = linearScale(Double(trackValue), fromRange: scaleFactorLinearRange, toRange: scaleFactorLogRange)
        // convert the LSF into a multiplier, multiply by the basePrice, and update the price text view
        let multiplier = exp(valueLog)
        newPrice = multiplier * basePrice
    //    let bpstr = getFormattedStringFromPrice(basePrice)
        let npstr = getFormattedStringFromPrice(newPrice)
        priceTextField.text = npstr
        //println("PS value update UI using LSF = \(trackValue) = logSF \(valueLog) = mul \(multiplier) * base \(bpstr) = newPrice \(npstr)")
    }
    private func sendScaleFactorsToSlider(maxScale: Double) {
        // the linear scale goes to the slider min/max values
        priceSlider.minimumValue = Float(scaleFactorLinearRange.start)
        priceSlider.maximumValue = Float(scaleFactorLinearRange.end)
        // the current value of the slider is set to midrange (zero)
        priceSlider.value = Float(0.0)
        // then the calculated percentages are sent to the min and max labels (TBD?: localized since %)
        let minScale = 1.0 / maxScale
        scaleFactorRange = minScale...maxScale
        scaleFactorLogRange = -log(maxScale)...log(maxScale)
        let nf = NSNumberFormatter()
        nf.numberStyle = .PercentStyle
        nf.minimumIntegerDigits = 1
        nf.maximumIntegerDigits = 3
        nf.minimumFractionDigits = 1
        nf.maximumFractionDigits = 1
        priceSliderMinLabel.text = NSNumberFormatter().stringFromNumber(minScale * 100.0)
        priceSliderMaxLabel.text = NSNumberFormatter().stringFromNumber(maxScale * 100.0)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
