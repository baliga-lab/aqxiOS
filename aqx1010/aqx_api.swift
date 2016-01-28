//
//  aqx_api.swift
//  aqx1010
//
//  Created by Baliga Lab on 1/27/16.
//  Copyright © 2016 Baliga Lab. All rights reserved.
//

import Foundation

let API_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss'Z'"
let AQX_BASE_URL = "https://aquaponics.systemsbiology.net"
//let AQX_BASE_URL = "http://eric.systemsbiology.net:5000"
let API_BASE_URL = AQX_BASE_URL + "/api/v1.0"

// generic function for API get call
func requestData(url: NSURL, fun: (NSDictionary) -> Void) {
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    let authToken = NSUserDefaults.standardUserDefaults().objectForKey("GoogleAuthToken") as! String
    
    let authString = "Bearer \(authToken)"
    config.HTTPAdditionalHeaders = ["Authorization": authString]
    let session = NSURLSession(configuration: config)
    let task = session.dataTaskWithURL(url) {(data, response, error) in
        let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
        print(s)
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(s!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            fun(json)
        } catch {
        }
    }
    task.resume()
}

func apiGetDetails(uid: String, fun: (NSDictionary) -> Void) {
    let url = NSURL(string: API_BASE_URL + "/system/" + uid)
    print(url)
    requestData(url!, fun: fun)
}

func apiGetMeasurements(uid: String, fun: (NSDictionary) -> Void) {
    let url = NSURL(string: API_BASE_URL + "/measurements/" + uid)
    print(url)
    requestData(url!, fun: fun)
}