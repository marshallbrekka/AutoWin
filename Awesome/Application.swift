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
        var windowRefs: [AXUIElementRef]? = AccessibilityAPI.getAttributes(self.ref, property: NSAccessibilityWindowsAttribute) as [AXUIElementRef]?
        if windowRefs != nil {
            windowRefs?.map({
                if Window.isWindow($0) {
                    windowObjects.append(Window(ref: $0))
                }
            }) as [Void]!
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
