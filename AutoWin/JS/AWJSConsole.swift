import Foundation
import JavaScriptCore

@objc protocol AWJSConsoleInterface : JSExport {
    static func log(_ item: JSValue)
}

@objc class AWJSConsole: NSObject, AWJSConsoleInterface {
    class func log(_ item: JSValue) {
        NSLog("JS Log: " + item.toString())
    }
    
    deinit {
        NSLog("deinit AWJSConsole")
    }
}
