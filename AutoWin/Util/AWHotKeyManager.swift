//
//  AWHotKeyManager.swift
//  Awesome
//
//  Created by Marshall Brekka on 11/18/15.
//  Copyright © 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Carbon

typealias AWHotKeyCallback = (down:Bool, key:String, modifiers:[String]) -> Void

class AWHotKeyManager {
    struct AWHotKeyInstance {
        let ref: EventHotKeyRef
        let key: String
        let modifiers: [String]
        var callbacks: NSMutableArray
    }
    
    struct AWHotKeyRef {
        let keyCode:UInt32
        let modCode:UInt32
        let handler: AWHotKeyCallbackWrapper
    }
    
    class AWHotKeySelfRef {
        let down:Bool
        let this:AWHotKeyManager
        init(down:Bool, this:AWHotKeyManager) {
            self.down = down
            self.this = this
        }
    }
    
    class AWHotKeyCallbackWrapper {
        var callback:AWHotKeyCallback
        init(callback:AWHotKeyCallback) {
            self.callback = callback
        }
    }

    var hotKeyInstances = [UInt64: AWHotKeyInstance]()
    var downRef:AWHotKeySelfRef?
    var upRef:  AWHotKeySelfRef?
    var downPointer:UnsafeMutablePointer<Void>?
    var upPointer:  UnsafeMutablePointer<Void>?
    
    init() {
        downRef     = AWHotKeySelfRef(down: true, this: self)
        upRef       = AWHotKeySelfRef(down: false, this: self)
        downPointer = UnsafeMutablePointer(Unmanaged.passUnretained(downRef!).toOpaque())
        upPointer   = UnsafeMutablePointer(Unmanaged.passUnretained(upRef!).toOpaque())

        installHandlerHelper(kEventHotKeyPressed, pointer: downPointer!)
        installHandlerHelper(kEventHotKeyReleased, pointer: upPointer!)
    }
    
    func addHotKey(key:String, modifiers:[String], callback:AWHotKeyCallback) -> AWHotKeyRef {
        let keyCode = AWKeyCodes.charToKeyCode(key)
        let modCode = AWKeyCodes.modifiersToModCode(modifiers)
        let code = AWHotKeyManager.combineKeyAndModCode(keyCode, modCode: modCode)
        let callbackWrapper = AWHotKeyCallbackWrapper(callback: callback)
        
        if let keyInstance = hotKeyInstances[code] {
            // we already have a listener, append the callback to the list
            keyInstance.callbacks.addObject(callbackWrapper)
        } else {
            // No listener, register one and start tracking callbacks
            var ref:EventHotKeyRef = nil
            let hotKeyID = EventHotKeyID(signature: modCode, id: keyCode)
            RegisterEventHotKey(keyCode, modCode, hotKeyID, GetEventMonitorTarget(), 0,  &ref)
            let keyInstance = AWHotKeyInstance(
                ref: ref,
                key: key,
                modifiers: modifiers,
                callbacks: [callbackWrapper])
            hotKeyInstances[code] = keyInstance
        }
        return AWHotKeyRef(keyCode: keyCode, modCode: modCode, handler: callbackWrapper)
    }
    
    func removeHotKey(ref: AWHotKeyRef) {
        let code = AWHotKeyManager.combineKeyAndModCode(ref.keyCode, modCode: ref.modCode)
        if let keyInstance = hotKeyInstances[code] {
            keyInstance.callbacks.removeObject(ref.handler)
            if (keyInstance.callbacks.count == 0) {
                UnregisterEventHotKey(keyInstance.ref)
                hotKeyInstances.removeValueForKey(code)
            }
        }
    }
    
    private func installHandlerHelper(eventKind: Int, pointer:UnsafeMutablePointer<Void>) {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(eventKind))

        InstallEventHandler(GetEventMonitorTarget(), {
            (handler: EventHandlerCallRef, event:EventRef, ptr:UnsafeMutablePointer<Void>) -> OSStatus in
            let pair = Unmanaged<AWHotKeySelfRef>.fromOpaque(COpaquePointer(ptr)).takeUnretainedValue()
            pair.this.eventHandler(pair.down, handler: handler, event: event)
            return noErr
        }, 1, &eventType, pointer, nil)
    }
    
    private func eventHandler(down: Bool, handler: EventHandlerCallRef, event:EventRef) {
        var hotKeyId:EventHotKeyID = EventHotKeyID()
        GetEventParameter(event, OSType(kEventParamDirectObject), OSType(typeEventHotKeyID), nil, sizeof(EventHotKeyID), nil, &hotKeyId)
        let code = AWHotKeyManager.combineKeyAndModCode(hotKeyId.id, modCode: hotKeyId.signature)
        print("event handler", down, handler, event, hotKeyId.id, hotKeyId.signature)
        if let keyInstance = hotKeyInstances[code] {
            for callback:AnyObject in keyInstance.callbacks {
                (callback as! AWHotKeyCallbackWrapper).callback(
                    down: down,
                    key: keyInstance.key,
                    modifiers: keyInstance.modifiers)
            }
        }
    }
    
    static func combineKeyAndModCode(keyCode:UInt32, modCode: UInt32) -> UInt64 {
        let code = UInt64(keyCode)
        let modCodeInt = UInt64(modCode)
        return modCodeInt << 32 | code
    }
    
    static func keyAndModifiersToCode(key:String, modifiers:[String]) -> UInt64 {
        let keyCode = AWKeyCodes.charToKeyCode(key)
        let modCode = AWKeyCodes.modifiersToModCode(modifiers)
        return AWHotKeyManager.combineKeyAndModCode(keyCode, modCode: modCode)
    }
}
