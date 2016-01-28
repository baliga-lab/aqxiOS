//
//  ChartsViewController.swift
//  aqx1010
//
//  Created by Serdar Turkarslan on 1/13/16.
//  Copyright © 2016 Baliga Lab. All rights reserved.
//

import UIKit
import Charts

class ChartsViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var tempDataSelected: UILabel!
    @IBOutlet weak var nitrateChartView: LineChartView!
    @IBOutlet weak var tempChartView: BarChartView!
    @IBOutlet weak var phDataSelected: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    
    //let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
    var phvals: [Double] = []
    var phlabels: [String] = []
    var tempvals: [Double] = []
    var templabels: [String] = []

    /*
    func tempChartValueSelected(chartView: BarChartView, entry: BarChartDataEntry, dataSetIndex: Int, highlight: ChartHighlighter) {
        tempDataSelected.text = "\(entry.value) in \(months[entry.xIndex])"
        print("\(entry.value) in \(months[entry.xIndex])")
    }*/

    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        phDataSelected.text = "\(entry.value) in \(phlabels[entry.xIndex])"
        print("\(entry.value) in \(phlabels[entry.xIndex])")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = (self.tabBarController as! AqxSystemTabController).uid
        lineChartView.delegate = self
        tempChartView.delegate = self
        apiGetMeasurements(uid, fun: { (measurements: NSDictionary) -> Void in
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
            
            dispatch_async(dispatch_get_main_queue(), {
                self.setChart(self.phlabels, values: self.phvals)
                self.setTempChart(self.templabels, values: self.tempvals)
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
        lineChartView.data = lineChartData
        //lineChartDataSet.colors = colors
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        lineChartView.descriptionText = ""
        lineChartView.noDataTextDescription = "Data will be loaded soon."
        lineChartView.maxVisibleValueCount = 60
        lineChartView.pinchZoomEnabled = false
        lineChartView.drawGridBackgroundEnabled = true
        lineChartView.drawBordersEnabled = false
    }
    
    func setTempChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        
        let tempChartDataSet = BarChartDataSet(yVals: dataEntries, label: "Temperature")
        let tempChartData = BarChartData(xVals: dataPoints, dataSet: tempChartDataSet)
        tempChartDataSet.colors = ChartColorTemplates.vordiplom()
        tempChartView.data = tempChartData
        tempChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        tempChartView.descriptionText = ""
        tempChartView.noDataTextDescription = "Data will be loaded soon."
        tempChartView.maxVisibleValueCount = 60
        tempChartView.pinchZoomEnabled = false
        tempChartView.drawGridBackgroundEnabled = true
        tempChartView.drawBordersEnabled = false
    }

    
    
}