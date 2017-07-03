import Foundation
import JavaScriptCore

class AWJSType {
    
    class func toJSValue(_ value: CGSize, context: JSContext) -> JSValue {
        return JSValue(size: value, in: context)
    }
    
    class func toJSValue(_ value: CGPoint, context: JSContext) -> JSValue {
        return JSValue(point: value, in: context)
    }

    class func toJSValue(_ value: CGRect, context: JSContext) -> JSValue {
        return JSValue(rect: value, in: context)
    }
    
    class func toJSValue(_ value: CFRange, context: JSContext) -> JSValue {
        return JSValue(object: ["location": value.location, "length": value.length], in: context)
    }
    
    class func isEmpty(_ value:JSValue) -> Bool {
        return value.isNull || value.isUndefined
    }
}
