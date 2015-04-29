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
    let context: JSContext = JSContext()
    let manager: AWManager
    let appEvents: AWApplicationNotification
    let events: AWJSEvent
    let application: AWJSApplication
    let hotkeys: AWJSHotKey
    
    let api:NSDictionary

    init() {
        context.exceptionHandler = { context, exception in
            println("JS Error: \(exception)")
        }
        context.setObject(AWJSConsole.self, forKeyedSubscript: "console")
        events = AWJSEvent(context: context)
        application =  AWJSApplication(events: events)
        hotkeys = AWJSHotKey()
        manager = AWManager(jsApp: application)
        appEvents = AWApplicationNotification(manager: manager)
        

        // initialize api objects here
        api = [
            "application": application,
            "events": events,
            "hotkey": hotkeys
        ]

        context.setObject(api, forKeyedSubscript: "aw")
        context.evaluateScript("function myThing(){}")
        context.evaluateScript("console.log('fuck this shit'); console.log(123); console.log({a: 1});")
        context.evaluateScript("aw.events.addEventListener('aw.application.launched', function(event, app) {console.log(app.pid)});")
        context.evaluateScript("aw.events.addEventListener('hi', myThing)")
        context.evaluateScript("aw.events.addEventListener('hi', myThing)")
        context.evaluateScript("aw.events.addEventListener('hi', function(){})")
        context.evaluateScript("function hotkey(){console.log('hotkey called'); aw.hotkey.removeHotkey('y', ['cmd'])}; aw.hotkey.addHotkeyListener('y', ['cmd'], hotkey);")
    }

}