/**
Entry point for the javascript environment that supports the 
aw.* apis.

The Class model is like so:
AWManager()
AWJSEvent()
AWJSManager(AWManager, AWJSEvent)
AWJSWindow(AWJSManager)
AWJSApplication(AWJSManager)
AWJSHotKey()
AWJSMonitors(AWJSEvent)
*/
import Foundation
import JavaScriptCore
import WebKit

class AWJSContext:NSObject {
    var webView:     WebView?
    var context:     JSContext
    let manager:     AWManager
    let events:      AWJSEvent
    let application: AWJSApplication
    let window:      AWJSWindow
    let hotkeys:     AWJSHotKey
    let monitors:    AWJSMonitors
    let mouse:       AWJSCursor
    
    let api:         NSDictionary
    
    init(manager:AWManager, hotKeys:AWHotKeyManager, customContent:String) {
        webView = WebView()
        // WKWebView
        // webView!.mainFrameURL = "https://www.google.com"
        // webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        context = JSContext(jsGlobalContextRef: (webView?.mainFrame.globalContext)!)
        context.exceptionHandler = { context, exception in
            NSLog("JS Error: \(exception)")
        }
        context.setObject(AWJSConsole.self, forKeyedSubscript: "console" as (NSCopying & NSObjectProtocol)!)
        
        self.manager = manager
        
        events      = AWJSEvent()
        application = AWJSApplication(manager: manager, events: events)
        window      = AWJSWindow(manager: manager, events: events)
        hotkeys     = AWJSHotKey(manager: hotKeys)
        monitors    = AWJSMonitors()
        mouse       = AWJSCursor()

        // initialize api objects here
        api = [
            "application": application,
            "window": window,
            "events": events,
            "hotkey": hotkeys,
            "monitors": monitors,
            "cursor": mouse,
        ]

        context.setObject(api, forKeyedSubscript: "aw" as (NSCopying & NSObjectProtocol)!)
        context.evaluateScript(customContent)
    }
    
    deinit {
        print("deinitting context")
        //JSGlobalContextRelease((webView?.mainFrame.globalContext)!)
        context.setObject(nil, forKeyedSubscript: "console" as (NSCopying & NSObjectProtocol)!)
        context.setObject(nil, forKeyedSubscript: "aw" as (NSCopying & NSObjectProtocol)!)
    }
}
