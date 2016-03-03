//
//  ChartsViewController.swift
//  aqx1010
//
//  Created by Serdar Turkarslan on 1/13/16.
//  Copyright © 2016 Baliga Lab. All rights reserved.
//

import UIKit
import Charts
import Foundation

class ChartsViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var valueSelected: UILabel!
    @IBOutlet weak var valueDateSelected: UILabel!
    @IBOutlet weak var nitrateChartView: LineChartView!
    @IBOutlet weak var tempChartView: LineChartView!
    @IBOutlet weak var lineChartView: LineChartView!

    var phvals: [Double] = []
    var phlabels: [String] = []
    var tempvals: [Double] = []
    var templabels: [String] = []
    var nitratevals: [Double] = []
    var nitratelabels: [String] = []

    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let myDate = phlabels[entry.xIndex]
        let dateSelected = formatter.dateFromString(myDate)
        formatter.dateFormat = "MMM dd yyyy, hh:mm:ss a"
        let dateMedium = formatter.stringFromDate(dateSelected!)
        
        valueSelected.text = "\(entry.value)"
        valueDateSelected.text = "\(dateMedium)"
        print("\(entry.value) in \(phlabels[entry.xIndex])")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = (self.tabBarController as! AqxSystemTabController).uid
        lineChartView.delegate = self
        tempChartView.delegate = self
        nitrateChartView.delegate = self
        apiGetMeasurements(uid, fun: { (measurements: NSDictionary) -> Void in
            // ammonium, alkalinity, chlorine, hardness, light, nitrate, nitrite, o2, ph, temp
            self.phvals = (measurements["ph"] as! NSArray).map({
                ($0 as! NSDictionary)["value"] as! Double
            })
            self.phlabels = (measurements["ph"] as! NSArray).map({
                ($0 as! NSDictionary)["time"] as! String
            })
            self.tempvals = (measurements["temp"] as! NSArray).map({
                ($0 as! NSDictionary)["value"] as! Double
            })
            self.templabels = (measurements["temp"] as! NSArray).map({
                ($0 as! NSDictionary)["time"] as! String
            })
            self.nitratevals = (measurements["nitrate"] as! NSArray).map({
                ($0 as! NSDictionary)["value"] as! Double
            })
            self.nitratelabels = (measurements["nitrate"] as! NSArray).map({
                ($0 as! NSDictionary)["time"] as! String
            })
            print(measurements)

            
            dispatch_async(dispatch_get_main_queue(), {
                self.setChart(self.phlabels, values: self.phvals)
                self.setTempChart(self.templabels, values: self.tempvals)
                self.setNitrateChart(self.nitratelabels, values: self.nitratevals)
            })
        })
        navigationItem.title = "Analytics"
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        var colors: [UIColor] = []
        for i in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "pH")
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartDataSet.setColor(UIColor.blueColor().colorWithAlphaComponent(0.5))
        lineChartDataSet.circleRadius = 3.0
        lineChartDataSet.setCircleColor(UIColor.blueColor())
        lineChartDataSet.lineWidth = 2.0
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawVerticalHighlightIndicatorEnabled = true
        lineChartDataSet.fillColor = UIColor.blueColor()
        lineChartDataSet.highlightColor = UIColor.blackColor()

        
        lineChartView.data = lineChartData
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        lineChartView.descriptionText = ""
        lineChartView.autoScaleMinMaxEnabled = true
        lineChartView.noDataTextDescription = "Data will be loaded soon."
        lineChartView.maxVisibleValueCount = 60
        lineChartView.pinchZoomEnabled = false
        lineChartView.drawGridBackgroundEnabled = true
        lineChartView.drawBordersEnabled = false
    }
    
    func setTempChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        
        let tempChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Temperature")
        let tempChartData = LineChartData(xVals: dataPoints, dataSet: tempChartDataSet)
        tempChartDataSet.setColor(UIColor.redColor().colorWithAlphaComponent(0.5))
        tempChartDataSet.circleRadius = 3.0
        tempChartDataSet.setCircleColor(UIColor.redColor())
        tempChartDataSet.lineWidth = 2.0
        tempChartDataSet.drawValuesEnabled = false
        tempChartDataSet.drawVerticalHighlightIndicatorEnabled = true
        tempChartDataSet.fillColor = UIColor.redColor()
        tempChartDataSet.highlightColor = UIColor.blackColor()
    
        
        tempChartView.data = tempChartData
        tempChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        tempChartView.descriptionText = ""
        tempChartView.noDataTextDescription = "Data will be loaded soon."
        tempChartView.maxVisibleValueCount = 60
        //tempChartView.rightAxis.drawLabelsEnabled = false
        tempChartView.pinchZoomEnabled = false
        tempChartView.drawGridBackgroundEnabled = true
        tempChartView.drawBordersEnabled = false
        let tempOptimal = ChartLimitLine(limit: 24.0, label: "")
        tempChartView.rightAxis.addLimitLine(tempOptimal)
        tempOptimal.lineColor = UIColor.orangeColor().colorWithAlphaComponent(0.5)
        tempOptimal.lineDashLengths = [2, 2]
        
    }
    
    
    func setNitrateChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        
        let nitrateChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Nitrate")
        let nitrateChartData = LineChartData(xVals: dataPoints, dataSet: nitrateChartDataSet)
        nitrateChartDataSet.setColor(UIColor.greenColor().colorWithAlphaComponent(0.5))
        nitrateChartDataSet.circleRadius = 3.0
        nitrateChartDataSet.setCircleColor(UIColor.greenColor())
        nitrateChartDataSet.lineWidth = 2.0
        nitrateChartDataSet.drawValuesEnabled = false
        nitrateChartDataSet.drawVerticalHighlightIndicatorEnabled = true
        nitrateChartDataSet.fillColor = UIColor.greenColor()
        nitrateChartDataSet.highlightColor = UIColor.blackColor()
        
        
        nitrateChartView.data = nitrateChartData
        nitrateChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        nitrateChartView.descriptionText = ""
        nitrateChartView.noDataTextDescription = "Data will be loaded soon."
        nitrateChartView.maxVisibleValueCount = 60
        //tempChartView.rightAxis.drawLabelsEnabled = false
        nitrateChartView.pinchZoomEnabled = false
        nitrateChartView.drawGridBackgroundEnabled = true
        nitrateChartView.drawBordersEnabled = false
//        let tempOptimal = ChartLimitLine(limit: 24.0, label: "Optimal")
//        tempChartView.rightAxis.addLimitLine(tempOptimal)
//        tempOptimal.lineColor = UIColor.orangeColor().colorWithAlphaComponent(0.5)
//        tempOptimal.lineDashLengths = [2, 2]
        
    }


    
    
}