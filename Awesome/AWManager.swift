//
//  AWManager.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/21/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Cocoa

class AWManager: AWApplicationJSInterface {
    
    // A map of pid (NSNumber) to application (AWApplication)
    let apps:NSMutableDictionary = NSMutableDictionary()
    let jsApp: AWJSApplication
    let appNotification: ApplicationNotification?
    
    init(jsApp: AWJSApplication) {
        self.jsApp = jsApp
        // get all applications and watch for new ones.
        var apps = AWApplication.applications()
        for app in apps {
            var key = NSNumber(int: app.pid)
            self.apps.setObject(app, forKey: key)
        }
        appNotification = ApplicationNotification(manager: self)
        
    }
    
    func applicationEvent(event: NSString, runningApp: NSRunningApplication) {
        println("application event " + event)
        println(runningApp.processIdentifier)
        var app: AWApplication?
        // Get an application instance, either an existing one or create a new one
        if (event == "launched") {
            app = AWApplication(app: runningApp)
            addApplication(app!)
        } else {
            var key = NSNumber(int: runningApp.processIdentifier)
            app = apps.objectForKey(key) as AWApplication?
        }
        
        if (app != nil) {
            // Trigger an event
            jsApp.triggerEvent(event, app: app!)
            
            // Remove the terminated app
            if (event == "terminated") {
                removeApplication(app!)
            }
        }
    }
    
    func addApplication(app: AWApplication) {
        apps.setObject(app, forKey: NSNumber(int: app.pid))
        println("adding application: " + String(app.pid))
    }
    
    func removeApplication(app: AWApplication) {
        apps.removeObjectForKey(NSNumber(int: app.pid))
        println("removing application: " + String(app.pid))
    }
    
    func applications() -> [AWApplication] {
        var keys:[NSNumber] = apps.allKeys as [NSNumber]
        return keys.map({(pid:NSNumber) -> AWApplication in
            return self.apps.objectForKey(pid) as AWApplication
        });
    }
    
    func activate(pid: pid_t) -> Bool {
        var key = NSNumber(int: pid)
        var app:AWApplication? = apps.objectForKey(key) as AWApplication?
        if app != nil {
            return app!.activate()
        } else {
            println("application wasn't found for pid")
            return false
        }
    }
    
}