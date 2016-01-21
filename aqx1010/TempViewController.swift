//
//  TempViewController.swift
//  aqx1010
//
//  Created by Serdar Turkarslan on 12/29/15.
//  Copyright © 2015 Baliga Lab. All rights reserved.
//

import UIKit

class TempViewController: UIViewController, UITextFieldDelegate {
    
    let TAG_DATE_PICKER    = 4711
    let TAG_INPUT_TEMP     = 47120
    
    var uid: String = ""
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.view.viewWithTag(TAG_INPUT_TEMP) as! UITextField).delegate = self

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
        let datePicker = self.view.viewWithTag(TAG_DATE_PICKER) as! UIDatePicker
        let date: NSDate = datePicker.date
        let tempValue = self.view.viewWithTag(TAG_INPUT_TEMP) as! UITextField
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = API_DATE_FORMAT
        print("date: " + formatter.stringFromDate(date))
        print("temperature: " + tempValue.text!)
        
        let authToken = NSUserDefaults.standardUserDefaults().objectForKey("GoogleAuthToken") as! String
        let url = NSURL(string: API_BASE_URL + "/measurements/" + self.uid)
        
        // data: {"measurements": [{"time": <time>, "temp": <value>, ...}]}
        let request = NSMutableURLRequest(URL: url!)
        let data = NSMutableDictionary()
        let measurements = NSMutableArray()
        let entry = NSMutableDictionary()
        entry["time"] = formatter.stringFromDate(date)
        if (tempValue.text != nil) { entry["temp"] = NSString(string: tempValue.text!).floatValue }

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
            self.statusLabel.text = "Submission successfull!"
            task.resume()
        } catch {
            self.statusLabel.text = "Error!"
    
        }
    }

}
