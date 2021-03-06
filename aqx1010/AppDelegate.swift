//
//  AppDelegate.swift
//  aqx1010
//
//  Created by Baliga Lab on 11/13/15.
//  Copyright © 2015 Baliga Lab. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    // GIDSignInDelegate
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
            print("ios8 login")
            return GIDSignIn.sharedInstance().handleURL(url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }

    func application(application: UIApplication,
        openURL url: NSURL, options: [String: AnyObject]) -> Bool {
            print("ios9 login")
            return GIDSignIn.sharedInstance().handleURL(url,
                sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                annotation: options[UIApplicationOpenURLOptionsAnnotationKey] as? String)
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                // Perform any operations on signed in user here.
                /*
                let userId = user.userID                  // For client-side use only!
                let idToken = user.authentication.idToken // Safe to send to the server
                let name = user.profile.name
                let email = user.profile.email
*/
                let refreshToken = user.authentication.refreshToken
                let authToken = user.authentication.accessToken
                print("refreshToken: " + refreshToken)
                /*
                let url = NSURL(string: "https://aquaponics.systemsbiology.net/api/v1.0/systems")
                let config = NSURLSessionConfiguration.defaultSessionConfiguration()
                let authString = "Bearer \(authToken)"
                print("tokenasg: " + authString)
                config.HTTPAdditionalHeaders = ["Authorization": authString]
                //NSUserDefaults.standardUserDefaults().objectForKey("GoogleRefreshToken")
*/
                NSUserDefaults.standardUserDefaults().setObject(refreshToken, forKey: "GoogleRefreshToken")
                NSUserDefaults.standardUserDefaults().setObject(authToken, forKey: "GoogleAuthToken")
                // in table view
                /*
                let session = NSURLSession(configuration: config)
                let task = session.dataTaskWithURL(url!) {(data, response, error) in
                    let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print(s)
                }
                task.resume()*/
                // ...
                let splitViewController = window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("StartViewController") as! UISplitViewController
                splitViewController.delegate = self
                window?.rootViewController = splitViewController
            } else {
                print("\(error.localizedDescription)")
            }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
        withError error: NSError!) {
            // Perform any operations when the user disconnects from app here.
            // ...
    }
    
    func splitViewController(splitViewController: UISplitViewController,
        collapseSecondaryViewController secondaryViewController: UIViewController,
        ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
            return true
    }
}
