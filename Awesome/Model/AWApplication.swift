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



class AWApplication {
    let app:NSRunningApplication
    let ref:AXUIElementRef
    let pid:pid_t
    var observer:AWObserver?;

    
    init(app:NSRunningApplication) {
        self.app = app
        pid = app.processIdentifier
        ref = AXUIElementCreateApplication(pid).takeRetainedValue()

        if pid == 198 {
            watch()
        } else {
            self.observer = nil
        }
    }
    
    func activate() -> Bool {
        return AWAccessibilityAPI.setAttribute(
            ref,
            property: NSAccessibilityFrontmostAttribute,
            value: true)
    }
    
    func notificationCallback(ob: AXObserver!, element:AXUIElement!, notification:CFString!) {
        println("notifo callback: " + notification);
        println(pid)
        println(CFEqual(element, ref))
        println(element);
        if notification == NSAccessibilityWindowCreatedNotification {
            var window = AWWindow(ref: element)
            println(window.title())
            println(window.size())
        } else {
            println("is the app ref equal")
            println(self.ref)
            println(CFEqual(element, ref))
        }
    }

    
    func watch() {
        observer = AWObserver(pid, notificationCallback);
        observer!.addNotification(ref, notification: NSAccessibilityApplicationHiddenNotification)
        observer!.addNotification(ref, notification: NSAccessibilityWindowCreatedNotification)
        println("watching now")
    }
    
    func title() -> String {
        return app.localizedName!
    }
    
    func windows() -> [AWWindow] {
        var windowObjects: [AWWindow]! = []
        var windowRefs: [AXUIElementRef]? = AWAccessibilityAPI.getAttributes(self.ref, property: NSAccessibilityWindowsAttribute) as [AXUIElementRef]?
        if windowRefs != nil {
            windowRefs?.map({
                if AWWindow.isWindow($0) {
                    windowObjects.append(AWWindow(ref: $0))
                }
            }) as [Void]!
        }
        return windowObjects
    }
    
    class func applications() -> [AWApplication] {
        let workspace = NSWorkspace.sharedWorkspace()
        let runningApps:[NSRunningApplication] =  workspace.runningApplications as [NSRunningApplication]
        var apps:[AWApplication] = []
        for runningApp in runningApps {
            apps.append(AWApplication(app: runningApp))
        }
        return apps
    }
}
