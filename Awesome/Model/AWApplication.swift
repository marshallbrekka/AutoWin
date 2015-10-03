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
        let notifo:String = String(notification)
        print("notifo callback: " + notifo);
        print(pid)
        print(CFEqual(element, ref))
        print(element);
        if notifo == NSAccessibilityWindowCreatedNotification {
            let window = AWWindow(ref: element)
            print(window.title())
            print(window.size())
        } else {
            print("is the app ref equal")
            print(self.ref)
            print(CFEqual(element, ref))
        }
    }

    
    func watch() {
        observer = AWObserver(pid, callback: notificationCallback);
        observer!.addNotification(ref, notification: NSAccessibilityApplicationHiddenNotification)
        observer!.addNotification(ref, notification: NSAccessibilityWindowCreatedNotification)
        print("watching now")
    }
    
    func title() -> String {
        return app.localizedName!
    }
    
    func windows() -> [AWWindow] {
        var windowObjects: [AWWindow]! = []
        let windowRefs: [AXUIElementRef]? = AWAccessibilityAPI.getAttributes(self.ref, property: NSAccessibilityWindowsAttribute) as [AXUIElementRef]?
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
        let runningApps:[NSRunningApplication] =  workspace.runningApplications 
        var apps:[AWApplication] = []
        for runningApp in runningApps {
            apps.append(AWApplication(app: runningApp))
        }
        return apps
    }
}
