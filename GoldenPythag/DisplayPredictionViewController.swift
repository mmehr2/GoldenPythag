//
//  DisplayPredictionViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/5/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

class DisplayPredictionViewController: UIViewController, BarGraphViewDataSource {
    
    var prediction : Prediction!
    
    private var pager = PagingDataCounter()
    private var currentPage : Int = 0 {
        didSet {
            setPrompt()
        }
    }
    private var valuesPerPage : Int {
        get {
            return pager.valuesPerPage
        }
        set {
            pager.valuesPerPage = newValue
            // update prompt on changes
            setPrompt()
        }
    }
    private func setPrompt() {
        // set the prompt
        navigationItem.prompt = "Page \(currentPage+1) of \(pager.numberOfPages)"
    }

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var resultsButton: UIBarButtonItem!
    @IBOutlet weak var barGraphView: BarGraphView!
    {
        didSet {
            let recognizer = UIPanGestureRecognizer(target: self, action: "pan:")
            barGraphView.addGestureRecognizer(recognizer)
            let recognizer2 = UITapGestureRecognizer(target: self, action: "tap:")
            barGraphView.addGestureRecognizer(recognizer2)
        }
    }
    
    @IBAction func showResults(sender: UIBarButtonItem) {
        print("Testing the Show Results Segue")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        descriptionLabel.text = getStandardPredictionDescription(prediction)
        resultsButton.enabled = prediction.resultList.count > 0
        // set up data pager for bar graph
        pager.count = prediction.resultList.count
        currentPage = 0 // reset the page whenever (re-)loaded
        // set ourselves as the data source for the bar graph
        barGraphView.dataSource = self
    }

    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        //case .Changed: fallthrough
        case .Ended:
            let translation = gesture.translationInView(barGraphView)
            // only need direction of translation here
            if translation.x < 0 {
                pageBarGraphViewRelative(-1)
            } else if translation.x > 0 {
                pageBarGraphViewRelative(+1)
            }
            // reset the translation to 0 so we can get incremental panning
            gesture.setTranslation(CGPointZero, inView: barGraphView)
        default: break
        }
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            // update the pager's currentPage accordingly
            // if we can get the X pos of the tap coord, we can get an indicator of what direction the user wants to go:
            let tapPoint = gesture.locationInView(barGraphView)
            let width = barGraphView.bounds.size.width
            if tapPoint.x < 0.3333 * width {
                // left third of view - decrease page number if possible
                pageBarGraphViewRelative(-1)
           } else if tapPoint.x > 0.6667 * width {
                // right third of view - increase page number if possible
                pageBarGraphViewRelative(+1)
            } else {
                // middle third - do nothing
            }
            break
        default: break
        }
    }

    func pageBarGraphViewRelative(increment: Int ) {
        let range = 0..<Int(pager.numberOfPages)
        if isValue(currentPage + increment, inOpenRange: range) {
            // change the page
            currentPage += increment
        }
        // update the bargraph to show the specified page
        barGraphView.setNeedsDisplay()
    }
    
    // MARK: - Bar graph data source
    func numberOfBarsInView(barGraphView: BarGraphView) -> Int {
        // update to get the latest number of barsPerPage
        valuesPerPage = Int(barGraphView.barsPerPage) // only whole bars
        return pager.getNumberOfValuesOnPage(currentPage) ?? 0
    }
    
    func barGraphView(barGraphView: BarGraphView, dataForBarAtIndex: Int) -> Float {
        // return the data at given index, normalized between 0.0 and 1.0
        // NOTE: the index is an offset from the current page start
        let pageStart = pager.getFirstIndexForPageNumber(currentPage)!
        let data = prediction.resultList[pageStart + dataForBarAtIndex]
        return Float( Double(data) / 1000.0 )
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Inputs Segue" {
            // Get the new view controller using segue.destinationViewController.
            if let dvc = segue.destinationViewController as? SelectPivotViewController {
                // Pass the selected object to the new view controller.
                dvc.setPivotData(prediction.pivotData)
            }
        } else if segue.identifier == "Show Results Segue" {
                // Get the new view controller using segue.destinationViewController.
                if let dvc = segue.destinationViewController as? ResultListViewController {
                    // Pass the selected object to the new view controller.
                    dvc.resultList = prediction.resultList
                    dvc.startDate = prediction.startDate
                }
        }
    }
    

}
