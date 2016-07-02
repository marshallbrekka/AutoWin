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
    
    class func isProcessTrusted() ->Bool {
        return AXIsProcessTrustedWithOptions(nil)
    }
    
    class func promptToTrustProcess() -> Bool {
        let dict = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String :kCFBooleanTrue]
        return AXIsProcessTrustedWithOptions(dict)
    }
    
    class func performAction(ref: AXUIElementRef, action: String) -> Bool {
        let status:AXError = AXUIElementPerformAction(ref, action)
        return status == AXError.Success
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
        print("set attr status", status)
        return status == AXError.Success
    }
    
    class func getValueAttribute<T>(ref: AXUIElementRef, property: String, type: AXValueType, inout destination: T) -> T {
        let value:AXValue? = getAttribute(ref, property: property) as AXValue?
        if (value != nil) {
            return AXValueToValue(value!, type: type, destination: &destination)
        } else {
            return destination;
        }
    }
    
    class func setValueAttribute<T>(ref:AXUIElementRef, property: String, type: AXValueType, inout source: T) -> Bool {
        if let axValue = ValueToAXValue(type, source: &source) {
            return setAttribute(ref, property: property, value: axValue)
        } else {
            return false
        }
    }
    
    /*
    Generic function for converting a AXValue to its real type.
    The destination can be one of CGSize, CGRect, CGRange, CGPoint.
    */
    class func AXValueToValue<T>(value: AXValue, type: AXValueType, inout destination: T) -> T {
        AXValueGetValue(value, type, &destination)
        return destination
    }
    
    class func ValueToAXValue<T>(type: AXValueType, inout source: T) -> AXValue? {
        if let value = AXValueCreate(type, &source) {
            return value.takeRetainedValue()
        }
        return nil
    }
    
    
}