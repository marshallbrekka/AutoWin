//
//  Window.swift
//  Awesome
//
//  Created by Marshall Brekka on 3/27/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Cocoa

class Window {
    let ref:AXUIElementRef
    //let id:CGWindowID // uint32_t
    init(ref:AXUIElementRef) {
        self.ref = ref
        //_AXUIElementGetWindow(ref, &id);
    }
    
    func title() -> String? {
        return AccessibilityAPI.getAttribute(self.ref, property: NSAccessibilityTitleAttribute) as String?
    }
    
    func size() -> CGSize {
        var size = CGSize()
        return AccessibilityAPI.getValueAttribute(self.ref,
            property: NSAccessibilitySizeAttribute,
            type: kAXValueCGSizeType,
            destination:&size)
    }
    
    func position() -> CGPoint {
        var point = CGPoint()
        return AccessibilityAPI.getValueAttribute(self.ref,
            property: NSAccessibilityPositionAttribute,
            type: kAXValueCGPointType,
            destination:&point)
    }
    
    class func isWindow(ref:AXUIElementRef) -> Bool {
        var role:String? = AccessibilityAPI.getAttribute(ref, property: NSAccessibilityRoleAttribute) as String?
        // The role attribute on a window can potentially be something
        // other than kAXWindowRole (e.g. Emacs does not claim kAXWindowRole)
        // so we will do the simple test first, but then also attempt to duck-type
        // the object, to see if it has a property that any window should have
        if role! == NSAccessibilityWindowRole {
            return true
        } else {
            return AccessibilityAPI.getAttribute(ref, property: NSAccessibilityMinimizedAttribute) as String? != nil
        }
    }
}