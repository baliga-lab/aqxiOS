//
//  pHViewController.swift
//  aqx1010
//
//  Created by Serdar Turkarslan on 12/18/15.
//  Copyright © 2015 Baliga Lab. All rights reserved.
//

import UIKit

class pHViewController: UIViewController, UITextFieldDelegate {
    
    let TAG_SYSTEM_NAME      = 4711
    let TAG_SYSTEM_TECHNIQUE = 4712
    
    let TAG_DATE_PICKER    = 4711
    let TAG_INPUT_TEMP     = 4712
    
    let TAG_INPUT_PH       = 47130
    let TAG_SLIDER_PH      = 47200
    
    
    @IBOutlet weak var phPreview: UIView!
    
    @IBOutlet weak var phSlider: UISlider!
    let phCGColors = [rgb2CGColor(0xfaac59), rgb2CGColor(0xee8243), rgb2CGColor(0xe35744), rgb2CGColor(0xe93e4d), rgb2CGColor(0xea185e)]
    let phUIColors = [rgb2UIColor(0xfaac59), rgb2UIColor(0xee8243), rgb2UIColor(0xe35744), rgb2UIColor(0xe93e4d), rgb2UIColor(0xea185e)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let phSlider = self.view.viewWithTag(TAG_SLIDER_PH) as! UISlider
        phSlider.layer.insertSublayer(makeGradient(phSlider.bounds, colors: phCGColors), atIndex: 0)
//        phSlider.setThumbImage(UIImage(named: "slider-control.png" ), forState: .Normal)
//        phSlider.setMinimumTrackImage(UIImage(named: "slider-highlight.png" ), forState: .Normal)
//        phSlider.setMaximumTrackImage(UIImage(named: "slider-bckg.png" ), forState: .Normal)
        
        phPreview.backgroundColor = UIColor(red: 0.89, green: 0.34, blue: 0.27, alpha: 1)

        (self.view.viewWithTag(TAG_INPUT_PH) as! UITextField).delegate = self
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
    
    func makeGradient(bounds: CGRect, colors: [CGColor]) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = phSlider.bounds
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
        let datePicker = self.view.viewWithTag(TAG_DATE_PICKER) as! UIDatePicker
        let date: NSDate = datePicker.date
        let phValue = self.view.viewWithTag(TAG_INPUT_PH) as! UITextField
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = API_DATE_FORMAT
        let uid = (self.tabBarController as! AqxSystemTabController).uid
        print("date: " + formatter.stringFromDate(date))
        
        let authToken = NSUserDefaults.standardUserDefaults().objectForKey("GoogleAuthToken") as! String
        let url = NSURL(string: API_BASE_URL + "/measurements/" + uid)
        print(url)
        
        // data: {"measurements": [{"time": <time>, "temp": <value>, ...}]}
        let request = NSMutableURLRequest(URL: url!)
        let data = NSMutableDictionary()
        let measurements = NSMutableArray()
        let entry = NSMutableDictionary()
        entry["time"] = formatter.stringFromDate(date)
        if (phValue.text != nil) { entry["ph"] = NSString(string: phValue.text!).floatValue }
        
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