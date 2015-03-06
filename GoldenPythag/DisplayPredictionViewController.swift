//
//  DisplayPredictionViewController.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/5/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

class DisplayPredictionViewController: UIViewController {
    
    var prediction : Prediction!

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var resultsButton: UIBarButtonItem!
    
    @IBAction func showResults(sender: UIBarButtonItem) {
        println("Testing the Show Results Segue")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        descriptionLabel.text = prediction.description
        resultsButton.enabled = prediction.resultList.count > 0
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Inputs Segue" {
            // Get the new view controller using segue.destinationViewController.
            if let dvc = segue.destinationViewController as? SelectPivotViewController {
                // Pass the selected object to the new view controller.
                dvc.pivotList = PricePivotList(marketID: prediction.marketId, pivots: prediction.pivotData)
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
