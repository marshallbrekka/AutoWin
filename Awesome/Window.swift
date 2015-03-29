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
    
    func getAttribute<T>(property: String) -> T? {
        var ptr: Unmanaged<AnyObject>?
        if AXUIElementCopyAttributeValue(self.ref, property, &ptr) != AXError(kAXErrorSuccess) { return nil }
        //return ptr.map { $0.takeRetainedValue() as T }
        return ptr?.takeRetainedValue() as? T
    }
    
    func title() -> String? {
        return getAttribute(NSAccessibilityTitleAttribute) as String?
    }
    
    func isWindow() -> Bool {
        var role:String? = getAttribute(NSAccessibilityRoleAttribute) as String?
        // The role attribute on a window can potentially be something
        // other than kAXWindowRole (e.g. Emacs does not claim kAXWindowRole)
        // so we will do the simple test first, but then also attempt to duck-type
        // the object, to see if it has a property that any window should have
        return role! == NSAccessibilityWindowRole ||
            getAttribute(NSAccessibilityMinimizedAttribute) as String? != nil
    }

}