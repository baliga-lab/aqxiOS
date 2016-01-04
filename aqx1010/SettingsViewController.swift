//
//  SettingsViewController.swift
//  aqx1010
//
//  Created by Serdar Turkarslan on 1/3/16.
//  Copyright © 2016 Baliga Lab. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var statusText: UILabel!
    
    @IBAction func didTapSignOut(sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        statusText.text = "Signed out."
        //navigationController!.popViewControllerAnimated(true)
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("loginscreen")
        self.showViewController(vc as! UIViewController, sender: vc)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
}
