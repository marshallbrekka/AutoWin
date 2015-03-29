//
//  Application.swift
//  Awesome
//
//  Created by Marshall Brekka on 3/27/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Cocoa
import Carbon



class Application {
    let app:NSRunningApplication
    let ref:AXUIElementRef
    let pid:pid_t
    
    init(app:NSRunningApplication) {
        self.app = app
        pid = app.processIdentifier
        ref = AXUIElementCreateApplication(pid).takeRetainedValue()
    }
    
    func title() -> String {
        return app.localizedName!
    }
    
    func windows() -> [Window] {
        var windowObjects: [Window]! = []
        var windows: Unmanaged<CFArray>?
        
        var result:AXError = AXUIElementCopyAttributeValues(ref, NSAccessibilityWindowsAttribute, 0, 100, &windows)
        var converted = AXError(kAXErrorSuccess)
        if result == converted {
            //println("did get windows" + String(result))
            var win:NSArray = windows!.takeRetainedValue() as NSArray
            for window in win {
                var windowObject:Window = Window(ref: window as AXUIElementRef)
                if windowObject.isWindow() {
                    windowObjects.append(windowObject)
                }
            }
        } else {
//            println("did not get windows" + String(result))
        }
        
       
        return windowObjects
    }
    
    class func applications() -> [Application] {
        let workspace = NSWorkspace.sharedWorkspace()
        let runningApps:[NSRunningApplication] =  workspace.runningApplications as [NSRunningApplication]
        var apps:[Application] = []
        for runningApp in runningApps {
            apps.append(Application(app: runningApp))
        }
        return apps
    }
}
