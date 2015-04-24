//
//  AWJSHotKey.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/22/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation

import JavaScriptCore

@objc protocol AWJSHotKeyInterface :JSExport {
    // Use hacky param names so that we get addHotkeyListener as the js method
    func add(key:String, hotkey modifiers:[String], listener callback: JSValue)
    // Use hacky param names so that we get removeHotkey as the js method
    func remove(key:String, hotkey modifiers:[String])
}

@objc class AWJSHotKey : NSObject, AWJSHotKeyInterface {
    let manager = AWHotKeyManager()
    
    // listeners -> key:(String) -> modifiers(Number) -> dictionary(callback, eventId)
    let listeners = NSMutableDictionary()
    
    func add(key: String, hotkey modifiers: [String], listener callback: JSValue) {
        var modListeners = listenersForKey(key)
        var modKey = modifiersToModKey(modifiers)
        var watcher:NSMutableDictionary? = modListeners.objectForKey(modKey) as NSMutableDictionary?
        var casted:[AnyObject] = modifiers as [AnyObject]
        if (watcher == nil) {
            println("add listener")
            watcher = NSMutableDictionary()
            modListeners.setObject(watcher!, forKey: modKey)
            watcher?.setObject(callback, forKey: "callback")
            var hotKeyId = manager.addHotKey(key, withModifiers: casted, forCallback: recievedEvent);
            watcher?.setObject(NSNumber(unsignedInt: hotKeyId), forKey: "id")
            modListeners.setObject(watcher!, forKey: modKey)
        } else {
            watcher?.setObject(callback, forKey: "callback")
        }
    }
    
    func remove(key: String, hotkey modifiers: [String]) {
        var modListeners:NSMutableDictionary? = listeners.objectForKey(key) as NSMutableDictionary?
        if modListeners != nil {
            var modKey = modifiersToModKey(modifiers)
            var watcher:NSMutableDictionary? = modListeners?.objectForKey(modKey) as NSMutableDictionary?
            if watcher != nil {
                var watcherId:NSNumber = watcher?.objectForKey("id") as NSNumber
                manager.removeHotKey(watcherId.unsignedIntValue)
                modListeners!.removeObjectForKey(modKey)
                if (modListeners!.count == 0) {
                    listeners.removeObjectForKey(key)
                }
            }
        }
    }
    
    func modifiersToModKey(modifiers: [String]) -> NSNumber {
        return NSNumber(unsignedInt: AWKeyCodes.modifiersToModCode(modifiers))
    }

    /*
    The function that is called by AWHotKeyManager that dispatches to
    the registered JS function.
    */
    func recievedEvent(down:Bool, key: String!, modifiers: [AnyObject]!) {
        println("recieved event")
        // Only call events on down for now.
        if (down) {
            println("its down")
            var listeners:NSMutableDictionary? = self.listeners.objectForKey(key) as NSMutableDictionary?
            if (listeners != nil) {
                println("found listeners")
                var modKey = modifiersToModKey(modifiers as [String])
                var watcher = listeners!.objectForKey(modKey) as NSMutableDictionary?
                if (watcher != nil) {
                    var callback: JSValue = watcher?.objectForKey("callback") as JSValue
                    callback.callWithArguments([key, modifiers])
                }
            }
        }
    }
    
    func listenersForKey(key:String) -> NSMutableDictionary {
        var listeners:NSMutableDictionary? = self.listeners.objectForKey(key) as NSMutableDictionary?
        if (listeners != nil) {
            return listeners!;
        } else {
            listeners = NSMutableDictionary()
            self.listeners.setObject(listeners!, forKey: key)
            return listeners!
        }
    }

}