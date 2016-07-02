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
    let pid: pid_t
    
    init(ref:AXUIElementRef, pid: pid_t) {
        self.ref = ref
        id = CFHash(ref)
        self.pid = pid
    }
    
    deinit {
        print("deinit awwindow")
    }
    
    func title() -> String? {
        return AWAccessibilityAPI.getAttribute(self.ref, property: NSAccessibilityTitleAttribute) as String?
    }
    
    func getSize() -> CGSize {
        var size = CGSize()
        return AWAccessibilityAPI.getValueAttribute(self.ref,
            property: NSAccessibilitySizeAttribute,
            type: AXValueType.CGSize,
            destination:&size)
    }
    
    func getPosition() -> CGPoint {
        var point = CGPoint()
        return AWAccessibilityAPI.getValueAttribute(self.ref,
            property: NSAccessibilityPositionAttribute,
            type: AXValueType.CGPoint,
            destination:&point)
    }
    
    func getFrame() -> NSDictionary {
        let size = getSize()
        let position = getPosition()
        return ["x": position.x,
                "y": position.y,
                "width": size.width,
                "height": size.height]
    }
    
    func becomeMain() -> Bool {
        return AWAccessibilityAPI.setAttribute(
            ref,
            property: NSAccessibilityMainAttribute,
            value: kCFBooleanTrue)
    }
    
    func setFrame(frame: NSDictionary) -> Bool {
        let x = frame.objectForKey("x") as? Int
        let y = frame.objectForKey("y") as? Int
        let width = frame.objectForKey("width") as? Int
        let height = frame.objectForKey("height") as? Int
        if (x == nil || y == nil || width == nil || height == nil) {
            return false
        } else {
            var size = CGSize(width: width!, height: height!)
            var position = CGPoint(x: x!, y: y!)
            let positionResult = AWAccessibilityAPI.setValueAttribute(
                    ref,
                    property: NSAccessibilityPositionAttribute,
                    type: AXValueType.CGPoint,
                    source: &position)
            print("POSITIONED!", positionResult)
            if positionResult {
                let sizeResult = AWAccessibilityAPI.setValueAttribute(
                    ref,
                    property: NSAccessibilitySizeAttribute,
                    type: AXValueType.CGSize,
                    source: &size)
                print("SIZE RESULT", sizeResult, size)
                return sizeResult
            } else {
                return false
            }
        }
    }
    
    func close() -> Bool {
        let closeButton = AWAccessibilityAPI.getAttribute(
            ref,
            property: NSAccessibilityCloseButtonAttribute) as AXUIElementRef?
                
        if closeButton != nil {
            return AWAccessibilityAPI.performAction(closeButton!, action: kAXPressAction)
        } else {
            return false
        }
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
            let minimizedAttr = AWAccessibilityAPI.getAttribute(ref, property: NSAccessibilityMinimizeButtonAttribute) as AnyObject?
            print("window doesn't have standard role", minimizedAttr)
            return minimizedAttr != nil
            
        }
    }
}