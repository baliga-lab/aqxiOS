//
//  SocialViewController.swift
//  aqx1010
//
//  Created by Serdar Turkarslan on 1/3/16.
//  Copyright © 2016 Baliga Lab. All rights reserved.
//

import UIKit

class SocialViewController: UIViewController {
    
    
    @IBOutlet weak var facebookView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: "https://www.facebook.com/groups/ProjectFeed1010/")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            
            (data, response, error) in
            
            if error == nil {
                
                var urlContent = NSString(data: data!, encoding:NSUTF8StringEncoding)
                
                dispatch_async(dispatch_get_main_queue()){
                    self.facebookView.loadHTMLString(urlContent! as String, baseURL: nil)
                }
            }
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
