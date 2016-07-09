import Foundation
import JavaScriptCore

@objc protocol AWJSConsoleInterface : JSExport {
    static func log(item: JSValue)
}

@objc class AWJSConsole: NSObject, AWJSConsoleInterface {
    class func log(item: JSValue) {
        print("JS Log: " + item.toString())
    }
    
    deinit {
        print("deinit awjsconsole")
    }
}