//
//  AWJSContext.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/20/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

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
        application = AWJSApplication(events: events)
        window      = AWJSWindow(events: events)
        hotkeys     = AWJSHotKey()
        // this should be removed, only leaving to get it to compile
        manager     = AWManager()
        monitors    = AWJSMonitors(events: events)
        

        // initialize api objects here
        api = [
            "application": application,
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
        context.evaluateScript("function hotkey(){console.log('hotkey called'); aw.hotkey.removeHotkey('y', ['cmd'])}; aw.hotkey.addHotkeyListener('y', ['cmd'], hotkey);")
        context.evaluateScript("var m = aw.monitors.monitors(); console.log(m[0].id); console.log(m[0].frame.width); console.log(m[0].frame.height);")
        context.evaluateScript("console.log(m[0].frame.x); console.log(m[0].frame.y);")
    }

}