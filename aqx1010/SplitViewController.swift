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

let TAG_DATE_PICKER = 4711
let TAG_TEMP_INPUT = 4712
let API_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss'Z'"
//let AQX_BASE_URL = "https://aquaponics.systemsbiology.net"
let AQX_BASE_URL = "http://eric.systemsbiology.net:5000"
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

class AqxMeasureTempController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func submit(sender: AnyObject) {
        let datePicker = self.view.viewWithTag(TAG_DATE_PICKER) as! UIDatePicker
        let date: NSDate = datePicker.date
        let tempValue = self.view.viewWithTag(TAG_TEMP_INPUT) as! UITextField
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
        entry["temp"] = NSString(string: tempValue.text!).floatValue
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
        /*
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
        }*/
    }
}
