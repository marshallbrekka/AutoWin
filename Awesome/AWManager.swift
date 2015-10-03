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
    let windows:NSMutableDictionary = NSMutableDictionary()
    let jsApp: AWJSApplication
    let jsWindow: AWJSWindow
    
    init(jsApp: AWJSApplication, jsWindow: AWJSWindow) {
        self.jsApp = jsApp
        self.jsWindow = jsWindow
        // get all applications and watch for new ones.
        let apps = AWApplication.applications()
        for app in apps {
            initApp(app, triggerEvents: false);
        }
    }
    
    /*
    Takes an AWApplication object and adds it to the tracked apps,
    also gets all its windows and starts listening for window events.
    */
    func initApp(app: AWApplication, triggerEvents: Bool) {
        let appKey = NSNumber(int: app.pid)
        self.apps.setObject(app, forKey: appKey);
        if (triggerEvents) {
            print("app launched");
            jsApp.triggerEvent("launched", app: app);
        }

        let windows = app.windows();
        for window in windows {
            let windowId = NSNumber(unsignedInt: window.id);
            self.windows.setObject(window, forKey: windowId);
            jsWindow.triggerEvent("created", window: window);
        }
    }
    
    func destroyApp(app: AWApplication) {
        
    }
    
    func applicationEvent(event: NSString, runningApp: NSRunningApplication) {
        print("application event " + (event as String));
        print(runningApp.processIdentifier);
        var app: AWApplication?;
        // Get an application instance, either an existing one or create a new one
        if (event == "launched") {
            app = AWApplication(app: runningApp);
            initApp(app!, triggerEvents: true);
        } else {
            let key = NSNumber(int: runningApp.processIdentifier)
            app = apps.objectForKey(key) as! AWApplication?
        }
        
        if (app != nil) {
            // Trigger an event
            jsApp.triggerEvent(event as String, app: app!)
            
            // Remove the terminated app
            if (event == "terminated") {
                removeApplication(app!)
            }
        }
    }
    
    func removeApplication(app: AWApplication) {
        apps.removeObjectForKey(NSNumber(int: app.pid))
        print("removing application: " + String(app.pid))
    }
    
    func applications() -> [AWApplication] {
        let keys:[NSNumber] = apps.allKeys as! [NSNumber]
        return keys.map({(pid:NSNumber) -> AWApplication in
            return self.apps.objectForKey(pid) as! AWApplication
        });
    }
    
    func activate(pid: pid_t) -> Bool {
        let key = NSNumber(int: pid)
        let app:AWApplication? = apps.objectForKey(key) as! AWApplication?
        if app != nil {
            return app!.activate()
        } else {
            print("application wasn't found for pid")
            return false
        }
    }
    
}