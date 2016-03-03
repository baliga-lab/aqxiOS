//
//  OxygenViewController.swift
//  aqx1010
//
//  Created by Serdar Turkarslan on 2/23/16.
//  Copyright © 2016 Baliga Lab. All rights reserved.
//



import UIKit
import Charts

class OxygenViewController: UIViewController, UITextFieldDelegate, ChartViewDelegate {
    
    let TAG_DATE_PICKER    = 4711
    let TAG_INPUT_O2       = 47170
    @IBOutlet weak var o2History: LineChartView!
    @IBOutlet weak var valueDateSelected: UILabel!
    @IBOutlet weak var valueSelected: UILabel!
    
    var uid: String = ""
    var o2vals: [Double] = []
    var o2labels: [String] = []
    
    
    func showError() {
        valueDateSelected.text = "There was an error with your submission"
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let myDate = o2labels[entry.xIndex]
        let dateSelected = formatter.dateFromString(myDate)
        formatter.dateFormat = "MMM dd yyyy, hh:mm:ss a"
        let dateMedium = formatter.stringFromDate(dateSelected!)
        valueSelected.text = "\(entry.value)"
        valueDateSelected.text = "\(dateMedium)"
        print("\(entry.value) in \(o2labels[entry.xIndex])")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        o2History.delegate = self
        apiGetMeasurements(uid, fun: { (measurements: NSDictionary) -> Void in
            print(measurements)
            self.o2vals = (measurements["o2"] as! NSArray).map({
                ($0 as! NSDictionary)["value"] as! Double
            })
            self.o2labels = (measurements["o2"] as! NSArray).map({
                ($0 as! NSDictionary)["time"] as! String
            })
            
            dispatch_async(dispatch_get_main_queue(), {
                self.setChart(self.o2labels, values: self.o2vals)
            })
        })
        
        print("uid: " + self.uid)
        (self.view.viewWithTag(TAG_INPUT_O2) as! UITextField).delegate = self
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
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "O2")
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartDataSet.setColor(UIColor.blueColor().colorWithAlphaComponent(0.5))
        lineChartDataSet.circleRadius = 3.0
        lineChartDataSet.setCircleColor(UIColor.blueColor())
        lineChartDataSet.lineWidth = 2.0
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawVerticalHighlightIndicatorEnabled = true
        lineChartDataSet.fillColor = UIColor.blueColor()
        lineChartDataSet.highlightColor = UIColor.blackColor()
        
        
        o2History.data = lineChartData
        o2History.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        o2History.descriptionText = ""
        o2History.autoScaleMinMaxEnabled = true
        o2History.noDataTextDescription = "Data will be loaded soon."
        o2History.maxVisibleValueCount = 60
        o2History.pinchZoomEnabled = false
        o2History.drawGridBackgroundEnabled = true
        o2History.drawBordersEnabled = false
    }
    
    
    
    override func viewDidLayoutSubviews() {
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
        var o2ValueError = false
        let datePicker = self.view.viewWithTag(TAG_DATE_PICKER) as! UIDatePicker
        let date: NSDate = datePicker.date
        let o2Value = self.view.viewWithTag(TAG_INPUT_O2) as! UITextField
        
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
        
        if (o2Value.text != nil) { entry["o2"] = NSString(string: o2Value.text!).floatValue } else {
            o2ValueError = true
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
                    o2ValueError = true
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if o2ValueError == true {
                        print("Error:\n \(error)")
                        self.showError()
                    } else {
                        let alertController = UIAlertController(title: "Submission Successfull!", message:String("You successfully submitted \n O2: \(o2Value.text!)"), preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        self.valueDateSelected.text = String("Last submission: pH: \(o2Value.text!) \n Time: \(formatter.stringFromDate(date))")
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