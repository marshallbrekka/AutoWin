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
    
    init(app:NSRunningApplication) {
        self.app = app
        pid = app.processIdentifier
        ref = AXUIElementCreateApplication(pid).takeRetainedValue()
    }
    
    func activate() -> Bool {
        return AWAccessibilityAPI.setAttribute(
            ref,
            property: NSAccessibilityFrontmostAttribute,
            value: true)
    }
    
    func title() -> String {
        if (app.localizedName == nil) {
            return ""
        } else {
            return app.localizedName!
        }
    }
    
    class func isSupportedApplication(app: AWApplication) -> Bool {
        print("getting application role", NSDate().timeIntervalSince1970)
        let role = AWAccessibilityAPI.getAttribute(app.ref, property: NSAccessibilityRoleAttribute) as String?
        print("got application role", NSDate().timeIntervalSince1970)
        if role != nil {
            return role! == NSAccessibilityApplicationRole
        } else {
            return false
        }
    }
}
