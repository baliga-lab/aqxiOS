//
//  TempViewController.swift
//  aqx1010
//
//  Created by Serdar Turkarslan on 12/29/15.
//  Copyright © 2015 Baliga Lab. All rights reserved.
//

import UIKit
import Charts

class TempViewController: UIViewController, UITextFieldDelegate, ChartViewDelegate {
    
    let TAG_DATE_PICKER    = 4711
    let TAG_INPUT_TEMP     = 47120
    @IBOutlet weak var tempHistory: LineChartView!
    @IBOutlet weak var valueDateSelected: UILabel!
    @IBOutlet weak var valueSelected: UILabel!
    
    var uid: String = ""
    var tempvals: [Double] = []
    var templabels: [String] = []
    
    
    func showError() {
        valueDateSelected.text = "There was an error with your submission"
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let myDate = templabels[entry.xIndex]
        let dateSelected = formatter.dateFromString(myDate)
        formatter.dateFormat = "MMM dd yyyy, hh:mm:ss a"
        let dateMedium = formatter.stringFromDate(dateSelected!)
        valueSelected.text = "\(entry.value)"
        valueDateSelected.text = "\(dateMedium)"
        print("\(entry.value) in \(templabels[entry.xIndex])")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempHistory.delegate = self
        apiGetMeasurements(uid, fun: { (measurements: NSDictionary) -> Void in
            print(measurements)
            self.tempvals = (measurements["temp"] as! NSArray).map({
                ($0 as! NSDictionary)["value"] as! Double
            })
            self.templabels = (measurements["temp"] as! NSArray).map({
                ($0 as! NSDictionary)["time"] as! String
            })
            
            dispatch_async(dispatch_get_main_queue(), {
                self.setChart(self.templabels, values: self.tempvals)
            })
        })

        (self.view.viewWithTag(TAG_INPUT_TEMP) as! UITextField).delegate = self
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
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Temperature")
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartDataSet.setColor(UIColor.redColor().colorWithAlphaComponent(0.5))
        lineChartDataSet.circleRadius = 3.0
        lineChartDataSet.setCircleColor(UIColor.redColor())
        lineChartDataSet.lineWidth = 2.0
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawVerticalHighlightIndicatorEnabled = true
        lineChartDataSet.fillColor = UIColor.redColor()
        lineChartDataSet.highlightColor = UIColor.blackColor()
        
        
        tempHistory.data = lineChartData
        tempHistory.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        tempHistory.descriptionText = ""
        tempHistory.autoScaleMinMaxEnabled = true
        tempHistory.noDataTextDescription = "Please be patient while data loading."
        tempHistory.maxVisibleValueCount = 60
        tempHistory.pinchZoomEnabled = false
        tempHistory.drawGridBackgroundEnabled = true
        tempHistory.drawBordersEnabled = false
    }
    
    
    
    override func viewDidLayoutSubviews() {
        //let margin: CGFloat = 20.0
        //let width = view.bounds.width - 2 * margin
        //phSlider.frame = CGRect(x: 64, y: 300, width: 280, height: 31)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func submit(sender: AnyObject) {
        self.view.endEditing(true)
        var tempValueError = false
        let datePicker = self.view.viewWithTag(TAG_DATE_PICKER) as! UIDatePicker
        let date: NSDate = datePicker.date
        let tempValue = self.view.viewWithTag(TAG_INPUT_TEMP) as! UITextField
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = API_DATE_FORMAT
        print("date: " + formatter.stringFromDate(date))
        
        let authToken = NSUserDefaults.standardUserDefaults().objectForKey("GoogleAuthToken") as! String
        let url = NSURL(string: API_BASE_URL + "/measurements/" + self.uid)
        print(url)
        
        // data: {"measurements": [{"time": <time>, "temp": <value>, ...}]}
        let request = NSMutableURLRequest(URL: url!)
        let data = NSMutableDictionary()
        let measurements = NSMutableArray()
        let entry = NSMutableDictionary()
        entry["time"] = formatter.stringFromDate(date)
        
        if (tempValue.text != nil) { entry["temp"] = NSString(string: tempValue.text!).floatValue } else {
            tempValueError = true
            showError()
        }
        
        measurements.addObject(entry)
        data["measurements"] = measurements
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let outdata = try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.init(rawValue: 0))
            let str = NSString.init(data: outdata, encoding: NSUTF8StringEncoding)
            print(str)
            request.HTTPBody = outdata
            
            
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let authString = "Bearer \(authToken)"
            config.HTTPAdditionalHeaders = ["Authorization": authString]
            let session = NSURLSession(configuration: config)
            let task = session.dataTaskWithRequest(request) {(data, response, error) in
                if error == nil {
                    let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print(s!)
                } else {
                    tempValueError = true
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if tempValueError == true {
                        print("Error:\n \(error)")
                        self.showError()
                    } else {
                        let alertController = UIAlertController(title: "Submission Successfull!", message:String("You successfully submitted \n Temperature: \(tempValue.text!) °C"), preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        self.valueDateSelected.text = String("Last submission: Temp: \(tempValue.text!) °C \n Time: \(formatter.stringFromDate(date))")
                    }
                }
                
                
            }
            task.resume()
        } catch {
            print("Error:\n \(error)")
            self.valueDateSelected.text = "Error:\n \(error)"
        }
    }

}
