//
//  BarGraphView.swift
//  GoldenPythag
//
//  Created by Michael L Mehr on 3/17/15.
//  Copyright (c) 2015 Michael L. Mehr. All rights reserved.
//

import UIKit

protocol BarGraphViewDataSource {
    func numberOfBarsInView(barGraphView: BarGraphView) -> Int
    func barGraphView(barGraphView: BarGraphView, dataForBarAtIndex: Int) -> Float
}

@IBDesignable
class BarGraphView: UIView {

    // public API overrides (with defaults)
    var dataSource : BarGraphViewDataSource?
    @IBInspectable var barWidth : Float = 30.0
    @IBInspectable var barSpacing : Float = 10.0
    @IBInspectable var barOffset : Float = 5.0
    @IBInspectable var barColor : UIColor = UIColor.yellowColor()
    @IBInspectable var barBackgroundColor : UIColor = UIColor.blueColor()
    // NOTE: the following is best called from the dataSource function numberOfBarsInView()
    // this will get the latest value while the code is drawing onscreen
    var barsPerPage : Double {
        let width = Float(self.bounds.size.width.native)
        let barSpace = barWidth + barSpacing
        let adjustedWidth = width - barOffset
        return Double(adjustedWidth / barSpace)
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // code nabbed from: http://stackoverflow.com/questions/5164523/bar-graphs-in-ios-app
        if dataSource == nil {
            addRandomPoints(randomDataPoints) // for demo only
        }
        //println("BGV:draw - barsPerPage = \(barsPerPage) frame=\(frame) bounds=\(bounds)")
        let height = self.bounds.size.height
        let context = UIGraphicsGetCurrentContext();
        // fill the view with background color
        CGContextSetFillColorWithColor(context, barBackgroundColor.CGColor)
        CGContextFillRect(context, rect);
        // draw the view bars
        CGContextSetFillColorWithColor(context, barColor.CGColor)
        let barWidthCGF = CGFloat(barWidth)
        let xOffset = CGFloat(barOffset)
        var count = CGFloat(0)
        let total = dataSource?.numberOfBarsInView(self) ?? values.count
        for i in 0..<total {
            let num = dataSource?.barGraphView(self, dataForBarAtIndex: i) ?? values[i]
            let x = CGFloat(count * (barWidthCGF + CGFloat(barSpacing)) + xOffset)
            let valueHeight = CGFloat(num) * height
            let barHeight = height - valueHeight
            let barRect = CGRectMake(x, barHeight, barWidthCGF, valueHeight);
            CGContextAddRect(context, barRect);
            //println("barRect[\(count):\(num)] = CGRectMake(\(x), \(barHeight), \(barWidthCGF), \(valueHeight))")
            count++;
        }
        CGContextFillPath(context);
    }

    // MARK: code only for Demo Mode (Interface Builder. or when no data source provided)
    var values : [Float] = [] // between 0 and 1
    var panOffset : CGFloat = 0.0 // DEPRECATED DURING PAGING DESIGN
    @IBInspectable var randomDataPoints : Int = 0 // set >0 for design-time data testing
    @IBInspectable private var added = false
    private func addRandomPoints( numToAdd: Int ) {
        if !added {
            for _ in 0..<numToAdd {
                let value = getRandomFrom(0, to: 1000)
                values.append(Float(Float(value)/1000.0))
            }
            added = true
        }
    }

}
