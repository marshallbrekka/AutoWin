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

class AWJSContext {
    let context:     JSContext = JSContext()
    let manager:     AWManager
    let events:      AWJSEvent
    let application: AWJSApplication
    let window:      AWJSWindow
    let hotkeys:     AWJSHotKey
    let monitors:    AWJSMonitors
    
    let api:         NSDictionary

    init() {
        context.exceptionHandler = { context, exception in
            print("JS Error: \(exception)")
        }
        context.setObject(AWJSConsole.self, forKeyedSubscript: "console")
        events      = AWJSEvent(context: context)
        manager     = AWManager()
        application = AWJSApplication(manager: manager, events: events)
        window      = AWJSWindow(manager: manager, events: events)
        hotkeys     = AWJSHotKey()
        // this should be removed, only leaving to get it to compile
        monitors    = AWJSMonitors(events: events)
        

        // initialize api objects here
        api = [
            "application": application,
            "window": window,
            "events": events,
            "hotkey": hotkeys,
            "monitors": monitors
        ]

        context.setObject(api, forKeyedSubscript: "aw")
        context.evaluateScript("function myThing(){}")
        context.evaluateScript("console.log('fuck this shit'); console.log(123); console.log({a: 1});")
        context.evaluateScript("aw.events.addEventListener('aw.application.launched', function(event, app) {console.log(app.pid)});")
        context.evaluateScript("aw.events.addEventListener('hi', myThing)")
        context.evaluateScript("aw.events.addEventListener('hi', myThing)")
        context.evaluateScript("aw.events.addEventListener('hi', function(){})")
        context.evaluateScript("function hotkey(){console.log('hotkey called'); var w = aw.window.focusedWindow(); if (w) {aw.window.close(w.pid, w.id);}}; aw.hotkey.addHotkeyListener('y', ['cmd'], hotkey);")
        context.evaluateScript("function size(){console.log('size called'); var w = aw.window.focusedWindow(); if (w) {aw.window.setFrame(w.pid, w.id, {x:50, y:50, width: 200, height: 200}); aw.window.getFrame(w.pid, w.id);}}; aw.hotkey.addHotkeyListener('j', ['cmd'], size);")
        context.evaluateScript("var m = aw.monitors.monitors(); console.log(m[0].id); console.log(m[0].frame.width); console.log(m[0].frame.height);")
        context.evaluateScript("console.log(m[0].frame.x); console.log(m[0].frame.y);")
        context.evaluateScript("var windows = aw.window.windows(); console.log(windows[0].id); console.log(windows[0].pid)")
    }

}