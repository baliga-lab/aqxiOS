//
//  SplitViewController.swift
//  aqx1010
//
//  Created by Baliga Lab on 11/16/15.
//  Copyright © 2015 Baliga Lab. All rights reserved.
//

import UIKit

let TAG_SYSTEM_NAME      = 4711
let TAG_SYSTEM_TECHNIQUE = 4712

let TAG_DATE_PICKER    = 4711
let TAG_INPUT_TEMP     = 4712
let TAG_INPUT_PH       = 4713
let TAG_INPUT_AMMONIUM = 4714
let TAG_INPUT_NITRATE  = 4715
let TAG_INPUT_NITRITE  = 4716
let TAG_INPUT_DIO      = 4717
let TAG_INPUT_LIGHT    = 4718

let TAG_SLIDER_PH      = 4720
let TAG_SLIDER_NH4     = 4721
let TAG_SLIDER_NO3     = 4722
let TAG_SLIDER_NO2     = 4723

let API_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss'Z'"
let AQX_BASE_URL = "https://aquaponics.systemsbiology.net"
//let AQX_BASE_URL = "http://eric.systemsbiology.net:5000"
let API_BASE_URL = AQX_BASE_URL + "/api/v1.0"


class MySplitViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("mysplitview loaded")
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryOverlay
    }
}

class AqxSystemInfo {
    let uid: String
    let name: String
    let thumbnailURL: String
    
    init(aUID: String, aName: String, aURL: String) {
        uid = aUID
        name = aName
        thumbnailURL = aURL
    }
}

class MyTableViewController: UITableViewController {
    var systems: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let authToken = NSUserDefaults.standardUserDefaults().objectForKey("GoogleAuthToken") as! String
        let url = NSURL(string: API_BASE_URL + "/systems")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let authString = "Bearer \(authToken)"
        config.HTTPAdditionalHeaders = ["Authorization": authString]
        // in table view
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithURL(url!) {(data, response, error) in
            if (response != nil) {
                let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("in TABLEVIEW")
                print(s)
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(s!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers)
                    let systems = json["systems"]! as! [NSDictionary]
                    for system: NSDictionary in systems {
                        print(system["uid"])
                        print(system["name"])
                        print(system["thumb_url"])
                        self.systems.addObject(AqxSystemInfo(aUID: system["uid"] as! String,
                            aName: system["name"] as! String, aURL: system["thumb_url"] as! String))
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                } catch {
                }
            } else {
                print(error)
            }
        }
        task.resume()

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("# systems: \(systems.count)")
        return systems.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "LabelCell", forIndexPath: indexPath)
        
        // Configure the cell...
        let system = systems[indexPath.row] as! AqxSystemInfo
        //cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        cell.textLabel?.text = "\(system.name)"
        let url: String = AQX_BASE_URL + "\(system.thumbnailURL)"
        let thumbnail = NSURL(string: url)
        cell.imageView?.image = UIImage(data: NSData(contentsOfURL: thumbnail!)!)
        return cell
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Systems"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("tapped \(indexPath.row)")
        if (self.splitViewController!.collapsed) {
            let controller = storyboard?.instantiateViewControllerWithIdentifier("DetailTabView")
            let detailController = controller as! AqxSystemTabController
            detailController.uid = (systems[indexPath.row] as! AqxSystemInfo).uid
            self.showDetailViewController(controller!, sender: self)
        } else {
            let detailView = splitViewController?.viewControllers[1]
            // TODO
            
        }
    }
}

class AqxSystemTabController : UITabBarController {
    var uid: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class AqxSystemDetailViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = (self.tabBarController as! AqxSystemTabController).uid
        print("load the details")
        
        let authToken = NSUserDefaults.standardUserDefaults().objectForKey("GoogleAuthToken") as! String
        let url = NSURL(string: API_BASE_URL + "/system/" + uid)
        print(url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let authString = "Bearer \(authToken)"
        config.HTTPAdditionalHeaders = ["Authorization": authString]
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithURL(url!) {(data, response, error) in
            let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(s)
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(s!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers)
                let details = json as! NSDictionary
                let sysname = (details["system_details"] as! NSDictionary)["name"] as! String
                let technique = (details["system_details"] as! NSDictionary)["aqx_technique"] as! String
                dispatch_async(dispatch_get_main_queue(), {
                    let systemNameView = self.view.viewWithTag(TAG_SYSTEM_NAME) as! UITextView
                    systemNameView.text = sysname
                    let techniqueView = self.view.viewWithTag(TAG_SYSTEM_TECHNIQUE) as! UITextView
                    techniqueView.text = technique
                })
            } catch {
            }
        }
        task.resume()
    }
}

func rgb2Color(rgb: Int) -> CGColor {
    return UIColor(red: CGFloat(Double((rgb >> 16) & 0xff) / 255.0),
                   green: CGFloat(Double((rgb >> 8) & 0xff) / 255.0),
                   blue: CGFloat(Double(rgb & 0xff) / 255.0), alpha: 1.0).CGColor
}

class AqxMeasurementsController : UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let phSlider = self.view.viewWithTag(TAG_SLIDER_PH) as! UISlider
        let phColors = [rgb2Color(0xfaac59), rgb2Color(0xee8243), rgb2Color(0xe35744), rgb2Color(0xe93e4d), rgb2Color(0xea185e)]
        phSlider.layer.insertSublayer(makeGradient(phSlider.bounds, colors: phColors), atIndex: 0)

        let nh4Slider = self.view.viewWithTag(TAG_SLIDER_NH4) as! UISlider
        let nh4Colors = [rgb2Color(0xffe26d), rgb2Color(0xdde093), rgb2Color(0xc7dd8a), rgb2Color(0x9dd29c), rgb2Color(0x88b789)]
        nh4Slider.layer.insertSublayer(makeGradient(nh4Slider.bounds, colors: nh4Colors), atIndex: 0)
        
        let no3Slider = self.view.viewWithTag(TAG_SLIDER_NO3) as! UISlider
        let no3Colors = [rgb2Color(0xfffaed), rgb2Color(0xf9abcc), rgb2Color(0xf581b2), rgb2Color(0xe92b93), rgb2Color(0xde0084), rgb2Color(0xd50078)]
        no3Slider.layer.insertSublayer(makeGradient(no3Slider.bounds, colors: no3Colors), atIndex: 0)
        
        let no2Slider = self.view.viewWithTag(TAG_SLIDER_NO2) as! UISlider
        let no2Colors = [rgb2Color(0xfefcf0), rgb2Color(0xfdf6f1), rgb2Color(0xfcecec), rgb2Color(0xfdb8d4), rgb2Color(0xf6a1c0), rgb2Color(0xfa91b3)]
        no2Slider.layer.insertSublayer(makeGradient(no2Slider.bounds, colors: no2Colors), atIndex: 0)
        
        (self.view.viewWithTag(TAG_INPUT_TEMP) as! UITextField).delegate = self
        (self.view.viewWithTag(TAG_INPUT_PH) as! UITextField).delegate = self
        (self.view.viewWithTag(TAG_INPUT_AMMONIUM) as! UITextField).delegate = self
        (self.view.viewWithTag(TAG_INPUT_NITRATE) as! UITextField).delegate = self
        (self.view.viewWithTag(TAG_INPUT_NITRITE) as! UITextField).delegate = self
        (self.view.viewWithTag(TAG_INPUT_DIO) as! UITextField).delegate = self
        (self.view.viewWithTag(TAG_INPUT_LIGHT) as! UITextField).delegate = self
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
        gradient.frame = bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = colors
        return gradient
    }
    
    @IBAction func phSliderValueChanged(sender: UISlider) {
        let textfield = self.view.viewWithTag(TAG_INPUT_PH) as! UITextField
        let s = NSString(format: "%.2f", sender.value)
        textfield.text = s as String
    }

    @IBAction func ammoniumSliderValueChanged(sender: UISlider) {
        let textfield = self.view.viewWithTag(TAG_INPUT_AMMONIUM) as! UITextField
        let s = NSString(format: "%.2f", sender.value)
        textfield.text = s as String
    }

    @IBAction func nitrateSliderValueChanged(sender: UISlider) {
        let textfield = self.view.viewWithTag(TAG_INPUT_NITRATE) as! UITextField
        let s = NSString(format: "%.2f", sender.value)
        textfield.text = s as String
    }

    @IBAction func nitriteSliderValueChanged(sender: UISlider) {
        let textfield = self.view.viewWithTag(TAG_INPUT_NITRITE) as! UITextField
        let s = NSString(format: "%.2f", sender.value)
        textfield.text = s as String
    }
    
    @IBAction func submit(sender: AnyObject) {
        self.view.endEditing(true)
        let datePicker = self.view.viewWithTag(TAG_DATE_PICKER) as! UIDatePicker
        let date: NSDate = datePicker.date
        let tempValue = self.view.viewWithTag(TAG_INPUT_TEMP) as! UITextField
        let phValue = self.view.viewWithTag(TAG_INPUT_PH) as! UITextField
        let ammoniumValue = self.view.viewWithTag(TAG_INPUT_AMMONIUM) as! UITextField
        let nitrateValue = self.view.viewWithTag(TAG_INPUT_NITRATE) as! UITextField
        let nitriteValue = self.view.viewWithTag(TAG_INPUT_NITRITE) as! UITextField
        let dioValue = self.view.viewWithTag(TAG_INPUT_DIO) as! UITextField
        let lightValue = self.view.viewWithTag(TAG_INPUT_DIO) as! UITextField
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = API_DATE_FORMAT
        let uid = (self.tabBarController as! AqxSystemTabController).uid
        print("date: " + formatter.stringFromDate(date))
        print("temperature: " + tempValue.text!)
        
        let authToken = NSUserDefaults.standardUserDefaults().objectForKey("GoogleAuthToken") as! String
        let url = NSURL(string: API_BASE_URL + "/measurements/" + uid)
        print(url)
        
        // data: {"measurements": [{"time": <time>, "temp": <value>, ...}]}
        let request = NSMutableURLRequest(URL: url!)
        let data = NSMutableDictionary()
        let measurements = NSMutableArray()
        let entry = NSMutableDictionary()
        entry["time"] = formatter.stringFromDate(date)
        if (tempValue.text != nil) { entry["temp"] = NSString(string: tempValue.text!).floatValue }
        if (phValue.text != nil) { entry["ph"] = NSString(string: phValue.text!).floatValue }
        if (ammoniumValue.text != nil) { entry["ammonium"] = NSString(string: ammoniumValue.text!).floatValue }
        if (nitrateValue.text != nil) { entry["nitrate"] = NSString(string: nitrateValue.text!).floatValue }
        if (nitriteValue.text != nil) { entry["nitrite"] = NSString(string: nitriteValue.text!).floatValue }
        if (dioValue.text != nil) { entry["o2"] = NSString(string: dioValue.text!).floatValue }
        if (lightValue.text != nil) { entry["light"] = NSString(string: lightValue.text!).floatValue }

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
