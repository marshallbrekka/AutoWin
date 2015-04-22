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
    func addEvent(eventName:String, listener:JSValue)
    func removeEvent(eventName:String, listener:JSValue)
}

@objc class AWJSEvent: NSObject, AWJSEventInterface {
    let context: JSContext
    let eventListeners: NSMutableDictionary;

    init(context:JSContext) {
        self.context = context
        self.eventListeners = NSMutableDictionary()
    }

    func addEvent(eventName: String, listener:JSValue) {
        println("adding event listener: " + eventName)
        var listeners:[JSValue]? = eventListeners.objectForKey(eventName) as [JSValue]?
        if (listeners == nil) {
            listeners = [listener];
        } else {
            // Exit early if the listener is already present
            for existingListener in listeners! {
                if (listener.isEqual(existingListener)) {
                    return;
                }
            }
            listeners!.append(listener)
        }
        eventListeners.setObject(listeners!, forKey: eventName)
    }
    
    func removeEvent(eventName: String, listener:JSValue) {
        println("removing event listener: " + eventName)
        var listeners:[JSValue]? = eventListeners.objectForKey(eventName) as [JSValue]?
        if (listeners != nil) {
            listeners = listeners!.filter( {(existingListener: JSValue) -> Bool in
                return listener.isNotEqualTo(existingListener)
            })
            eventListeners.setObject(listeners!, forKey: eventName)
        }
    }
    
    func triggerEvent(eventName: String, eventData: NSDictionary) {
        var listeners: [JSValue]? = eventListeners.objectForKey(eventName) as [JSValue]?
        if (listeners != nil) {
            println("triggering listeners for: " + eventName)
            for listener in listeners! {
                listener.callWithArguments([eventName, eventData])
            }
        } else {
            println("no listeners for: " + eventName)
        }
    }
}
