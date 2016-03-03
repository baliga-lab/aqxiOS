//
//  pHViewController.swift
//  aqx1010
//
//  Created by Serdar Turkarslan on 12/18/15.
//  Copyright © 2015 Baliga Lab. All rights reserved.
//

import UIKit
import Charts

class pHViewController: UIViewController, UITextFieldDelegate, ChartViewDelegate {
    
    let TAG_SYSTEM_NAME      = 4711
    let TAG_SYSTEM_TECHNIQUE = 4712
    
    let TAG_DATE_PICKER    = 4711
    let TAG_INPUT_TEMP     = 4712
    
    let TAG_INPUT_PH       = 47130
    let TAG_SLIDER_PH      = 47200
    var uid: String = ""
    
    @IBOutlet weak var phHistory: LineChartView!
    @IBOutlet weak var valueDateSelected: UILabel!
    @IBOutlet weak var valueSelected: UILabel!
    @IBOutlet weak var phSubmissionStatus: UILabel!
    @IBOutlet weak var phPreview: UIView!
    
    var phvals: [Double] = []
    var phlabels: [String] = []
    
    @IBOutlet weak var phSlider: UISlider!
    let phCGColors = [rgb2CGColor(0xfaac59), rgb2CGColor(0xee8243), rgb2CGColor(0xe35744), rgb2CGColor(0xe93e4d), rgb2CGColor(0xea185e)]
    let phUIColors = [rgb2UIColor(0xfaac59), rgb2UIColor(0xee8243), rgb2UIColor(0xe35744), rgb2UIColor(0xe93e4d), rgb2UIColor(0xea185e)]
    
    func showError() {
        //phSubmissionStatus.text = "There was an error with your submission"
        valueDateSelected.text = "There was an error with your submission"
    }
    
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
        
        phHistory.delegate = self
        apiGetMeasurements(uid, fun: { (measurements: NSDictionary) -> Void in
            // ammonium, alkalinity, chlorine, hardness, light, nitrate, nitrite, o2, ph, temp
            self.phvals = (measurements["ph"] as! NSArray).map({
                ($0 as! NSDictionary)["value"] as! Double
            })
            self.phlabels = (measurements["ph"] as! NSArray).map({
                ($0 as! NSDictionary)["time"] as! String
            })
            dispatch_async(dispatch_get_main_queue(), {
                self.setChart(self.phlabels, values: self.phvals)
            })
        })
        
        phSlider.layer.insertSublayer(makeGradient(phSlider.bounds, colors: phCGColors), atIndex: 0)
        phPreview.backgroundColor = UIColor(red: 0.89, green: 0.34, blue: 0.27, alpha: 1)
        print("uid: " + self.uid)
        phPreview.layer.borderWidth = 1
        //phPreview.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).CGColor
        (self.view.viewWithTag(TAG_INPUT_PH) as! UITextField).delegate = self
        
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
        
        
        phHistory.data = lineChartData
        phHistory.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        phHistory.descriptionText = ""
        phHistory.autoScaleMinMaxEnabled = true
        phHistory.noDataTextDescription = "Data will be loaded soon."
        phHistory.maxVisibleValueCount = 60
        phHistory.pinchZoomEnabled = false
        phHistory.drawGridBackgroundEnabled = true
        phHistory.drawBordersEnabled = false
    }

    
    
    override func viewDidLayoutSubviews() {
//        let margin: CGFloat = 20.0
//        let width = view.bounds.width - 2 * margin
//        phSlider.frame = CGRect(x: 20, y: 300, width: width, height: 31)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func makeGradient(bounds: CGRect, colors: [CGColor]) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = colors
        return gradient
    }
    
    @IBAction func phSliderValueChanged(sender: UISlider) {
        let textfield = self.view.viewWithTag(TAG_INPUT_PH) as! UITextField
        let s = NSString(format: "%.2f", sender.value)
        textfield.text = s as String
        
        // compute preview color
        let stops = phUIColors
        let numStops = stops.count
        let range = (sender.maximumValue - sender.minimumValue)
        let segmentLength = range / Float(numStops - 1)
        
        // TODO: This is the global fraction, need fraction between stops
        let fraction = (sender.value - sender.minimumValue) / range
        
        let segment = Int((sender.value - sender.minimumValue) / segmentLength)
        print("value: ", sender.value, " range: ", range, " segment: ", segment, " fraction: ", fraction)
        phPreview.backgroundColor = UIColor(red: CGFloat(1.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: 1.0)
        let stop0 = stops[segment]
        let stop1 = stops[segment < numStops ? (segment + 1) : segment]
        var red0: CGFloat = 0, green0: CGFloat = 0, blue0: CGFloat = 0, alpha0: CGFloat = 0
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        if (stop0.getRed(&red0, green: &green0, blue: &blue0, alpha: &alpha0)) {
            print("stop0, r = ", red0, " g = ", green0, " b = ", blue0, " alpha = ", alpha0)
        }
        if (stop1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)) {
            print("stop1, r = ", red1, " g = ", green1, " b = ", blue1, " alpha = ", alpha1)
        }
        let redInterp = interpolate(Float(red0), to: Float(red1), fraction: fraction)
        let blueInterp = interpolate(Float(blue0), to: Float(blue1), fraction: fraction)
        let greenInterp = interpolate(Float(green0), to: Float(green1), fraction: fraction)
        phPreview.backgroundColor = UIColor(red: CGFloat(redInterp), green: CGFloat(greenInterp), blue: CGFloat(blueInterp), alpha: 1.0)
        textfield.backgroundColor = UIColor(red: CGFloat(redInterp), green: CGFloat(greenInterp), blue: CGFloat(blueInterp), alpha: 0.5)
    }
    
    
    @IBAction func submit(sender: AnyObject) {
        self.view.endEditing(true)
        var phValueError = false
        let datePicker = self.view.viewWithTag(TAG_DATE_PICKER) as! UIDatePicker
        let date: NSDate = datePicker.date
        let phValue = self.view.viewWithTag(TAG_INPUT_PH) as! UITextField
        
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
        if (phValue.text != nil) { entry["ph"] = NSString(string: phValue.text!).floatValue } else {
            phValueError = true
            showError()
            //phSubmissionStatus.text = "Error: Your pH value is empty"
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
                    phValueError = true
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if phValueError == true {
                        print("Error:\n \(error)")
                        self.showError()
                    } else {
                        let alertController = UIAlertController(title: "Submission Successfull!", message:String("You successfully submitted \n pH: \(phValue.text!)"), preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        self.valueDateSelected.text = String("Last submission: pH: \(phValue.text!) \n Time: \(formatter.stringFromDate(date))")
                    }
                }
                
                
            }
            task.resume()
        } catch {
            print("Error:\n \(error)")
            self.phSubmissionStatus.text = "Error:\n \(error)"
        }
    }
}