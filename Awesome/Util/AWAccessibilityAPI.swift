//
//  AccessibilityAPI.swift
//  Awesome

import Foundation

class AWAccessibilityAPI {
    
    class func getAttribute<T>(ref: AXUIElementRef, property: String) -> T? {
        var pointer: Unmanaged<AnyObject>?
        var status:AXError = AXUIElementCopyAttributeValue(ref, property, &pointer)
        if status != AXError(kAXErrorSuccess) {
            return nil
        } else {
            return pointer?.takeRetainedValue() as? T
        }
    }
    
    class func getAttributes<T: AnyObject>(ref: AXUIElementRef, property: String) -> [T]? {
        // get the number of values for the attribute
        var attributeCount: CFIndex = 0
        var countStatus:AXError = AXUIElementGetAttributeValueCount(ref, property, &attributeCount)
        if countStatus != AXError(kAXErrorSuccess) {
            return nil
        } else if attributeCount == 0 {
            return [T]()
        }
        
        // get the values for the attribute
        var pointer: Unmanaged<CFArray>?
        var status:AXError = AXUIElementCopyAttributeValues(ref, property, 0, attributeCount, &pointer)
        if status != AXError(kAXErrorSuccess) {
            return nil
        } else if pointer == nil {
            return nil
        }
        
        let array: Array<AnyObject>? = pointer?.takeRetainedValue()
        if array == nil {
            return nil
        } else {
            return array as? [T]
        }
    }
    
    class func setAttribute<T: AnyObject>(ref: AXUIElementRef, property: String, value: T) -> Bool {
        var status:AXError = AXUIElementSetAttributeValue(ref, property, value)
        return status != AXError(kAXErrorSuccess)
    }
    
    class func getValueAttribute<T>(ref: AXUIElementRef, property: String, type: AXValueType, inout destination: T) -> T {
        var value:AXValue = getAttribute(ref, property: property) as AXValue!
        return convertValue(value, type: type, destination: &destination)
    }
    
    /*
    Generic function for converting a AXValue to its real type.
    The destination can be one of CGSize, CGRect, CGRange, CGPoint.
    */
    class func convertValue<T>(value: AXValue, type: AXValueType, inout destination: T) -> T {
        var status: Boolean = AXValueGetValue(value, type, &destination )
        return destination
    }
}