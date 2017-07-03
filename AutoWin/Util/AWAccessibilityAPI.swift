import Foundation

class AWAccessibilityAPI {
    
    class func getPid(_ ref: AXUIElement) -> pid_t {
        var pid:pid_t = 0
        AXUIElementGetPid(ref, &pid)
        return pid
    }
    
    class func isProcessTrusted() ->Bool {
        return AXIsProcessTrustedWithOptions(nil)
    }
    
    class func promptToTrustProcess() -> Bool {
        let dict = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String :kCFBooleanTrue]
        return AXIsProcessTrustedWithOptions(dict as CFDictionary?)
    }
    
    class func performAction(_ ref: AXUIElement, action: String) -> Bool {
        let status:AXError = AXUIElementPerformAction(ref, action as CFString)
        return status == AXError.success
    }
    
    class func getAttribute<T>(_ ref: AXUIElement, property: String) -> T? {
        var pointer:AnyObject?
        let status:AXError = AXUIElementCopyAttributeValue(ref, property as CFString, &pointer)
        if status != AXError.success {
            return nil
        } else {
            return pointer as? T
        }
    }
    
    class func getAttributes<T: AnyObject>(_ ref: AXUIElement, property: String) -> [T]? {
        // get the number of values for the attribute
        var attributeCount: CFIndex = 0
        let countStatus:AXError = AXUIElementGetAttributeValueCount(ref, property as CFString, &attributeCount)
        if countStatus != AXError.success {
            return nil
        } else if attributeCount == 0 {
            return [T]()
        }
        
        // get the values for the attribute
        var pointer: CFArray?
        let status:AXError = AXUIElementCopyAttributeValues(ref, property as CFString, 0, attributeCount, &pointer)
        if status != AXError.success {
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
    
    class func setAttribute<T: AnyObject>(_ ref: AXUIElement, property: String, value: T) -> Bool {
        let status:AXError = AXUIElementSetAttributeValue(ref, property as CFString, value)
        print("set attr status", status)
        return status == AXError.success
    }
    
    class func getValueAttribute<T>(_ ref: AXUIElement, property: String, type: AXValueType, destination: inout T) -> T {
        let value:AXValue? = getAttribute(ref, property: property) as AXValue?
        if (value != nil) {
            return AXValueToValue(value!, type: type, destination: &destination)
        } else {
            return destination;
        }
    }
    
    class func setValueAttribute<T>(_ ref:AXUIElement, property: String, type: AXValueType, source: inout T) -> Bool {
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
    class func AXValueToValue<T>(_ value: AXValue, type: AXValueType, destination: inout T) -> T {
        AXValueGetValue(value, type, &destination)
        return destination
    }
    
    class func ValueToAXValue<T>(_ type: AXValueType, source: inout T) -> AXValue? {
        if let value = AXValueCreate(type, &source) {
            return value
        }
        return nil
    }
}
