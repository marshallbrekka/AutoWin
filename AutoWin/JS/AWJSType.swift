//
//  JSType.swift
//  Awesome
//
//  Class for converting CG/CF types to a JSValue

import Foundation
import JavaScriptCore

class AWJSType {
    
    class func toJSValue(value: CGSize, context: JSContext) -> JSValue {
        return JSValue(size: value, inContext: context)
    }
    
    class func toJSValue(value: CGPoint, context: JSContext) -> JSValue {
        return JSValue(point: value, inContext: context)
    }

    class func toJSValue(value: CGRect, context: JSContext) -> JSValue {
        return JSValue(rect: value, inContext: context)
    }
    
    class func toJSValue(value: CFRange, context: JSContext) -> JSValue {
        return JSValue(object: ["location": value.location, "length": value.length], inContext: context)
    }
    
    class func isEmpty(value:JSValue) -> Bool {
        return value.isNull || value.isUndefined
    }
}