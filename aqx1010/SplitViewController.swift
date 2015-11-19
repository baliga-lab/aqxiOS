//
//  SplitViewController.swift
//  aqx1010
//
//  Created by Baliga Lab on 11/16/15.
//  Copyright © 2015 Baliga Lab. All rights reserved.
//

import UIKit


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
        let url = NSURL(string: "https://aquaponics.systemsbiology.net/api/v1.0/systems")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let authString = "Bearer \(authToken)"
        config.HTTPAdditionalHeaders = ["Authorization": authString]
        // in table view
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithURL(url!) {(data, response, error) in
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
                self.tableView.reloadData()
            } catch {
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
        
        return cell
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Systems"
    }
}
