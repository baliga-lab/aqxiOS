//
//  NitriteViewController.swift
//  aqx1010
//
//  Created by Serdar Turkarslan on 1/2/16.
//  Copyright © 2016 Baliga Lab. All rights reserved.
//

import UIKit

class NitriteViewController: UIViewController, UITextFieldDelegate {
    
    var uid: String = ""
    @IBOutlet weak var no2Preview: UIView!
    @IBOutlet weak var nitriteSlider: UISlider!
    
    let no2CGColors = [rgb2CGColor(0xfefcf0), rgb2CGColor(0xfdf6f1), rgb2CGColor(0xfcecec), rgb2CGColor(0xfdb8d4), rgb2CGColor(0xf6a1c0), rgb2CGColor(0xfa91b3)]
    let no2UIColors = [rgb2UIColor(0xfefcf0), rgb2UIColor(0xfdf6f1), rgb2UIColor(0xfcecec), rgb2UIColor(0xfdb8d4), rgb2UIColor(0xf6a1c0), rgb2UIColor(0xfa91b3)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nitriteSlider.layer.insertSublayer(makeGradient(nitriteSlider.bounds, colors: no2CGColors), atIndex: 0)
        
        no2Preview.backgroundColor = UIColor(red: 0.98, green: 0.92, blue: 0.92, alpha: 1)
        no2Preview.layer.borderWidth = 1
        (self.view.viewWithTag(TAG_INPUT_NITRITE) as! UITextField).delegate = self
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
    
    func makeGradient(bounds: CGRect, colors: [CGColor]) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = colors
        return gradient
    }
    
    @IBAction func nitriteSliderValueChanged(sender: UISlider) {
        
        let textfield = self.view.viewWithTag(TAG_INPUT_NITRITE) as! UITextField
        let s = NSString(format: "%.2f", sender.value)
        textfield.text = s as String
        // compute preview color
        let stops = no2UIColors
        let numStops = stops.count
        let range = (sender.maximumValue - sender.minimumValue)
        let segmentLength = range / Float(numStops - 1)
        
        // TODO: This is the global fraction, need fraction between stops
        let fraction = (sender.value - sender.minimumValue) / range
        
        let segment = Int((sender.value - sender.minimumValue) / segmentLength)
        print("value: ", sender.value, " range: ", range, " segment: ", segment, " fraction: ", fraction)
        no2Preview.backgroundColor = UIColor(red: CGFloat(1.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: 1.0)
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
        no2Preview.backgroundColor = UIColor(red: CGFloat(redInterp), green: CGFloat(greenInterp), blue: CGFloat(blueInterp), alpha: 1.0)
        textfield.backgroundColor = UIColor(red: CGFloat(redInterp), green: CGFloat(greenInterp), blue: CGFloat(blueInterp), alpha: 0.5)
    }
    
    @IBAction func submit(sender: AnyObject) {
        self.view.endEditing(true)
        let datePicker = self.view.viewWithTag(TAG_DATE_PICKER) as! UIDatePicker
        let date: NSDate = datePicker.date
        let nitriteValue = self.view.viewWithTag(TAG_INPUT_NITRITE) as! UITextField
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = API_DATE_FORMAT
        print("date: " + formatter.stringFromDate(date))
        
        let authToken = NSUserDefaults.standardUserDefaults().objectForKey("GoogleAuthToken") as! String
        let url = NSURL(string: API_BASE_URL + "/measurements/" + self.uid)
        print("Splitview URL \(url)")
        
        // data: {"measurements": [{"time": <time>, "temp": <value>, ...}]}
        let request = NSMutableURLRequest(URL: url!)
        let data = NSMutableDictionary()
        let measurements = NSMutableArray()
        let entry = NSMutableDictionary()
        entry["time"] = formatter.stringFromDate(date)
        if (nitriteValue.text != nil) { entry["nitrite"] = NSString(string: nitriteValue.text!).floatValue }
        
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
                let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(s)
            }
            task.resume()
        } catch {
        }
    }

    
    

}
