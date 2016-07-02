//
//  AppDelegate.swift
//  AwesomeHelper
//
//  Created by Marshall Brekka on 11/5/15.
//  Copyright © 2015 Marshall Brekka. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
//    @IBOutlet weak var window: NSWindow!
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        print("started helper", NSBundle.mainBundle().bundleURL)
        let parentUrl = NSBundle.mainBundle().bundleURL.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent
        let config:[String:AnyObject] = NSDictionary() as! [String : AnyObject]
        do {
            try NSWorkspace.sharedWorkspace().launchApplicationAtURL(parentUrl!, options: NSWorkspaceLaunchOptions.Default, configuration: config)
        } catch {
             print("failed to launch", parentUrl!)
        }
        
        
        NSApplication.sharedApplication().terminate(self)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
}
