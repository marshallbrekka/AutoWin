//
//  Window.swift
//  Awesome
//
//  Created by Marshall Brekka on 3/27/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Cocoa

class AWWindow {
    let ref:AXUIElementRef
    let id: UInt
    
    init(ref:AXUIElementRef) {
        self.ref = ref
        id = CFHash(ref)
    }
    
    func title() -> String? {
        return AWAccessibilityAPI.getAttribute(self.ref, property: NSAccessibilityTitleAttribute) as String?
    }
    
    func size() -> CGSize {
        var size = CGSize()
        return AWAccessibilityAPI.getValueAttribute(self.ref,
            property: NSAccessibilitySizeAttribute,
            type: AXValueType.CGSize,
            destination:&size)
    }
    
    func position() -> CGPoint {
        var point = CGPoint()
        return AWAccessibilityAPI.getValueAttribute(self.ref,
            property: NSAccessibilityPositionAttribute,
            type: AXValueType.CGPoint,
            destination:&point)
    }
    
    class func isWindow(ref:AXUIElementRef) -> Bool {
        print("IS WINDOW")
        let role:String? = AWAccessibilityAPI.getAttribute(ref, property: NSAccessibilityRoleAttribute) as String?
        print("IS WINDOW", role)
        // The role attribute on a window can potentially be something
        // other than kAXWindowRole (e.g. Emacs does not claim kAXWindowRole)
        // so we will do the simple test first, but then also attempt to duck-type
        // the object, to see if it has a property that any window should have
        if role == nil {
            return false
        } else if role! == NSAccessibilityWindowRole {
            let subrole:String? = AWAccessibilityAPI.getAttribute(ref, property: NSAccessibilitySubroleAttribute) as String?
            return (subrole == nil ||
                    subrole! == NSAccessibilityStandardWindowSubrole)
        } else {
            print("window doesn't have standard role")
            return AWAccessibilityAPI.getAttribute(ref, property: NSAccessibilityMinimizedAttribute) as String? != nil
        }
    }
}