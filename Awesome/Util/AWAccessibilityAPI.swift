//
//  AccessibilityAPI.swift
//  Awesome

import Foundation

class AWAccessibilityAPI {
    
    class func getPid(ref: AXUIElementRef) -> pid_t {
        var pid:pid_t = 0
        AXUIElementGetPid(ref, &pid)
        return pid
    }
    
    class func getAttribute<T>(ref: AXUIElementRef, property: String) -> T? {
        var pointer:AnyObject?
        let status:AXError = AXUIElementCopyAttributeValue(ref, property, &pointer)
        if status != AXError.Success {
            return nil
        } else {
            return pointer as? T
        }
    }
    
    class func getAttributes<T: AnyObject>(ref: AXUIElementRef, property: String) -> [T]? {
        // get the number of values for the attribute
        var attributeCount: CFIndex = 0
        let countStatus:AXError = AXUIElementGetAttributeValueCount(ref, property, &attributeCount)
        if countStatus != AXError.Success {
            return nil
        } else if attributeCount == 0 {
            return [T]()
        }
        
        // get the values for the attribute
        var pointer: CFArray?
        let status:AXError = AXUIElementCopyAttributeValues(ref, property, 0, attributeCount, &pointer)
        if status != AXError.Success {
            return nil
        } else if pointer == nil {
            return nil
        }
        
        let array: Array<AnyObject>? = pointer as Array<AnyObject>?
        if array == nil {
            return nil
        } else {
            return array as? [T]
        }
    }
    
    class func setAttribute<T: AnyObject>(ref: AXUIElementRef, property: String, value: T) -> Bool {
        let status:AXError = AXUIElementSetAttributeValue(ref, property, value)
        return status != AXError.Success
    }
    
    class func getValueAttribute<T>(ref: AXUIElementRef, property: String, type: AXValueType, inout destination: T) -> T {
        let value:AXValue? = getAttribute(ref, property: property) as AXValue?
        if (value != nil) {
            return convertValue(value!, type: type, destination: &destination)
        } else {
            return destination;
        }
    }
    
    /*
    Generic function for converting a AXValue to its real type.
    The destination can be one of CGSize, CGRect, CGRange, CGPoint.
    */
    class func convertValue<T>(value: AXValue, type: AXValueType, inout destination: T) -> T {
        AXValueGetValue(value, type, &destination)
        return destination
    }
}