//
//  AWJSEvent.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/20/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol AWJSEventInterface: JSExport {
    func addEventListener(eventName:String, eventFunction: JSValue)
    
    func removeEventListener(eventName:String, eventFunction: JSValue)
}

@objc class AWJSEvent: NSObject, AWJSEventInterface {
    let context: JSContext
    let eventListeners: NSMutableDictionary;

    init(context:JSContext) {
        self.context = context
        self.eventListeners = NSMutableDictionary()
    }
    
    func addEventListener(eventName: String, eventFunction: JSValue) {
        println("adding event listener: " + eventName)
    }
    
    func removeEventListener(eventName: String, eventFunction: JSValue) {
        println("removing event listener: " + eventName)
    }
    
    func triggerEvent(eventName: String, eventData: NSDictionary) {
        println("triggering event: " + eventName)
    }
}
