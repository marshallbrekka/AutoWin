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
    func addEvent(eventName:String, _ listener:JSValue)
    func removeEvent(eventName:String, _ listener:JSValue)
}

@objc class AWJSEvent: NSObject, AWJSEventInterface {
    let eventListeners: NSMutableDictionary;

    override init() {
        self.eventListeners = NSMutableDictionary()
    }
    
    deinit {
        print("deinit awjsevent")
    }

    func addEvent(eventName: String, _ listener:JSValue) {
        print("adding event listener: " + eventName)
        let wrapped = JSManagedValue(value: listener)
        listener.context.virtualMachine.addManagedReference(wrapped, withOwner: self)
        var listeners:[JSManagedValue]? = eventListeners.objectForKey(eventName) as! [JSManagedValue]?
        if (listeners == nil) {
            listeners = [wrapped];
        } else {
            // Exit early if the listener is already present
            for existingListener in listeners! {
                if (wrapped.isEqual(existingListener)) {
                    return;
                }
            }
            listeners!.append(wrapped)
        }
        eventListeners.setObject(listeners!, forKey: eventName)
    }
    
    func removeEvent(eventName: String, _ listener:JSValue) {
        print("removing event listener: " + eventName)
        var listeners:[JSManagedValue]? = eventListeners.objectForKey(eventName) as! [JSManagedValue]?
        if (listeners != nil) {
            listeners = listeners!.filter( {(existingListener: JSManagedValue) -> Bool in
                if (listener.isNotEqualTo(existingListener.value)) {
                    return true
                } else {
                    existingListener.value.context.virtualMachine.removeManagedReference(existingListener, withOwner: self)
                    return false
                }
            })
            eventListeners.setObject(listeners!, forKey: eventName)
        }
    }
    
    func triggerEvent(eventName: String, eventData: NSDictionary?) {
        let listeners: [JSManagedValue]? = eventListeners.objectForKey(eventName) as! [JSManagedValue]?
        if (listeners != nil) {
            print("triggering listeners for: " + eventName)
            for listener in listeners! {
                if eventData == nil {
                    listener.value.callWithArguments([eventName])
                } else {
                    listener.value.callWithArguments([eventName, eventData!])
                }
            }
        } else {
            print("no listeners for: " + eventName)
        }
    }
}
